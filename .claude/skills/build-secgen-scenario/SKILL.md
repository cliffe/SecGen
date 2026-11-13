---
name: build-secgen-scenario
description: Author a SecGen scenario XML (scenarios/**/*.xml) from scratch - assemble a valid, resolvable scenario that selects modules, wires datastores, networks the systems and places reachable flags. Use when asked to write a scenario, build a scenario, create a scenario, make a new scenario, add a scenario under scenarios/..., turn a lab/CTF idea into scenario XML, or build a Hacktivity "hack box" or "hackbox" (a small practice CTF with a short kill chain and flags, briefed only by its description). The mechanical authoring counterpart to review-secgen-scenario (author then review). Trigger words - "write a scenario", "build a scenario", "create a scenario", "new scenario XML", "scenarios/tests/...", "hack box", "hackbox", "practice box", "practice CTF".
---

# Build a SecGen scenario

> **Paths** in this skill are relative to the SecGen repository root (or your
> worktree of it). If your session runs from a parent directory holding several
> repos, prefix them with the SecGen checkout, e.g. `SecGen/scripts/secgen-dev-run`.

This skill is mechanical: how to assemble a scenario XML that validates against
the XSD and resolves with `build-project` into a coherent, solvable challenge.
It does **not** cover writing the modules themselves (that is `secgen-puppet`)
or judging the finished result (that is `review-secgen-scenario`). Author here,
then review and test.

A scenario composes modules into one or more `<system>` VMs. Each system has a
`<base>` (the OS template) plus `<vulnerability>`, `<service>` and `<utility>`
modules, connected to each other through **datastores** (scenario-global
variables, each an array of strings) and `<generator>`/`<encoder>` blocks that
produce data at build time.

Read `README-Creating-Scenarios.md` and `README-Networking.md` for the
authoritative format. Keep a known-good scenario open while you work; the
minimal one is `scenarios/tests/test_scenario_proftpd.xml`.

## Before you start: decide the shape

Pin these down first, because every later choice follows from them:

- **How many systems**, and what each one is for (a single service box; a
  target plus a Kali attacker; several targets on one network).
- **The base** for each system (platform/distro/type).
- **The intended solve path** — the ordered steps a student takes from where
  they start to each flag (see the achievable-pathway checklist below). Write
  it out before you write XML; it tells you which modules and which datastore
  wiring you need.
- **Where the scenario file lives** (next section).

## Where scenario files live, and naming

Scenarios live under `scenarios/`, sorted by purpose:

- `scenarios/tests/` — small build/test scenarios. Names are descriptive, often
  `test_scenario_<thing>.xml` (e.g. `test_scenario_proftpd.xml`). Put a
  from-scratch exercise or a module smoke test here.
- `scenarios/ctf/` — attacker-vs-target challenges, `<name>.xml`
  (e.g. `feeling_blu.xml`). Hacktivity hack boxes live here too; see
  "Hack boxes" below.
- `scenarios/labs/<category>/` — teaching labs, usually `<n>_<slug>.xml`
  (e.g. `web_security/1_intro_web_security.xml`). The category directory
  matters; it pairs with the lab sheet's `categories`.
- `scenarios/examples/` — reference snippets, one feature each. Good to copy
  from, not where your new scenario belongs.

## The root element and the exact namespace

Every scenario starts with this header **exactly** — the namespace string is a
known trap:

```xml
<?xml version="1.0"?>

<scenario xmlns="http://www.github/cliffe/SecGen/scenario"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://www.github/cliffe/SecGen/scenario">
```

The namespace is `http://www.github/cliffe/SecGen/scenario` — note `www.github`
with **no** `.com`. A natural-looking `http://www.github.com/...` or
`https://...` URL is a different namespace and the scenario fails XSD validation
with no useful hint. Copy the header from a working scenario rather than typing
it.

Directly under `<scenario>` come the metadata elements, then one or more
`<system>` blocks:

- `<name>` and `<author>` — required-feeling in practice; every real scenario
  has them.
- `<description>` — prose shown to the user. For a CTF, hint at the chain
  without spoiling it (see `write-secgen-ctf-description`). For a lab, this is
  teaching prose and the real solution key is a `<lab_sheet_url>`.
- `<type>` — one or more: `test`, `ctf`, `attack-ctf`, `pwn-ctf`, `ctf-lab`,
  `lab-sheet`, `hackerbot-lab` … Use `test` for a throwaway build check.
- `<difficulty>`, `<CyBOK ...>` keyword blocks, `<lab_sheet_url>`, `<video>` —
  optional; labs carry CyBOK blocks and a sheet URL.

## `<system>` structure

```xml
<system>
  <system_name>web_server</system_name>
  <base platform="linux" distro="Debian 12" type="desktop" name="KDE"/>
  ...modules, inputs, networks, build...
</system>
```

- `<system_name>` is the only element inside `<system>` that is **not** a module
  selector. It names the VM; `<network_ip system="...">` and the IP map refer to
  it, so keep names stable and distinct.
- `<base>` selects the OS template by attribute **filters**, not a fixed path.
  Common attributes: `platform` (`linux`/`windows`), `distro` (`Debian 12`,
  `Kali`, …), `type` (`desktop`/`server`), `name` (a template variant such as
  `KDE`, `MSF`). Give enough attributes to pin the base you want; too few and
  SecGen randomly picks among matches. A Kali attacker box is
  `<base distro="Kali" name="MSF"/>`.
- **Module selectors** — `<vulnerability>`, `<service>`, `<utility>` — also
  filter. The precise way to pick a known module is `module_path=".*/<name>"`
  (a regexp, e.g. `module_path=".*/proftpd"`). You can instead filter on
  metadata attributes (`type`, `privilege`, `access`, `difficulty`, `cve`) and
  let SecGen choose; an empty `<vulnerability/>` picks any vulnerability. For a
  designed challenge, name the modules with `module_path` so the build is
  reproducible.
- **Multiple systems**: repeat the whole `<system>` block. Datastores are
  shared across all of them (a value produced in one system is readable in
  another), so a Kali box and its target coordinate through the scenario-global
  datastores.

## Datastores and generators

A datastore is a named array of strings, global to the scenario. **Writing
concatenates** to the array; it does not overwrite.

- **Produce** a value: `<input into_datastore="NAME"> ... </input>`, with
  literal `<value>`s, `<generator>`s and/or `<encoder>`s nested inside.
- **Consume** a value: `<datastore>NAME</datastore>` inside a module `<input>`,
  or `<datastore access="N">NAME</datastore>` for one array element by index, or
  `<datastore access_json="['a']['b']">NAME</datastore>` for a field of JSON
  content.

Generators you will reach for most:

- `account` — builds one account record (JSON) from `username`, `password`,
  `super_user`, `strings_to_leak`, `leaked_filenames`. Feed it into the
  `accounts` datastore (see Accounts below).
- `flag_generator` — mints a fresh random flag per call. This is how flags are
  created; it needs no inputs. (`module_path=".*base64"` plus `iterations`
  encodes the flag.)
- `strong_password_generator` — a strong random password. Use it for spoiler
  passwords and for credentials the challenge does **not** want cracked.
- `random_sanitised_word` (with a `wordlist` input, optional `min_length`) — a
  human-memorable word; use for a crackable/guessable password or a username.
- Message/filename/word generators and `line_selector`/structured-content
  encoders (e.g. selecting an organisation from
  `lib/resources/structured_content/organisations/json_organisations`) produce
  themed content. Browse `modules/generators/` and
  `modules/encoders/` for what exists before inventing a value.

Nest freely: a generator's output can feed another generator or an encoder, and
several children under one `<input>` concatenate into one array.

## Inputs must match the module's `read_fact`s

`<input into="NAME">` only has an effect if the target module declares `NAME` as
a `read_fact` in its `secgen_metadata.xml`. An input a module does not read is
**silently dropped** — the classic "I set it but nothing changed" bug. Before
wiring an input, check the module's metadata for the fact name (the
`review-secgen-module` skill does this; `secgen-puppet` explains how a module
reads facts). Where you omit an input, the module falls back to its
`default_input` — confirm that default suits your challenge (for example, don't
let a bruteforce target default to a strong password).

## Networking

Declare each NIC with `<network type="private_network"/>` inside the system.
With no inputs it auto-assigns an IP on **VLAN 1** from a randomly generated
private subnet. The key rule for an attack to work:

- **Attacker and target must share a subnet.** VMs on the **same `vlan`** land
  on the same subnet. The default `<network type="private_network"/>` on every
  system puts them all on VLAN 1 together, so exploit traffic flows. Only set an
  explicit `vlan` when you deliberately want separate segments (then matching
  `vlan` values share a subnet; different ones are isolated).
- **The `IP_addresses` datastore** records the VMs' addresses so modules can
  reference them. The name must be exactly `IP_addresses` (the
  `--network-ranges` CLI option overwrites it by that name). Populate it once,
  in order, with one `<network_ip system="..."/>` per system you need an address
  for:

  ```xml
  <input into_datastore="IP_addresses">
    <!-- 0 attack_vm -->
    <network_ip system="attack_vm"/>
    <!-- 1 web_server -->
    <network_ip system="web_server"/>
  </input>
  ```

  Then read an element by index, e.g. point the attacker's browser at the
  target: `<datastore access="1">IP_addresses</datastore>` into an `iceweasel`
  `start_page`. Index comments keep the order readable.
- `range` fixes the subnet, `IP_address` pins a static address (mutually
  exclusive). `public_network` is DHCP-only and cannot be referenced by
  `<network_ip>`. See `README-Networking.md`.

## Accounts

User accounts are added by the `parameterised_accounts` utility, selected with
`module_path=".*/parameterised_accounts"`. The selector resolves to the
platform-correct module for the system's base (unix vs windows — they place
leaked files differently). Feed it an `accounts` datastore built from `account`
generators (or inline JSON):

```xml
<input into_datastore="accounts">
  <generator type="account">
    <input into="username">
      <value>shepherd</value>
    </input>
    <input into="password">
      <generator type="strong_password_generator"/>
    </input>
    <input into="super_user">
      <value>false</value>
    </input>
    <input into="leaked_filenames">
      <value>flag.txt</value>
    </input>
    <input into="strings_to_leak">
      <generator type="flag_generator"/>
    </input>
  </generator>
</input>

<utility module_path=".*/parameterised_accounts">
  <input into="accounts">
    <datastore>accounts</datastore>
  </input>
</utility>
```

**Formatting.** Put each nested child on its own indented line, never inline:
write `<input into="x">`, the `<value>`/`<generator>`/`<encoder>`/`<datastore>`
child indented beneath it, then `</input>` — as above, and the same for every
nested element. Don't write `<input into="x"><value>asdf</value></input>`.

Notes:

- `super_user=true` grants `ALL=(ALL) ALL` sudo — a first-class privilege step
  (`sudo cat /home/other/flag`), not an exploit. Use it deliberately.
- `strings_to_leak` + `leaked_filenames` place a file in the account's home
  (unix: `/home/<user>/<filename>` at `0600`; windows: the Desktop at `0444`).
  This is the standard way to drop a flag a student reads after reaching the
  account.
- **A module may `require` an accounts utility.** `proftpd`, for example,
  declares `<requires><module_path>utilities/unix/system/.*/accounts</module_path></requires>`.
  If you add such a module, include a `parameterised_accounts` utility or
  `build-project` fails to resolve. The attacker/Kali box also needs an account
  (commonly the known `kali/kali` login as inline JSON).

## The required cleanup root-password reset (per system)

**Every `<system>` must end with a cleanup build that randomises the root
password.** This is not optional:

```xml
<input into_datastore="spoiler_admin_pass">
  <generator type="strong_password_generator"/>
</input>
<build type="cleanup">
  <input into="root_password">
    <datastore>spoiler_admin_pass</datastore>
  </input>
</build>
```

Why: it stops the VM shipping with a known or default root password, while
recording the generated password for the instructor (the "spoiler"). Produce
`spoiler_admin_pass` with a `strong_password_generator` once (any one system),
and because datastores are scenario-global every system's cleanup can read it.
A system with no cleanup block, or one whose cleanup reads a `spoiler_*`
datastore that nothing produces (yielding a blank password), is a defect — give
each system the block and make sure the producer exists.

## Achievable-pathway checklist (lightweight, manual)

Before validating, walk the intended solve path once by eye. The challenge must
be reachable, not just resolvable:

- **There is a remote entry point.** At least one remotely accessible
  service/vulnerability lets the attacker get their first foothold. A
  local-only privesc vulnerability on a box nobody can reach yet is dead weight
  until something remote lands first.
- **Each step's prerequisite is produced earlier.** Every credential, foothold
  or file a step needs is handed to the student by an earlier step or by the
  base (a leaked password, a crackable hash, a world-readable clue). Trace each
  one to where it comes from; a value never exposed before it is needed breaks
  the chain.
- **Account hops have a key.** If the path crosses from one account to another
  (e.g. `www-data` → a user → root), name the primitive for each hop — a reused
  password, a sudo grant, an exploit — and confirm an earlier step provides it.
- **Flags are reachable in order.** Each flag sits behind the step meant to
  reveal it (ownership/permissions, or gated by the exploit) and no later flag
  is exposed early. Every flag a student should earn has a `flag_generator`
  source somewhere (scenario XML or a module default).

This is an eyeball check of your own design. **Deeper, automated
reachability/kill-chain analysis is a future roadmap item, not part of this
mechanical skill** — for a thorough manual pass once the scenario is written,
run `review-secgen-scenario`.

## Validate cheaply — no VMs

The sanctioned loop before you ever build a VM (SecGen's "check cheaply" rule):

1. **XSD-validate** a single scenario file. Confirm the schema name in
   `lib/schemas/` (it is `scenario_schema.xsd`) and run:

   ```
   xmllint --noout --schema lib/schemas/scenario_schema.xsd scenarios/tests/<file>.xml
   ```

   `xmllint` prints `<file> validates` on success. To validate every scenario at
   once instead, `ruby lib/CyBOK/validate_xml_all_scenarios.rb`. A failure here
   is almost always the namespace trap above or a mistyped element.

2. **Resolve with `build-project`** — generates the project (Vagrantfile +
   Puppet) without creating any VM, catching unsatisfiable `requires`/`conflict`
   and unresolved modules:

   ```
   ruby secgen.rb -s scenarios/tests/<file>.xml build-project
   ```

   Do **not** pass `--read-options` / a `secgen.conf` path on the command line:
   it is unnecessary for `build-project` and is blocked here. A clean run prints
   the generated `projects/<id>` path.

   **From a git worktree**, gems resolve relative to the worktree, which has
   none, so the run fails with `Could not find nokogiri-…`. Prefix the command
   with `BUNDLE_PATH` pointing at the main checkout's bundle, e.g.:

   ```
   BUNDLE_PATH=/home/deploy/Code/SecGen/vendor/bundle ruby secgen.rb -s scenarios/tests/<file>.xml build-project
   ```

   (The main-checkout path is environment-specific; it is recorded in the
   workspace's local notes. From the main checkout itself no prefix is needed.)

3. Only once both pass is the scenario worth building on real VMs — that is the
   `secgen-test-pipeline` skill's job.

`build-project` writes a `projects/<id>/` directory (gitignored). Delete scratch
projects you no longer need to keep the tree tidy.

## A minimal single-VM template to copy

A complete, valid, resolvable single-service scenario — the smallest useful
starting point:

```xml
<?xml version="1.0"?>

<scenario xmlns="http://www.github/cliffe/SecGen/scenario"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://www.github/cliffe/SecGen/scenario">

  <name>Test: example service</name>
  <author>Your Name</author>
  <description>Minimal single-VM scenario deploying one service with an
  account that carries a flag.</description>

  <type>test</type>

  <system>
    <system_name>target</system_name>
    <base platform="linux" distro="Debian 12" type="desktop"/>

    <input into_datastore="IP_addresses">
      <network_ip system="target"/>
    </input>

    <input into_datastore="accounts">
      <generator type="account">
        <input into="username">
          <generator type="random_sanitised_word">
            <input into="wordlist">
              <value>mythical_creatures</value>
            </input>
          </generator>
        </input>
        <input into="password">
          <generator type="strong_password_generator"/>
        </input>
        <input into="super_user">
          <value>false</value>
        </input>
        <input into="leaked_filenames">
          <value>flag.txt</value>
        </input>
        <input into="strings_to_leak">
          <generator type="flag_generator"/>
        </input>
      </generator>
    </input>

    <utility module_path=".*/parameterised_accounts">
      <input into="accounts">
        <datastore>accounts</datastore>
      </input>
    </utility>

    <service module_path=".*/proftpd">
      <input into="port">
        <value>21</value>
      </input>
    </service>

    <network type="private_network"/>

    <input into_datastore="spoiler_admin_pass">
      <generator type="strong_password_generator"/>
    </input>
    <build type="cleanup">
      <input into="root_password">
        <datastore>spoiler_admin_pass</datastore>
      </input>
    </build>
  </system>

</scenario>
```

For a two-VM attacker/target shape, add a second `<system>` with
`<base distro="Kali" name="MSF"/>`, give it the known `kali/kali` account, list
both systems in the `IP_addresses` datastore, put both on the default
`private_network` (same VLAN 1 subnet), and point the attacker's browser/notes
at the target's IP. See `scenarios/labs/web_security/1_intro_web_security.xml`
and `scenarios/ctf/feeling_blu.xml` for worked multi-VM examples.

## Hack boxes (Hacktivity practice CTFs)

A hack box is a small `scenarios/ctf/` scenario that Hacktivity users play on
their own: a Kali attacker (or a desktop login), one target, a one- to
three-step kill chain with a flag per step, and no lab sheet, so the
description is the only brief. **When building or reviewing one, read
`references/hack-boxes.md`** (relative to this skill's directory). It covers
the three shapes the existing boxes use, copy-ready attacker and target
blocks, the Proxmox-capable bases, flag and pivot wiring, and a checklist of
the defects found in the first seven boxes (Debian 10 bases, hard-coded IPs,
leftover Hackerbot plumbing, weak extra accounts, difficulty/description
mismatches).

## Pair with these skills

- **`review-secgen-scenario`** — run it on what you just wrote: it checks the
  wiring, the kill chain and flag reachability in depth. This authoring skill
  and that review skill are counterparts.
- **`secgen-puppet`** — the module internals: how a module reads your inputs
  (`read_fact`/`get_parameters`), what it installs and leaks. Reach for it when
  you need a fact name or a module does not behave as its metadata suggests.
- **`review-secgen-module`** — check a module you depend on (that its
  `read_fact`s have defaults, that it leaks what you expect).
- **`secgen-test-pipeline`** — build the scenario on Proxmox and run each
  module's `secgen_test` over the guest agent, then clean up the VMs. Also how
  to add a `secgen_test` for a module that lacks one.
