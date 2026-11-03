---
name: write-module-secgen-tests
description: Write (author) the post-provision secgen_test that ships with a SecGen module - the modules/<type>/.../<name>/secgen_test/<name>.rb file, a subclass of PostProvisionTest, with checks at the right tiers (1 provisioned, 2 service/tool works, 3 exploitable - tier 3 only for vulnerability modules). Use when asked to "write a secgen_test", "add a test to this module", "give this module tier-2/tier-3 coverage", decide what to assert, pick the right helper, or fix a test that's wrongly written (not a broken module). Covers the file skeleton, the PostProvisionTest check API, what belongs in each tier, checking every read_fact through json_inputs so the test holds for any parameterised deployment (not just the defaults), the standalone-subprocess constraints, and authoring tier-3 attacker-VM checks. For building/running/diagnosing on Proxmox use secgen-test-pipeline instead; for the module's own Puppet/Ruby use secgen-puppet.
---

# Write a module's secgen_test

> **Paths** in this skill are relative to the SecGen repository root (or your
> worktree of it). If your session runs from a parent directory holding several
> repos, prefix them with the SecGen checkout, e.g.
> `SecGen/lib/objects/post_provision_test.rb`.

This skill is the **authoring** layer: it is about writing the test file that
ships inside a module and deciding what each check should prove. It is the
companion to **`secgen-test-pipeline`**, which is the **orchestration** layer —
building a VM, running the test over the Proxmox guest agent, reading results,
diagnosing failures and cleaning up. Write the test here; run it there. When a
check fails because the *module* is broken (not the test), fix the module with
**`secgen-puppet`**.

The base class, every helper and the canonical signatures are in
`lib/objects/post_provision_test.rb`. The results format, statuses and exit
codes are the contract in `README-Testing.md` — read it once; this skill does
not restate it in full.

## Where the test lives

A module may ship one test at:

```
modules/<type>/<platform>/<category>/<name>/secgen_test/<name>.rb
```

It is copied into every generated project at build time and run there. One test
file per module, named after the module, holding one `PostProvisionTest`
subclass.

## The three tiers — and who gets tier 3

Every check is recorded at a **tier** that says how much of the module it
proves. The tiers are cumulative: `tier_reached` is the highest tier whose
checks, and every lower tier's, all passed.

| Tier | Proves | Typical module |
|---|---|---|
| 1 | **Provisioned** — package/files/accounts exist | every module |
| 2 | **Service/tool works** — service listens and answers, or the tool runs from a terminal as the intended user | services, utilities, and vulnerabilities |
| 3 | **Exploitable** — the intended vuln is actually exploitable, proven from an attacker VM | **vulnerability modules only** |

**Not every module needs tier 3.** Only `modules/vulnerabilities/**` modules
have an exploit to demonstrate. A **service** or **utility** module has no
intended vulnerability, so it tops out at **tier 2**: prove it installed (tier
1) and that it works (tier 2), and stop. Adding a tier-3 check to a
non-vulnerability module is a mistake — there is nothing to exploit, and the
scenario will have no attacker VM, so the check would only ever SKIP.

Match the top tier to the module's job:

- **utility** (a tool on the box) → tier 1 + tier 2 (invoke the binary as the
  intended user; see below).
- **service** (something that listens) → tier 1 + tier 2 (port up, banner,
  HTTP).
- **vulnerability** → tier 1 + tier 2 + **tier 3** (the real exploit). If an
  exploit genuinely can't be automated yet, ship tiers 1–2 and leave a comment
  saying why tier 3 is absent.

## Skeleton

```ruby
require_relative '../../../../../lib/post_provision_test'

class FooTest < PostProvisionTest
  def initialize
    self.module_name = 'foo'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_local_command('installed?', 'which foo', '/usr/bin/foo') }
    tier(2) do
      test_service_up                              # port from the module's inputs
      test_banner('220 ')                          # first bytes the port sends
      test_http('/login.php', match: 'Sign in')    # 2xx/3xx + body match
      test_command_succeeds('foo runs', 'foo --version', user: 'alice')
    end
    # tier 3 only for a vulnerability module (needs an attacker VM in the scenario):
    # test_msf_exploit('exploit/unix/misc/foo_rce', rport: self.port, tier: 3)
  end
end

FooTest.new.run
```

`tier(n) { ... }` sets the tier for every check inside the block; every helper
also takes an explicit `tier:`. The `require_relative` is **always exactly five
`../`** — copy it verbatim. It resolves against the test's **copied** location in
the generated project (`<project>/puppet/<system>/modules/<mod>/secgen_test/`,
where SecGen puts a copy of the client in `<project>/lib/`), which is a fixed
depth, **not** the source module's path — so it does not change with the
module's category nesting. Don't recount it against the source tree; both
precedents below use the same five.

Keep the class name and `module_name` in step with the module's directory: a
renamed `gravcms` -> `gravcms_exec` module gets `GravcmsExecTest` and
`module_name = 'gravcms_exec'`, so the results file matches the module.

## Comments: the test, not the war story

Comment what a check proves and any non-obvious mechanics — why tier 3 polls for
the sentinel, why a payload override is needed. Leave out the history of how the
module came to work: a "PHP 8 NOTE (resolved): ... used to die ... verified PASS
on <date>" block is changelog prose that belongs in the commit message, not the
test. If you add a helper to `PostProvisionTest`, describe the class of case it
serves, not the lab that prompted it — `wait_for_sentinel` is for any
deferred-execution exploit (cron, at, a task scheduler), not "Grav's scheduler".

## The check API

All defined in `lib/objects/post_provision_test.rb`. Default tiers in brackets.

| Helper | Passes when |
|---|---|
| `test_local_command(label, cmd, substr, user: nil)` **[1]** | `substr` appears in stdout (add `2>&1` to match stderr, but then never match the program's own name: `x: command not found` would match; use `test_command_succeeds` for "x runs") |
| `test_service_up(port: self.port)` **[2]** | the port is listening (SKIP if the module has no port input) |
| `test_banner(match, port:, send: nil)` **[2]** | what the port sends (after optional `send` + CRLF) contains `match` |
| `test_http(path, match: nil, status: nil, port:, scheme: 'http')` **[2]** | status matches (default 2xx/3xx) and body contains `match` |
| `test_command_succeeds(label, cmd, user: nil)` **[2]** | exit status is 0 |
| `test_html_returned_content(page, match, hide=false)` | legacy: body contains `match` |
| `test_msf_exploit(module, rhost:, rport: self.port, attacker:, payload:, collect:, force:, options:, tier: 3)` **[3]** | a Metasploit exploit from the attacker VM gets RCE on the target. Use `rport: self.port` (not a hardcoded number) so the test respects scenarios that override the port. |
| `test_http_exploit(path, method:, data:, headers:, expect:, expect_status:, sentinel:, include_headers:, collect:, tier: 3)` **[3]** | a crafted web exploit from the attacker VM matches `expect` and/or proves execution via a target-side `sentinel` |
| `test_smb_share_listed(share, comment:)` / `test_smb_anonymous_write(share, dir, expect_writable:)` **[2]** | an anonymous `smbclient` from the attacker VM lists the share / puts a file that lands in `dir` on the target (or is refused). Don't make a module install smbclient for its test; add `utilities/unix/smb/smbclient` to the attacker in the test scenario if the base lacks it |
| `test_smb_share_setting(share, param, value)` **[2]** | the target's `testparm` gives `value` for that share parameter (defaults included). `samba_share_name` returns the `[share]` name and comment the samba module renders, following `organisation` |
| `run_msf_module(module, rhost:, attacker:, options:, tier: 3, label:, timeout: 120)` **[3]** | run any MSF module (auxiliary/scanner/gather) on the attacker VM and return `{attacker:, attacker_ip:, rhost:, stdout:, stderr:, exit_status:, msf_output:}` (nil + SKIP if no attacker). Records no PASS/FAIL — the caller asserts on the output or a follow-up command. For non-RCE modules where `test_msf_exploit` doesn't apply. |
| `pass_check` / `fail_check` / `skip_check(name, detail=nil, tier:, evidence:)` | record your own result |
| `skip!(reason)` | stop now and report SKIP (a prerequisite is missing) |
| `add_evidence(name, cmd)` | register an extra command whose output is saved **if the test FAILs** |
| `run_command(cmd)` / `run_as_user(user, cmd)` / `http_get(path)` | raw `{stdout, stderr, exit_status}` / `{status, body, error}` |
| `run_on_system(name, cmd)` / `other_system_ip(name)` | run on / get the IP of **another** VM in the project |
| `system_present?(name)` / `attack_system` | a sibling VM exists / the sibling whose base is `<type>attack</type>` (nil if none) |
| `get_module_path(__FILE__)` / `get_project_path` / `get_system_name` / `secgen_root` | self-derive paths (see constraints) |

Legacy tests that push `"PASSED: ..."` / `"FAILED: ..."` onto `outputs` and set
`all_tests_passed` still work; those lines are recorded as checks. Write new
tests with the check API.

## Parameterisation-aware tests — use `json_inputs`, not hardcoded values

Every value that `secgen_metadata.xml` defines with `<read_fact>` or
`<default_input>` is resolved at build time and written into the generated
project. At test time, `self.json_inputs` holds those resolved values as a
hash keyed by the input name; each value is an array of strings (or absent if
the input was not present at all):

```ruby
self.json_inputs['port']         # => ["21"] or absent
self.json_inputs['dns_records']  # => ["ns1|A|192.0.2.1", "www|A|192.0.2.10"] or absent
self.json_inputs['banner']       # => ["Welcome to this server"] or absent
```

`self.port` is already derived from `json_inputs['port']` automatically — use
it everywhere, never write `test_service_up(port: 21)`.

**Rule: a test must be correct for any valid deployment of the module**, not
only the default. Hardcoding expected values restricts the test to one
specific deployment and silently gives wrong results for all others.

**Start from the inputs, before writing any assertion.** Open the module's
`secgen_metadata.xml` and list every `<read_fact>` and `<default_input>`. For
each one, decide:

- **Check it** if it changes something observable on the box: a port, banner,
  account or password, path or filename, hostname, DNS record, file or page
  content, a leaked string. Read the value from `json_inputs` and assert that
  the module really applied it (the config file holds it, the service answers
  with it, the account can log in with it).
- **Skip it** if it has no observable effect the test can see from the box, or
  belongs to another system: an on/off switch that only matters at boot or in
  a desktop session (`start_on_boot`, `autostart`), or the IP of a *different*
  system the module talks to (`server_ip`, `logstash_ip`). Leave a one-line
  comment in the test naming the inputs you skipped and why, so a reviewer can
  tell "considered and skipped" from "missed".

A read_fact that the module declares but the test never mentions is a gap in
the test. A test that asserts a literal value which is also the input's
`<default_input>` (port 21, banner `220 `, user `alice`) is the commonest form
of that gap: it passes on the default build and silently tests the wrong thing
on every other one.

**Check for the input before asserting on it.** If a parameter was not
supplied, `json_inputs['key']` is absent. Guard input-dependent checks:

```ruby
# custom banner: check for it if and only if one was supplied
if (banner = self.json_inputs['banner']&.first)
  tier(2) { test_banner(banner) }
end
```

**Assert against the actual resolved value, not a guess.**

```ruby
# for each configured DNS record, verify the resolver returns it
(self.json_inputs['dns_records'] || []).each do |record|
  hostname, type, ip = record.split('|')
  tier(2) { test_local_command("#{hostname} #{type} resolves", "dig +short @localhost #{hostname} #{type}", ip) }
end
```

**Multiple values.** Many inputs accept multiple values (e.g. multiple DNS
records, multiple usernames). The value is always an array — iterate it.
`&.first` is convenient for single-valued inputs.

**What to skip vs. what to always check.** Not every check depends on a
parameterisable value. Tier-1 checks (package present, binary on disk) are
structural and always apply. Tier-2 checks that verify *behaviour driven by a
specific input value* — a banner, a DNS record, a credential — are conditional
on that input being present.

## What to assert at each tier

**Tier 1 — provisioned.** Cheap existence checks. The binary is on disk
(`which`, `test -x`), the config file is present, the account exists. Use
`test_local_command` with a substring you expect in the output. Keep these
specific — `test -x /usr/local/sbin/vsftpd` beats `which vsftpd` if the module
builds from source to a custom path.

**Tier 2 — it works.** For a **service**, prove it answers, not just that the
port is open where you can: `test_service_up` for the port,
`test_banner`/`test_http` for a real response. For a **utility**, actually
**invoke the binary as the intended user** (`user:` / `run_as_user`) so PATH and
missing-shared-library problems surface — a tool that only `root` can run, or
that dies on a missing lib, passes a naive `which` but fails here, which is the
point.

**Tier 3 — exploitable (vulnerability modules).** See the next section.

## Standalone-subprocess constraints

A `secgen_test` runs as its own `bundle exec ruby <script>` and does **not**
load `constants.rb` or `Print`. So inside a test:

- `ROOT_DIR`, `BASES_DIR`, `Print.std` and friends are **not** available.
  Derive paths from the base class (`get_module_path(__FILE__)`,
  `get_project_path`, `get_system_name`, `secgen_root`).
- Record results through the check API (`pass_check`/`fail_check`/`skip_check`
  or the `test_*` helpers), **not** `puts` — stray prints are not recorded as
  checks.
- Guest commands run **as root**. For "as the intended user" use `run_as_user`
  or the `user:` argument (wraps `runuser`, falling back to `su`).
- Each guest round-trip costs ~3s on the dev server. Batch related checks into
  one command where you reasonably can rather than many small calls.
- Need a new reusable helper (guest exec, IP lookup, node/VMID parsing)? Add it
  to `PostProvisionTest` and have both the self and sibling cases share it —
  don't re-implement transport in a single test.

## Authoring a tier-3 check (vulnerability modules)

A tier-3 check attacks the target **from another VM in the project**, because
exploit traffic must come from the scenario VLAN, not the SecGen host. Two
things have to line up:

1. **The test scenario needs an attacker VM.** Add a second system built from a
   base of `<type>attack</type>` (`<base distro="Kali" name="MSF"/>` ships
   Metasploit), with both systems on one subnet so it can reach the target. The
   helpers find the attacker by base type, not name. **If there is no
   `type=attack` sibling, tier 3 SKIPs cleanly** and the lower tiers still run —
   so the same test works standalone and in a full scenario.
2. **The check itself:**
   - **Metasploit exploit** (metadata often names it in `<msf_module>`): use
     `test_msf_exploit`. It resolves the attacker, runs `msfconsole` on it, and
     proves RCE via a **sentinel file** the exploit drops on the target, which
     the target's own guest agent reads back and checks for `uid=`. It defaults
     to the no-session `cmd/unix/generic` payload (a command runs on the target
     directly — no reverse/bind shell to race). **For CmdStager modules, see
     below.**
   - **Web exploit with no msf module**: use `test_http_exploit` — it crafts the
     request(s) with `curl` on the attacker VM and asserts on the response
     (`expect:`) and/or a target-side `sentinel:` proving command injection.
   - **Anything more bespoke**: `run_on_system(attack_system, '<cmd>')` then
     assert with `run_command`.

**Rule: if a Metasploit module exists for the vulnerability, tier 3 must use
it.** For an **exploit** module (gives RCE), use `test_msf_exploit`. For an
**auxiliary/scanner/gather** module (no RCE — file read, traversal, info leak,
credential dump), use `run_msf_module` to run it on the attacker and then
assert on its output or on a follow-up command that proves the effect (see the
samba_symlink_traversal precedent below). A bespoke `curl`/HTTP exploit should
only appear when there is genuinely no MSF module. If an exploit module can't
be driven with `test_msf_exploit` after trying the correct payload type
(standard, fetch, or CmdStager — see below), do not reimplement the exploit in
test code. Instead, record a `skip_check` and leave a comment so a human can
resolve it later:

```ruby
# TODO: human needed — exploit/linux/http/example_rce uses CmdStager but
# LHOST routing from this VLAN needs manual verification before wiring in.
skip_check('msf exploit (exploit/linux/http/example_rce)',
           'CmdStager LHOST unresolved; cannot automate without manual check',
           tier: 3, evidence: nil)
```

**Assert the privilege level — it is driven by `<privilege>`.** `test_msf_exploit`
takes `expect_privilege:`, and `generate-t3-test` sets it automatically from the
module's `<privilege>`: `root_rwx` requires the exploited shell to be root or a
sudoer; `user_rwx` requires a non-root, non-sudoer shell (judged from the
sentinel's `id` and `sudo -n -l`). A plain `test_msf_exploit` passes on *any*
`uid=`, so without this a `user_rwx` module that actually lands root — or a
`root_rwx` one that lands a mere user — would pass wrongly. Keep `<privilege>`
honest with what the module gives, and if you hand-write a tier-3 (or a non-MSF
one) assert the same level yourself. A mismatch is a module bug to fix, never a
check to drop.

**CmdStager modules** use `execute_cmdstager` rather than `execute_command` (look
for `include Msf::Exploit::CmdStager` in the module source; `show info` in
msfconsole lists `Arch: x86, x64` and there is no `CMD` datastore option). They
require a **native Linux payload** (`linux/x64/exec`), not `cmd/unix/generic`
(wrong architecture) and not a fetch payload (different staging mechanism).
CmdStager builds a native ELF binary from the payload, serves it from a
transient HTTP server on the attacker at `LHOST`, and stages it to the target
via wget. The `CMD` option on `linux/x64/exec` is what gets executed — no
reverse shell, no handler.

Unlike fetch payloads, `test_msf_exploit` does **not** auto-set `LHOST` for
CmdStager. Resolve the attacker IP first, then pass it via `options:`:

```ruby
tier(3) do
  resolved = resolve_attacker('exploit/linux/http/example_cmdstager', nil, nil, 3)
  next unless resolved
  _, attacker_ip, _ = resolved
  test_msf_exploit('exploit/linux/http/example_cmdstager',
                   rport: TARGET_PORT,
                   payload: 'linux/x64/exec',
                   collect: 'cat /home/targetuser/*',
                   options: { 'LHOST' => attacker_ip },
                   sentinel_wait: 120)
end
```

Pass `sentinel_wait:` (seconds) when execution is asynchronous — a scheduler,
container manager or job queue runs the command a few seconds after submission.
For synchronous exploits, omit it (defaults to 0, reads the sentinel once).

**Metasploit gotchas** (all handled inside `test_msf_exploit`; mind them only in
a custom attacker-side command):

- **Export `HOME`** — the guest agent runs with none and `msfconsole`'s
  rb-readline aborts without it. Prefix `export HOME=/root TERM=dumb;`.
- **Don't assume a reverse/bind shell for the assertion** — a session can open
  and close before you interact with it. Prefer a command that runs on the
  target and leaves a durable artefact you verify out-of-band (the sentinel).
- **Don't assume a payload name** — Metasploit changes module payload
  compatibility between versions, and a global default payload can silently take
  over and demand `LHOST`. Diagnose with `use <module>; show payloads` on the
  attacker (grep the list) and confirm the name. Prefer the default
  `cmd/unix/generic`.
- **Inconclusive AutoCheck** (`Cannot reliably check exploitability ... set
  ForceExploit true`) — pass `force: true`. Distinct from a payload problem;
  read the `msf_output` evidence to tell them apart.

The orchestration side of tier 3 (building the attacker, running msf over the
agent, collecting evidence) lives in `secgen-test-pipeline`.

## Results, in brief

`run` prints `PASSED:`/`FAILED:`/`SKIPPED:` lines, writes the per-module JSON,
and exits **0** PASS / **1** FAIL / **2** SKIP. A SKIP is **never** a pass — it
means the test couldn't be carried out (no attacker VM for tier 3, no password,
guest agent down, or the test raised). The full layout and the JSON fields are
the results contract in `README-Testing.md`.

Note: a breakage Puppet catches during provisioning (a service that won't
start) is a **build** failure, not a test FAIL — no tests run. A test FAIL means
Puppet was happy but the check wasn't. Don't paper over a real build break with
a weaker test.

## Precedents to copy

- **Service, tiers 1–2:** `scenarios/tests/test_scenario_proftpd.xml` and
  `modules/services/unix/ftp/proftpd/secgen_test/proftpd.rb` — install check +
  `test_service_up` on port 21.
- **Vulnerability, tier 3 (Metasploit, `cmd/unix/generic`):**
  `modules/vulnerabilities/unix/misc/distcc_exec/secgen_test/distcc_exec.rb`
  with `scenarios/tests/test_scenario_distcc.xml` — a ~4-line `test_msf_exploit`
  on a Kali attacker, PASSing tier 3 on the `uid=119(distccd)` sentinel.
- **Vulnerability, tier 3 (Metasploit, CmdStager):**
  `modules/vulnerabilities/unix/http/hadoop_yarn_rce/secgen_test/hadoop_yarn_rce.rb`
  with `scenarios/tests/test_scenario_hadoop_yarn_rce.xml` — CmdStager exploit
  (`exploit/linux/http/hadoop_unauth_exec`) using `linux/x64/exec` with
  `LHOST` resolved before the call and `sentinel_wait: 120` for the deferred
  container execution.
- **Vulnerability, tier 3 (web, no msf):** `vuln_parameterised_website` — SQLi
  auth-bypass via `test_http_exploit` (`expect: /location:\s*index\.php/i`).
- **Vulnerability, tier 3 (MSF auxiliary, no RCE):**
  `modules/vulnerabilities/unix/smb/samba_symlink_traversal/secgen_test/samba_symlink_traversal.rb`
  with `scenarios/tests/vulnerabilities/unix/smb/samba_symlink_traversal/test_scenario_samba_symlink_traversal.xml`
  — `run_msf_module` drives the MSF auxiliary to plant a symlink, then
  `smbclient` on the attacker reads `/etc/passwd` through it to prove traversal.
  The pattern for any auxiliary/scanner/gather module that doesn't give RCE.

## Then

Run the test with **`secgen-test-pipeline`** (build → run over the guest agent →
read results → fix → re-verify). Static-review the module with
**`review-secgen-module`** — it checks that the metadata and Puppet agree, which
is complementary to what the test proves live.
