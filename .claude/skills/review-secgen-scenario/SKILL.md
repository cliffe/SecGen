---
name: review-secgen-scenario
description: Review a SecGen scenario (scenarios/**/*.xml) for a coherent, solvable challenge - correct datastore wiring across modules, an intended attack/kill chain that works end-to-end, inputs that match the modules' read_facts, and flags that are reachable. Use when asked to review, audit, or check a SecGen scenario. Ends by listing the modules the scenario uses and recommending the review-secgen-module skill on each. Trigger words - "review this scenario", "check scenarios/...", "audit the ctf".
---

# Review a SecGen scenario

A scenario (`scenarios/**/*.xml`) composes modules into a complete challenge: one or more `<system>` VMs, each with a `<base>`, and a set of `<utility>`, `<service>`, and `<vulnerability>` modules wired together with **datastores** (scenario-global variables holding arrays of strings) and generators/encoders.

Where the **module** review (see the `review-secgen-module` skill) checks one module in isolation, the **scenario** review checks the things only visible at the composition level:

- Does the intended attack chain actually work end-to-end?
- Is every cross-module datastore wired consistently (the value one module produces is the value another consumes)?
- Do the inputs the scenario passes match the target modules' declared `read_fact`s (an input a module doesn't read is silently dropped)?
- Are all flags reachable, in the right order, by the intended path?

Read `README-Creating-Scenarios.md` for the authoritative format (parameterisation, datastores, `access_json`, `IP_addresses`, uniqueness, cleanup).

## First: identify the scenario *shape* — do not assume CTF

The rules below are written with a multi-VM attacker-vs-target CTF in mind, but many scenarios are **not** that shape, and applying CTF assumptions to them produces false positives. Before reviewing, classify the scenario from its `<type>` (there may be **several** `<type>` tags, e.g. `ctf-lab`, `lab-sheet`), its structure, and its framing:

- **CTF** (`ctf`, `attack-ctf`, `pwn-ctf`): attacker VM + target(s), a kill chain, flags gated by exploitation, pre/post-leak breadcrumbs. The rules apply directly.
- **Lab / teaching** (`lab`, `ctf-lab`, `lab-sheet`): guided, pedagogical, often a fixed attacker workstation (e.g. a Kali box with a **deliberately known**`kali/kali` login and no flags) plus one target. The authoritative "solution" usually lives in an external **`<lab_sheet_url>`** field, *not* in the description — read it if present, and treat the `<description>` as teaching prose ("you will attempt online brute force attacks"), not a precise chain to verify line-by-line. Flags are frequently plain per-account home-directory files placed by a **utility** (`parameterised_accounts`), with **no** pre/post-leak distinction. Privilege steps may be plain account features (`super_user` → sudo), not exploits.
- **Hackerbot / interactive-bot lab** (`hackerbot-lab`, and a `.../hackerbot_config/*` generator in use): a **defensive/blue-team** guided lab. A `desktop` (student's own box, autologin with a known password) plus a `hackerbot_server`; the student chats to the **`hackerbot`** bot over IRC (via `pidgin`) and the bot **rewards flags as chat messages** when it verifies the student has correctly hardened/defended their machine — flags are **not placed on disk**. This inverts several CTF assumptions:
  - Flags are minted inside the **generator module** (`hackerbot_config/*default_input` or a passed `flags` fact) and delivered via bot `<message>` (`<%= $flags.pop %>`). There is usually **no `flag_generator` in the scenario XML at all** — that absence is *not* a finding here (see S4).
  - `strings_to_leak`/`leaked_filenames` on the accounts are the **assets the student must defend** (trade secrets, card data, logs) placed in the student's own home — deliberately readable from the start. They are the *opposite* of a post-exploit payload; do **not** apply R4's "must not be reachable pre-attack".
  - The bot legitimately holds **root on the target** from the outset (via an SSH key handshake) so it can run verification commands. There is no attacker account transition to trace (S2b is N/A).
  - The generator's real logic lives in `secgen_local/local.rb` + a `*_lab.xml.erb` template, **not** in Puppet manifests (its `.pp` is empty/`.no_puppet`). See S8 and the module skill's note on `hackerbot_config` generators.

Adjust expectations accordingly. When a rule below assumes a CTF-only construct (pre/post-leak, RCE→root, flags-in-vuln-module), and the scenario legitimately does it differently, that is **not a finding** — say so explicitly rather than forcing the scenario into the CTF template.

## How to run the review

1. Read the scenario. Build the picture:
   - Each `<system>`: `system_name`, `<base>` (distro/type), `<network>`.
   - Every module: `module_path` / `type`, and every `<input into="...">` it receives.
   - Every `<input into_datastore="X">` (producers) and every `<datastore>X</datastore>` / `access_json=...` reference (consumers). Note `read_fact="..."` selectors.
2. **Reconstruct the intended attack/learning chain** from `name`, `description`, `difficulty`, the CyBOK keywords, any **`<lab_sheet_url>`** (read it — for labs it's the real solution key), and the modules chosen. Write it out as ordered steps: where the student starts → each foothold/escalation → each flag or objective. The CyBOK blocks and comments often narrate the intended solution — use them. For teaching labs the chain may be short and linear (one credential step, one sudo read); that's fine.
3. Cross-check against the rules below, reasoning about *when* in the chain each value becomes available.
4. Report findings, severity-ordered.
5. **End by listing every module the scenario uses and recommending a `review-secgen-module` pass on each** (see final section).

## Rules to check

### S1 — Datastore wiring is consistent (producer → consumer)

For each datastore, confirm every consumer gets the value the producer made, and that the value is suitable where it lands. Remember datastores are **global to the scenario** (a datastore written in one `<system>` can be read in another — e.g. `spoiler_admin_pass` produced on the attack VM, consumed in the web server's cleanup) and that **writing concatenates** to the array rather than overwriting.

Trace each one end-to-end. In `feeling_blu.xml`, for example:

- `password` is generated once (`random_sanitised_word`, `min_length 6`) and fed into **three** places: the OS user account, bludit `known_password`, and the pre-leak `Creds:` string. They must all be the same value for the challenge to cohere — verify they all read the same datastore.
- `organisation`'s `['manager']['username']` is reused as the OS username, the bludit `known_username`, and part of the pre-leak. Consistent — good.

Flag any consumer reading a **different** value than the challenge logic assumes (the classic bug: two subtly different generators/datastores where the design needs one shared value).

### S2 — Every attack-enabling value is obtainable *before* it's needed

This is the scenario-level version of the module pre/post-leak reasoning, across modules. For each credential/secret the attacker must supply at some step, verify an **earlier** step in the chain hands it to them.

Watch for `access_json` mismatches that quietly break this. In `feeling_blu.xml` the zip file's password is `['manager']['name']` — the manager's **name**, which is *different* from `['manager']['username']` that was pre-leaked. So the review must ask: **where does the student learn the manager's name?**

**Do not answer this with a guess.** It is tempting to write "presumably from the website" and move on — that is exactly how a real break gets rubber-stamped. You must **locate the specific template/line that outputs the value AND confirm the containing page/resource is actually published and served.** For the zip password that meant verifying three things in the actual files: `templates/about.erb` renders `@manager_profile['name']`, `configure.pp` sets `$manager_profile` from the org datastore, and `pages.php.erb` marks the `about` page as a published static page (so it's public). Only after finding a concrete, served output do you conclude the value is obtainable; if you can't find one, it's a High-severity break (the zip is uncrackable). Same discipline for every attack-enabling value.

### S2b — Privilege/account transitions each have an enabling primitive

The chain usually hops between *accounts*, and each hop needs its own key that an earlier step must provide. Trace the transitions explicitly and, for each, name the credential or primitive that enables it and where the attacker obtains it.

**The transition shape is objective-defined — do not force it to `RCE → user → root`.** That is one common CTF shape, not a template every scenario must match. A hop may be:

- a **credential** obtained by cracking/guessing/leaking (e.g. brute-force an SSH password, then `ssh victim@target`);
- an **exploit** yielding RCE as a service account;
- a plain **account feature** — notably `super_user=true` in `parameterised_accounts`, which grants `ALL=(ALL) ALL` sudo, making `sudo cat /home/other/flag` the intended lateral/vertical step with **no exploit at all**. Treat `super_user`/ sudo grants as a first-class transition primitive.

The objective may also **not** be root — a lab's goal might be lateral read of a peer's file, or just obtaining one user shell. Don't hunt for a root step that the scenario never intended; anchor on the actual objective (from `lab_sheet_url` / description / flag placements).

**Zero-transition is a valid shape — don't manufacture a hop.** Many exploitation labs have **no account/credential transition at all**: the exploit *is* the only key, landing the attacker directly at the privilege that reads the flag (e.g. `easyftp_rce` → SYSTEM RCE; `unrealirc` backdoor → shell as `irc`). In that case S2b is trivially satisfied and there's nothing to trace. A `super_user=true` on an account here is **not** an attacker transition — it typically just makes the auto-logon console user an admin, an account the attacker never authenticates as. Only treat `super_user`/sudo as a transition primitive when the intended path actually authenticates as that account (as in `1_intro_linux`). Confirm which before reading anything into it.

In `feeling_blu.xml` the crux is easy to miss: the exploit yields RCE as `www-data`, but the **first flag is in the OS user's home** — so the attacker must pivot `www-data → maxie`. That hop works *only because* the pre-leaked bludit password is **reused as maxie's OS password** (the same `password` datastore feeds both), enabling `su maxie`. If those two had been different values, the box would be unsolvable despite every individual module being fine. This inter-account hop is the heart of a medium box — always ask "how does the attacker cross from the account the exploit gives them to the account holding the next objective?"

### S3 — Passed inputs match the target module's `read_fact`s

For each `<input into="NAME">` on a module, `NAME` should be a `read_fact` that module declares. An input a module doesn't read is silently ignored — a common cause of "I set it but it had no effect". This requires opening the module's `secgen_metadata.xml` (which is exactly what the module review does; at minimum spot-check the load-bearing inputs like `known_password`, `strings_to_pre_leak`). Conversely, note module inputs the scenario relies on but does **not** set, which then fall back to the module's `default_input` — confirm that default is acceptable for this challenge.

Two things a scenario review must not skip here:

- **Multi-valued inputs — confirm the module renders them all.** An `<input>` can supply several `<value>`/`<datastore>`/`<generator>` children, producing an array. In `feeling_blu.xml` `strings_to_pre_leak` has four elements (`Creds:` + username + password + flag). Whether all four actually surface depends on the consuming module iterating them — bludit's `pre_leak.erb` does `.each`, so they do; had it rendered `[0]`, the creds and flag would silently vanish with no error. When an input is multi-valued, open the consuming template/code and verify it emits **every** element, not just the first.
- **Overridden credential generators fit the *scenario's* objective — which is not always the module's headline attack.** A scenario input **overrides** the module's `default_input`, which can change the module's security properties. Two opposite cases, and you must decide which applies from the scenario's actual goal:

  - *Override that weakens/keeps attackable:* bludit defaults `known_password` to `weak_password_generator`; a scenario advertising bruteforce must keep it attackable — a strong override there **silently defeats** the intended attack (a real finding).
  - *Override that strengthens, and is correct:* a module may be **repurposed for a side effect** while its headline vuln is deliberately neutralised. In `1_intro_linux.xml`, `ssh_root_login` is included only to enable SSH + `PermitRootLogin yes`, and its `root_password` is overridden with `strong_password_generator` **on purpose** because the intended crack targets the `victim` account, not root. Flagging that as "a strong override defeats the attack" is a **false positive**.

  So: before flagging a strengthened credential, confirm what the scenario's objective actually is. An override that hardens a vector the challenge never intends the student to attack is correct, not a bug — the attackable target is elsewhere.

### S4 — Flags are generated, placed, and reachable in order

- **Expect flags — warn if there are none.** Almost every scenario, **including labs**, should hand the student one or more flags as proof of completing each objective. If there is no flag source at all, that is a finding (typically Medium): flag it and ask whether flags were intended and omitted. Only treat a flagless scenario as acceptable when its `type`/purpose genuinely doesn't call for them (a pure demo/build-only or infrastructure scenario) — and say so. **But "no `flag_generator` in the scenario XML" ≠ "no flags".** Flags can originate outside the scenario file:
  - inside a **generator module's `default_input`** (e.g. `hackerbot_config/*` defaults `flags` to several `flag_generator`s) — the scenario need not mint them. Trace the `flags` fact into the generator module before concluding there are none.
  - via a `flags`/`strings_to_leak` fact the scenario passes without the word `flag_generator` visible. So resolve the flag *source* (scenario XML **or** the module's default) before raising this.
- **Inventory every flag.** Enumerate each `flag_generator` invocation in the scenario (in `feeling_blu.xml` there are six, across four modules) and, for each, trace where it lands and confirm a student on the intended path actually reaches it. This inventory-vs-placement pass is the core of S4 — not the distinctness check below (which `flag_generator` satisfies automatically, since it mints a fresh value per call).
- **Labs have flags too — the flag usually originates at the *scenario* level.** The standard pattern (including in labs): a `flag_generator` is invoked directly in the scenario's own datastore/`<input>` block and fed into a module's `strings_to_leak` (commonly `parameterised_accounts`; sometimes a vulnerability/service module). So the flag value is minted in the scenario XML, not inside the module, and the load-bearing *placement* code lives in whichever module receives the `strings_to_leak`. Trace each `flag_generator` → the `strings_to_leak` it feeds → the module that leaks it. Don't expect the flag to live in the "vulnerability" module specifically, and when you recommend module reviews (final section) point at whichever module actually places the payload.
- **`parameterised_accounts` placement is platform-dependent — check the right code.** Its leak location and mode differ by platform: the **unix** module leaks to `/home/<user>/<filename>` at `0600` owned by the user; the **windows** module leaks to `C:/Users/<user>/Desktop/<filename>` at **`0444` (world-readable)**. So don't assume "home dir, 0600" — resolve the platform-correct module for the target VM (see S5b). A world-readable flag is not automatically a bug: when the only way onto the box is the exploit (e.g. SYSTEM RCE), Desktop `0444` is still gated behind exploitation.
- **Inventory flags per system — different VMs may use different placement.** A multi-target scenario can place one VM's flag via the utility and another's via the vuln/service module. `6_exploitation.xml` does exactly this: the Windows flag comes from windows `parameterised_accounts` (Desktop, 0444), the Linux flag from the `unrealirc` backdoor module (`/home/irc/flag`, 0600). Walk each `<system>` separately; don't stop after identifying the first mechanism.
- **Flags may have no pre/post-leak distinction — that's fine.** In a guided lab the flags are typically plain home-directory files (via `strings_to_leak`), read *after* the credential/sudo step, with progression enforced purely by **file ownership and permissions** (e.g. flag A owned by `victim 0600`, flag B owned by `bystander` reachable only via `sudo`). Here S4's job is: does ownership/permission gate each flag behind its step? Don't try to classify these as pre- or post-leak.
- **Distinguish a "flag" from breadcrumb content**, because a `flag_generator` can appear inside *either*. Some flags are the reward of a step; others sit inside a pre-leak/clue string. Reason about each oddball: e.g. `sudo_root_less` puts a flag in its `strings_to_pre_leak` at `/root` `0600` — that flag is only ever read *through* the privesc primitive, not before it, and that's correct. Classify by how the student obtains it, not by which fact carries it.
- Multiple flags form a sensible progression matching `difficulty` and the kill chain (e.g. web foothold as `www-data` → user → root via sudo → crack a protected zip in `/root`). Verify each flag's location is only reachable after the step that precedes it, and that no later-stage flag is exposed early.

### S5 — Systems, bases, and networks are coherent

- Every `<system>` has a `<base>` and the networks connect the attacker to the target(s). `IP_addresses` datastore is populated in the right order and consumed correctly (e.g. the attack VM's browser `start_page` pointing at the target).
- Base platform supports the modules: a module's `<requires>` (e.g. bludit needs apache- and php-compatible modules) must be satisfiable on the chosen base.
- `<conflict>`s among selected modules won't collide (e.g. only one `webapp` if a module conflicts on `type=webapp`).
- **Targets are findable and recognisable.** When a service is exposed on a **randomised port** (or otherwise not on its default), confirm the student can still *discover and identify* it by the recon the scenario expects — the attack VM's browser `start_page`/notes point at it, or a scan reveals what it is. A service whose only identifying signal (product name, vulnerable version) sits behind a method the student won't run (e.g. only in a web console's title, when bare `nmap -sV` shows a generic HTTP server) can leave them unable to recognise the target. This, and whether the service comes up in a realistic/valid state, is the module-level **R4c** check — apply it per exposed service and defer the fix detail to the module review.

### S5b — A `module_path` can resolve to different code per platform

Modules are selected by `module_path`/`type` regex, and the **same** selector can match **multiple** real module directories — SecGen then picks the one matching the target `<system>`'s base `platform`. `.*/parameterised_accounts`, for example, resolves to `modules/utilities/unix/system/parameterised_accounts` on a Linux VM and `modules/utilities/windows/system/parameterised_accounts` on a Windows VM — **different Puppet code with different behaviour** (see the S4 placement note). So:

- Don't assume a `module_path` maps 1:1 to one directory. For each place a module is used, resolve to the platform-correct directory for *that* system.
- When a scenario uses the same selector on VMs of different platforms, **review each platform's module** — they can differ in exactly the properties you care about (leak path, mode, service setup).

### S6 — Build/cleanup and spoilers

- **Every `<system>` must define a cleanup build that randomises the root password — this is required, not optional.** The canonical block is:

  ```xml
  <build type="cleanup">
    <input into="root_password">
      <datastore>spoiler_admin_pass</datastore>
    </input>
  </build>
  ```

  This is *the* mechanism by which SecGen randomises and then records each VM's root password (so the box doesn't ship with a known/default root password while the generated password is still remembered for the instructor). A `<system>` with **no** `build type="cleanup"` / `root_password` is a finding — flag it and name which system is missing it. Verify each system has one; don't assume the scenario applies it globally (it's per-`<system>`).
- **Confirm every `spoiler_*` datastore consumed in cleanup is actually produced by some system.** Because datastores are scenario-global, cleanup often reads a spoiler produced in a *different* `<system>` (in `feeling_blu.xml` both systems' cleanup consume `spoiler_admin_pass`, but it is generated only under `attack_vm`). That's fine — but a consumer with **no** producer anywhere yields an empty value and ships a box with a blank/known root password. Verify the producer exists; don't assume it because the consumer is present.
- Spoiler datastores (answer keys, admin passwords) are strong and not leaked to the attacker as part of the challenge.
- **The attacker/workstation VM legitimately has a known login and no flags.** A fixed `kali/kali` (or similar) account on the student's own box, and empty `strings_to_leak`/`leaked_filenames` for it, is intended — that's where the student *works from*, not a target. Don't flag its known credentials under this rule; the cleanup root reset still applies to it, but the interactive user is meant to be known.

### S7 — Metadata and discoverability (lower priority)

- `name`, `description`, `type`, `difficulty` present and honest about the chain. Note there may be **multiple `<type>` tags** (e.g. `ctf-lab` + `lab-sheet`) — all should be consistent with what the scenario is.
- CyBOK keywords match the actual skills exercised.
- `description` doesn't spoil the solution. For labs, a `<lab_sheet_url>` pointing to the guided worksheet is expected and normal.

### S8 — Hackerbot wiring (only for interactive-bot labs)

When the scenario uses a `hackerbot_config/*` generator + `hackerbot` server, the "is it solvable" question becomes "is the bot correctly wired to challenge, verify, and reward". The generator's logic is in `secgen_local/local.rb` and a `*_lab.xml.erb` template (not Puppet), so read those. Check:

- **Flag count matches reward sites.** The number of flags the generator produces (e.g. `REQUIRED_FLAGS` / a `while $flags.length < N` pad in the ERB) must equal the number of `<%= $flags.pop %>` reward sites across the `<attack>` conditions. A mismatch silently pads random flags or leaves an attack flagless — the single most important bot check.
- **Each `<attack>` is both winnable and losable.** Its `<post_command>` output must be matchable by exactly one `<condition>`/`<output_matches>` (or `output_not_matches`), the flag-releasing branch must be the *correct-defence* branch, and a wrong/insufficient defence must fall through to a non-reward condition. Watch condition **ordering** (a reject-over-hardening branch may need to fire first).
- **The bot can reach the target (key handshake).** A `hackerbot_key` datastore is produced once and consumed by **both** the `hackerbot` server (private key) and `hackerbot_client` on the desktop (authorized public key). The bot SSHing as root to the target is intended, not a finding.
- **IRC transport agrees.** `ircd` on the server + `pidgin` on the desktop pointed at the server IP + the bot's `server_ip` all refer to the same place.
- **Defended assets are placed.** The `strings_to_leak`/`leaked_filenames` the student must protect are actually created (mind subdirectory filenames like `trade_secrets/code.pl` — confirm the account leak creates parent dirs).

## Output format

Report severity-ordered findings, each with the concrete consequence for solvability. Then give the **end-to-end chain walkthrough**: numbered steps from the attacker's start to the final flag, and for each step state what the student must know/have and where the previous step provided it. End with a verdict: **is the scenario solvable exactly as intended, with every required value available before it's needed and every flag reachable in order?**

Severity guide:

- **High**: the chain is broken/unsolvable — a required value is never exposed before it's needed (S2), a datastore wired to the wrong value (S1), a flag unreachable or exposed out of order (S4), an input silently dropped because it isn't a `read_fact` (S3), or (bot labs) flag count ≠ reward sites / an `<attack>` with no reachable reward path or unreachable target (S8).
- **Medium**: no flags at all where the scenario should have them (S4), any `<system>` missing its required `build type="cleanup"` root-password reset (S6), a `spoiler_*` datastore consumed with no producer (S6), base/requires/conflict friction (S5), defaults relied on that may not suit the challenge (S3).
- **Low**: metadata/CyBOK/spoiler polish (S7).

## Then: review the modules this scenario uses

A scenario review is incomplete without checking the modules it composes, because flag *placement* and pre/post-leak reachability live in the module Puppet code. Finish by listing every module the scenario references (resolve each `module_path` / `type` to a concrete module directory — and per S5b, one selector may resolve to **more than one** directory across platforms; list each platform-correct module actually used) and recommend running the **`review-secgen-module`** skill on each, e.g. for `feeling_blu.xml`:

- Vulnerabilities: `bludit_upload_images_exec`, `sudo_root_less`, `zip_file`.
- Utilities: `parameterised_accounts`, `iceweasel`, `kali_top10`, `kali_web`.

Offer to run those module reviews next.
