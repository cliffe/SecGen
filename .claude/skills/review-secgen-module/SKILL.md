---
name: review-secgen-module
description: Review a SecGen vulnerability/service/utility module for correctness and consistency between its secgen_metadata.xml and Puppet manifests. Use when asked to review, audit, or check a SecGen module, especially that declared read_facts have default_inputs and that leaked/encoded strings are actually exposed to the attacker. Trigger words - "review this module", "check this secgen module", "audit modules/vulnerabilities/...".
---

# Review a SecGen module

Check a SecGen module for internal consistency between its `secgen_metadata.xml` (the declaration of inputs) and its Puppet manifests (the code that consumes those inputs and actually provisions the vulnerable/insecure state).

The single most important property: **every input the module declares must have a sane default, be read by the Puppet code, and — for leak/encode inputs — must actually reach the attacker.** A module that declares `strings_to_leak` but never leaks them is broken: the challenge has no payload to find.

## What a module looks like

A module lives under `modules/{vulnerabilities,services,utilities}/.../<name>/`:

- `secgen_metadata.xml` — declares `<read_fact>` inputs, `<default_input>` defaults, module attributes, conflicts/requires.
- `<name>.pp` — entry point, `include`s the manifest classes.
- `manifests/*.pp` — usually `install.pp`, `config.pp`, `service.pp`. `config.pp` reads parameters and does the leaking/encoding.
- `templates/`, `files/`, `secgen_test/` — supporting assets.

Read `README-Modules-Metadata.md` and `README-Modules-Puppet.md` in the repo root for the authoritative format.

This skill reviews a module **in isolation**. Whether a module's inputs are wired correctly *within a challenge* — cross-module datastores, the overall kill chain, whether the scenario passes inputs the module actually reads — is the job of the `review-secgen-scenario` skill. Reach for that when reviewing a `scenarios/**/*.xml` file.

## How to run the review

1. Read `secgen_metadata.xml`. Collect:
   - Every `<read_fact>NAME</read_fact>`.
   - Every `<default_input into="NAME">...</default_input>` and its generator/ encoder/value contents.
   - Module attributes (`name`, `privilege`, `access`, `platform`, `type`, `conflict`, `requires`).
2. Read `<name>.pp` and every file in `manifests/`. Collect:
   - Parameters read via `$secgen_parameters['NAME']`.
   - Every `::secgen_functions::leak_files` / `leak_file` call and which `strings_to_leak` / `leaked_filenames` / `images_to_leak` it uses.
   - Every use of `strings_to_encode` / encoder consumption.
   - Templates referenced, and whether read parameters flow into them.
3. Cross-check against the rules below.
4. Report findings grouped by severity. For each: the file:line, what rule it breaks, and the concrete consequence for the challenge.

## Rules to check

### R1 — Every `<read_fact>` has a `<default_input>`

For each `<read_fact>NAME</read_fact>` there should be a matching `<default_input into="NAME">`, so the module still works when selected randomly (no scenario supplies the input).

**Calibrate the severity by the actual failure mode**, don't just assert "it breaks":

- If the Puppet code indexes the missing fact (e.g. `$fact[0]`) or requires a real value, the missing default genuinely breaks the module — higher severity.
- If the fact flows into something that tolerates an empty array — notably `leak_files`, whose params default to `[]` and simply produce no files — then a missing default is a **silent no-op empty leak**, not a crash. Still a real gap (a leak fact with no default leaks nothing), but lower severity. Say which it is.

Exceptions that legitimately have no default:

- `organisation` — optional override, intentionally empty by default.
- Facts documented as "no default by design" (flag it as a note, not an error, and confirm the Puppet code handles the empty case, e.g. the `if $raw_org...` guard in the proftpd example).

### R2 — Every `<default_input>` targets a declared fact

Each `<default_input into="NAME">` should correspond to a `<read_fact>NAME</read_fact>` (or a genuinely code-consumed parameter). A default for a fact that is never read is dead config — flag it.

### R3 — Every read fact is consumed by Puppet

Each `<read_fact>` should be read via `$secgen_parameters['NAME']` somewhere in the manifests (or passed onward). A declared-but-unread fact means the default generator runs for nothing.

### R4 — Payloads reach the attacker at the right point in the attack path

This is the core check, and it is a **reasoning task, not a pattern match**. `leak_files`/`leak_file` is only the most common mechanism. Related SecGen defines do the same job under different names — notably `secgen_functions::leak_to_file::leak_file` (used by e.g. the `zip_file` module) — so "no `leak_files` call" does **not** mean "no leak". Beyond those, a module may surface its payload in any number of ways, for example:

- writing a world-/group-readable file directly (`file { ... }`),
- an ERB template that interpolates the string into a service config, banner, MOTD, web page, or FTP welcome message,
- seeding a database, an environment variable, a comment, or a hosted download,
- embedding it in an image, QR code, or archive.

So do not just grep for `leak_files`. Instead, **trace the actual challenge**: build a mental model of the intended attack (from the module's vuln type, `privilege`, `access`, `msf_module`, `hint`, `solution`, and the Puppet code), then for each payload ask *when in that attack path does the pen tester obtain it, and with what access?*

**Not every module has a pre/post-leak split — many have neither.** The `strings_to_pre_leak` vs `strings_to_leak` distinction below only applies when the module actually declares those facts. Plenty of modules just place a single plain file (or none at all — e.g. `parameterised_accounts` leaks per-account home files, and a module like `ssh_root_login` may exist only to enable a service/config with its leak facts unused by the scenario). Only apply the pre/post reasoning to the facts the module really uses; don't manufacture a pre/post classification that isn't there.

**A vuln module with *no* leak facts (or none at all) is often correct — the flag lives elsewhere on the same VM.** A pure exploitable-service module (e.g. `easyftp_rce` declares zero `read_fact`s and leaks nothing; the backdoor just grants RCE) is legitimate: its job is to be exploitable, and the objective flag is placed by a **sibling module on the same `<system>`** — commonly `parameterised_accounts` leaking to the exploited user's home/Desktop. So when a vuln module is inert, don't report "no payload"; instead confirm some other module on that system places the flag somewhere the exploit's resulting access reaches. (This is a scenario-level check — the `review-secgen-scenario` S4 per-system flag inventory covers it.)

- **`strings_to_pre_leak` / `pre_leaked_filenames`** — a `pre_leak` fact means "leaked *earlier* than the main `strings_to_leak` payload", which classifies it by the module's **mechanism**, not automatically by pre-authentication. Two legitimate shapes exist, so **decide which one this module intends before you judge reachability**:

  1. *Pre-auth breadcrumb* — a clue the student's starting position can reach (anonymous FTP home, public web root, login banner, world-readable file) that sets up or hints at the exploit. This is the common case (e.g. bludit's dirbuster-discoverable web file).
  2. *Primitive-revealed content* — content the exploit primitive itself surfaces, stored behind privilege by design. For example `sudo_root_less` leaks `strings_to_pre_leak` to `/root/<name>` at `0600` owned root: it is unreachable pre-auth *on purpose* because reading it **is** the challenge — `sudo -l` discloses the filename and `sudo less /root/<file>` reads it as root. Flagging this as "unreachable pre-exploit" would be a false positive.

  So do **not** mechanically require pre-leak to be pre-auth readable. Determine the intended mechanism from the Puppet code, `hint`/`solution`, and the privesc primitive, then verify the content is reachable *at the step the module intends*. Only flag a genuine mismatch (e.g. a breadcrumb that was *meant* to bootstrap the attack but sits somewhere only the post-exploit user can read).
- **`strings_to_leak` / `leaked_filenames`** are *usually* the **solution payload** — the proof/flag the student obtains **only after** performing the intended attack. In the offensive case, verify it is *not* reachable from the starting position: it should sit behind the privilege/access the exploit grants (e.g. `/root` at `0600` after a root-level RCE, or the exploited user's home after that user is compromised). If a supposedly post-exploitation payload is already world-readable or reachable pre-attack, the challenge is trivially bypassable — flag it. **But `strings_to_leak` is not always a post-exploit payload.** Judge by *role*, not fact name. In **defensive / blue-team labs** (e.g. Hackerbot integrity labs) the same fact holds **assets the student must protect** — trade secrets, card data, logs placed readable in the student's *own* home from the start. There, being world-/owner-readable pre-"attack" is the whole point, not a bug; the challenge is to *defend* them, and any reward flag is delivered by the bot, not this file. Determine whether the module/scenario is offensive or defensive before applying the "must not be reachable early" test.

**Fact names vary.** Do not assume the pre-leak filename fact is called `pre_leaked_filenames` — modules name these to fit the delivery mechanism (e.g. `web_pre_leak_filename` for a dirbuster-discoverable file in a web root). Match by role and by tracing the code, not by fixed names.

**Short-circuit check (both directions).** Explicitly verify the payload is reachable at its stage and *not* at the wrong one:

- The solution `strings_to_leak` must **not** be inadvertently reachable pre-attack — e.g. leaked into a directory the web server serves directly, or a world-readable path — which would let the student grab the flag without doing the exploit. **Verify the protection is actually in effect, not just present.** A common trap: the bludit flag lands in `bl-content/tmp` and the app ships an `.htaccess` deny rule for `bl-content/*`, but that rule only applies if the vhost enables `AllowOverride` — puppetlabs-apache defaults to `AllowOverride None`, which silently ignores the `.htaccess` and leaves the directory served. So "confirm that holds" means confirming the `AllowOverride`/rewrite is enabled and the deny is live, and checking what the residual protection is if it isn't (here, only the random `filename_generator` name). A present-but-ignored `.htaccess` is the realistic failure mode — check for it explicitly.
- The pre-leak content must **actually be served/reachable** by the intended discovery method — e.g. a static file dropped in a docroot must actually be returned by the web server (right location, servable by the vhost config), not swallowed by the app router. If the student can't reach the clue, it's useless.

The two must not be confused or swapped. Common concrete bugs:

- a pre-leak call/file using `$strings_to_leak` instead of `$strings_to_pre_leak` (or vice-versa) — the intended payload never surfaces at the right stage;
- pre-leak content stored somewhere only root/the exploited user can read;
- the solution `strings_to_leak` placed in a pre-exploit-readable location, short-circuiting the challenge;
- a payload declared and defaulted but written nowhere at all.

State explicitly, per payload, **the access level and attack step at which the student obtains it**, and whether that matches its pre/post intent.

Reference example (proftpd_133c_backdoor `config.pp`) — here the mechanism is two separate `leak_files` calls, but the point is *where* each lands: `strings_to_leak` into `/root` (reachable only after the root-level backdoor RCE) and `strings_to_pre_leak` into the anonymous FTP user's home (reachable before the attack):

```puppet
::secgen_functions::leak_files { 'proftpd_133c_backdoor-file-leak':
  storage_directory => '/root',
  leaked_filenames  => $leaked_filenames,
  strings_to_leak   => $strings_to_leak,
  leaked_from       => "proftpd_133c_backdoor",
  mode              => '0600'
}
::secgen_functions::leak_files { 'proftpd_133c_backdoor-file-pre-leak':
  storage_directory => $anon_user_home,
  leaked_filenames  => $pre_leaked_filenames,
  strings_to_leak   => $strings_to_pre_leak,   # note: pre-leak strings
  leaked_from       => "proftpd_133c_backdoor-pre",
  mode              => '0600'
}
```

with metadata:

```xml
<read_fact>strings_to_pre_leak</read_fact>
<read_fact>pre_leaked_filenames</read_fact>
<default_input into="strings_to_pre_leak">
  <generator type="message_generator"/>
</default_input>
<default_input into="pre_leaked_filenames">
  <value>note</value>
</default_input>
```

### R4b — Facts required to *perform* the attack are set and obtainable

Some modules declare a third category of input: credentials or other facts the student must possess to carry out the exploit — e.g. `known_username`, `known_password`, a known token, a target path. These are neither pre-leak clues nor solution payloads; they are the keys to the attack. For each, verify **both**:

1. **They are actually installed as the real, working values.** Trace that the fact is written into the live config the exploit hits (not just declared). Watch for multi-step plumbing that can drift out of sync — e.g. the bludit module sets the password via `install.php` using `$known_password`, then has to `sedusers.php` to rename the account to `$known_username` because the installer hardcodes `admin`. If either step used the wrong variable or ran in the wrong order (note the `->` ordering), the credentials wouldn't match and the challenge would be unsolvable.
2. **They are obtainable by the intended method.** Confirm the generator matches the intended difficulty/technique: a password meant to be bruteforced uses `weak_password_generator` (not a strong random one); a username meant to be guessed defaults to something guessable (`admin`) or is itself pre-leaked. A "bruteforceable" credential generated as an unguessable 32-char string is a bug — the intended attack path is impossible.

Cross-check with metadata: if `<type>bruteforceable</type>` (or a hint/solution) implies credentials are in play, the required facts and their generators must support that.

**Caveat — the module default is not the final word.** A module review only sees the module's own `default_input` generator. A scenario can **override** it with `<input into="known_password">`, which changes the security property you just signed off on — e.g. bludit defaults `known_password` to `weak_password_generator` (bruteforceable), but a scenario may override it with a stronger generator that defeats the intended bruteforce. So when this credential is bruteforce/guess critical, note "if a scenario overrides this generator, the technique must be re-verified at scenario level" — this is exactly what the `review-secgen-scenario` skill's S3 checks. Note the override can also legitimately go the *other* way: a scenario may repurpose the module for a side effect and **strengthen** the credential on purpose (e.g. `ssh_root_login` included only to enable SSH + `PermitRootLogin`, with a strong root password because the intended crack targets a different account). At module level, just verify the default supports the module's own advertised attack; whether an override is right or wrong is a scenario-objective question, not a module bug.

### R4c — The provisioned service is identifiable and in a realistic state

For a **service/vulnerability module that stands up a network service** (web app, daemon, appliance), the student has to *find and recognise* it before exploiting it. Trace what actually gets served and ask three things:

1. **Is it identifiable as the intended software?** Confirm some concrete signal discloses what it is by the discovery method the challenge expects — an HTTP `<title>`/banner/favicon, a service-version string, a login page, a default path. Note *which* method reveals it: a web console whose HTML title says the product name is discoverable by browser or `http-title`, but bare `nmap -sV` may only see a generic Jetty/nginx/HTTP server and **not** the product or its (vulnerable) version. If the only identifying signal lives somewhere the expected recon won't look, say so — the student may not realise what they've found or that it's the vulnerable build.
2. **Does it come up in a realistic, valid, visually logical state?** A service that installs but boots empty/half-configured (e.g. an admin console with zero data, a CMS with no posts, a DB with no tables) is *functionally* fine for the exploit but reads as a sterile lab artefact rather than a system someone runs. Confirm the provisioned state is coherent (right port, service actually `running`, no error page) and note when it looks unrealistically empty.
3. **Minimal-effort realism improvements.** Where the software already ships sample/seed data or a quickstart (very common — Druid's wikipedia sample, a CMS's demo content), a single post-`service` `exec` that loads it (gated with `require => Service[...]` and `tries`/`try_sleep` for startup) makes the box look used for almost no cost. Suggest the cheapest concrete change; don't demand elaborate content. Realism here is usually **cosmetic/pedagogical, not a solvability break** — rank it Low unless the *identifiability* gap (point 1) could actually stop the intended student from finding/recognising the target, which is Medium.

### R5 — `leak_files` calls are well-formed (when that mechanism is used)

If the module leaks via `leak_files`/`leak_file`, confirm the mandatory params are present and paired correctly:

- `storage_directory` (required) and `leaked_from` (required — must be unique per call to avoid Puppet resource clashes; two calls sharing a `leaked_from` collide).
- `strings_to_leak` count vs `leaked_filenames` count: leak_files zips them, so a single filename with many strings appends to one file — confirm that's intended.
- `owner`/`group`/`mode` produce access appropriate to the leak timing (pre vs post exploitation).

### R6 — Encode inputs are consumed

If the module declares `strings_to_encode` (or is an encoder-consuming module), confirm the encoded value is written somewhere the challenge uses it (template, file, service config). A declared `strings_to_encode` that never lands in output is dead.

### R7 — Defaults use appropriate generators

Sanity-check `<default_input>` generator choices:

- `strings_to_leak` / `strings_to_pre_leak` → `message_generator` (or a nested generator/encoder producing text).
- `leaked_filenames` / `pre_leaked_filenames` → `filename_generator` or a literal `<value>`.
- `server_name` / usernames → `username_generator`.
- `port` → a literal `<value>` (e.g. `21`). Flag mismatches (e.g. a filename fact defaulting to a message generator).

### R8 — Manifest/metadata plumbing consistency

- Entry point `<name>.pp` `include`s each manifest class that must run (`install`, `config`, `service` as applicable).
- Every parameter read in Puppet either has a `<read_fact>` or is a genuinely internal/derived value — flag reads of `$secgen_parameters['X']` where `X` is not declared.
- Templates (`content => template(...)`) referenced actually exist and receive the variables they interpolate.

**Not every module is Puppet-based — don't apply R8 to those.** Content **generators** under `modules/generators/structured_content/**` (notably `hackerbot_config/*`) have an empty/`.no_puppet` `.pp`; their logic lives in `secgen_local/local.rb` plus ERB templates (e.g. `*_lab.xml.erb`), and their `secgen_metadata.xml` declares `read_fact`s/`default_input`s consumed by that Ruby, not by Puppet. For these, R8's "entry `.pp` includes each class" is inapplicable — review the `local.rb` and templates instead (and, for hackerbot, the bot-wiring checks in the scenario skill's S8). R1–R3 still apply (facts should have defaults and be consumed — but *by the Ruby/ERB*, so grep there, not just Puppet).

### R9 — Metadata attribute sanity (lower priority)

- `privilege`, `access`, `platform`, `type` are present and consistent with what the module does (e.g. a remotely exploitable service is `access=remote`).
- `conflict`/`requires` are minimal (conflicts reduce randomisation — flag unnecessary ones).
- Description, references, and (if real) CVE/CVSS are present.

## Output format

Report as a grouped list, most severe first. Use this shape:

- **[R4] config.pp:46 — pre-leak payload never exposed.** The pre-leak call uses `$strings_to_leak` instead of `$strings_to_pre_leak`, so `strings_to_pre_leak` is generated but never leaked; the pre-exploitation clue is missing.

Severity guide:

- **High**: a declared payload never reaches the attacker (R3/R4), the solution reachable pre-attack or the pre-leak clue unreachable (R4), credentials that don't match the live config or aren't obtainable by the intended method (R4b), a read fact with no default that isn't an intentional exception (R1), resource clashes (R5).
- **Medium**: dead defaults/facts (R2/R6), wrong generator (R7), plumbing gaps (R8).
- **Low**: metadata attribute polish (R9).

End with an explicit walkthrough of the attack path and a verdict:

1. Where the student starts, and what pre-leak clues they can obtain there.
2. The intended attack step and the access it grants.
3. Whether the solution `strings_to_leak` payload becomes reachable only at that step — not before.

Verdict: does the challenge actually hand the pen tester its pre-leak clues *before* the attack and its solution payload *only after* the intended attack?
