---
name: write-secgen-ctf-description
description: Rewrite the <description> of a SecGen CTF scenario (scenarios/ctf/*.xml) into enticing, website-quality copy that hints at the vulnerability class and kill chain without spoiling the exact exploit/CVE/tool name. Use when asked to write, improve, or "make enticing" a CTF scenario's description, or to give it "a good hint of what to expect". Trigger words - "update the description", "write a description for this CTF", "make this scenario description enticing".
---

# Write a SecGen CTF scenario description

A scenario's `<description>` (inside the `<scenario>` root, right after `<author>`) is player-facing marketing/briefing copy shown on a website or challenge list. The bar is: **would this make someone want to attempt the challenge, and do they know roughly what they're walking into** — without the description doing the recon for them.

Bad (too short, uninformative, or literally spoils the answer):

- `Hack the web_server from kali.` — tells the player nothing.
- `Exploit CVE-2025-32433 (Erlang/OTP SSH pre-auth RCE) to get root.` — spoils the entire challenge; there's nothing left to discover.

Good — concrete enough to be exciting and orient the player, vague enough that finding the exact service/exploit is still the challenge:

> A server is running an outdated big-data analytics platform with its web UI exposed. A high-severity, unauthenticated command injection flaw lets you impersonate a user and trick the service into running your own shell commands - no credentials required. Scan the target, identify the vulnerable service and version, find a public exploit, and pop a shell to grab the first flag from a home directory. From there, a scheduled security audit job on the box is running an old rootkit-checker with a well-known local privilege escalation bug: drop a payload where it will be picked up and executed as root to complete the takeover.

(This is the actual description for `scenarios/ctf/catching_sparks.xml` — use it as the calibration example for length, tone, and how much to reveal.)

## How to research one scenario

1. **Read the scenario XML fully.** Note every `<system>` (each usually a stage — an attacker box plus one or more targets reached via foothold/lateral movement/privesc) and every `<vulnerability module_path="...">` / `<utility module_path="...">` it wires in.
2. **Resolve each `module_path`/`type` to its module directory** (e.g. `find modules -path "*apache_spark_rce*"`) and read that module's `secgen_metadata.xml`: `<description>`, `<type>`, `<difficulty>`, `<cve>`. This is where the real, spoiler-grade facts live — the scenario XML itself rarely says what the vulnerability actually is.
   - A `module_path` can resolve to **different code per platform** (e.g. unix vs windows `parameterised_accounts`) — resolve per `<system>`'s base, not once for the whole file.
1. **Find where the flags are** — look for `<generator type="flag_generator"/>` feeding a `strings_to_leak` input, and the surrounding inputs (e.g. `leaked_filenames`, `storage_directory`) to know roughly *where* each flag lands (a home directory, `/root`, inside a cracked archive, embedded in application data). This is what lets you write "grab the first flag from a home directory" instead of vague filler.
2. **Reconstruct the kill chain shape**: recon → foothold → flag → privesc → root/flag, possibly with extra side-quests (decode a pre-leaked clue, crack a password-protected archive, brute-force a login). CyBOK keyword blocks and XML comments in the scenario often narrate the intended chain — use them.
3. **Check CVE recency against today's actual date**, not the vulnerability's perceived novelty. Only describe a flaw as "recent"/"recently disclosed" if its `<cve>` year is genuinely within the last ~2 years of *today*. A CVE from 2018 or 2022 is not recent just because it sounds unfamiliar — for those, describe the vulnerability class neutrally with no recency claim.

## Writing rules

- **2–5 sentences.** Long enough to paint a picture, short enough to stay a teaser.
- **Name the service/target category, not the product+version**: "an outdated big-data analytics platform", "a lightweight, rarely-patched web server", "a small flat-file blogging platform" — not "Apache Spark 3.1.2" or "Bludit 3.13.1".
- **Name the vulnerability class, not the CVE**: "unauthenticated command injection", "a path-traversal bug in the image upload handler", "a permissive sudo rule around a text-processing tool" — never the literal `CVE-xxxx-xxxxx` string, exploit-db ID, or Metasploit module name.
- **Describe the technique, not the recipe.** "Track down a public exploit for this pre-authentication RCE" is fine; "run `msfconsole -> use exploit/linux/http/...`" is not.
- **State roughly where each flag lives** ("the first flag from a home directory", "a second flag hidden in the application's own data", "a flag waiting inside a password-protected archive in /root") — this is the single most enticing, least-spoiling kind of hint available.
- **Every system/stage gets a mention.** If the scenario is multi-stage (foothold → privesc, or two independent "escape" targets), the description should walk through the shape of the whole chain, not just the first step.
- **Cut dead weight.** Don't say "use kali to hack the server" — every scenario already runs from a Kali attack box; that's not a hint, it's noise.
- **Preserve non-spoiler information the player actually needs**, verbatim — a required login password stated in the original description (e.g. `Root_Cron-trol`'s "password: tiaspbiqe2r"), or credentials the challenge deliberately hands over up front (e.g. `Analyse This!`'s provided username/password, where the challenge is what you do *after* logging in, not getting in). Don't launder these away in the name of "no spoilers" — they were never meant to be secret.
- **Paired/variant scenarios must read as distinct.** Several scenarios come in pairs sharing one `<name>` or a "basic vs advanced/brute" relationship (`git_dejavu` / `git_dejavu_adv`, `rand_webapp` / `rand_webapp_adv`, `feeling_blu` / `feeling_blu_brute`). Check what actually differs in the XML (harder difficulty settings, less pre-leaked information, an older/stricter base) and write the harder variant's description to explicitly frame it as the tougher rematch — otherwise the two descriptions look like duplicates.

## Making the edit

- Only replace the text inside `<description>...</description>`. Don't touch any other tag, don't reformat surrounding XML.
- Match the file's **existing indentation style** — some scenario files use 2-space indent, some 4-space; look at sibling tags (`<type>`, `<author>`) in the same file rather than assuming.
- After editing, validate the file still parses: `python3 -c "import xml.dom.minidom as m; m.parse('scenarios/ctf/FILE.xml')"`.
- Confirm with `git diff` that the change is scoped to the description block only (no stray whitespace, no accidental edits elsewhere).

## Doing this across many scenarios

When asked to update a whole batch of scenario descriptions, this is embarrassingly parallel — each file's research and edit is independent. Split the file list into groups of ~5–6 and dispatch one `general-purpose` agent per group (running in the background so they proceed concurrently), giving each agent this skill's methodology inline in its prompt (file list, the research steps above, the writing rules, the calibration example, and the edit/validate mechanics) since a fresh agent won't have this skill loaded automatically. After all agents complete, `git diff` every changed file yourself to spot-check tone, spoiler discipline, and that paired scenarios actually read as distinct before reporting the work done.
