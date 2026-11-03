---
name: secgen-test-pipeline
description: Test a SecGen module or scenario end-to-end on Proxmox using the agentic testing pipeline - build a VM, then run its secgen_test over the QEMU Guest Agent (no guest network needed, works after net0 teardown + reboot). Covers writing secgen_tests, the PostProvisionTest guest-agent transport, the build+test loop with secgen-dev-run/secgen-test-run, diagnosing failures via the agent, and cleaning up VMs. Use when asked to test/verify a module or scenario, write a secgen_test, run the pipeline, or debug why a built VM's service/exploit isn't working. Trigger words - "test this module", "run the pipeline", "secgen_test", "does it provision", "verify the service starts", "post-provision test".
---

# Test a SecGen module/scenario (Proxmox guest-agent pipeline)

> **Paths** in this skill are relative to the SecGen repository root (or your
> worktree of it). If your session runs from a parent directory holding several
> repos, prefix them with the SecGen checkout, e.g. `SecGen/scripts/secgen-dev-run`.

This is the automated-verification half of the agentic pipeline (statuses,
tiers and the results format are in `README-Testing.md`). It answers: *does this module actually provision,
and is the intended service/exploit really there on a freshly built VM?* — without
which agent-generated content can't be trusted.

The helper scripts are in `scripts/` (usage in `scripts/README.md`); run them as
`scripts/<name>` from the checkout/worktree you're working in. Host specifics
(Proxmox hosts, creds location, VLAN range) live in `CLAUDE.local.md`. This skill
is the mechanism and the workflow.

## How testing works

- Each module may ship `secgen_test/<name>.rb`, a subclass of `PostProvisionTest`
  (`lib/objects/post_provision_test.rb`), copied into every project at build time.
- On a **Proxmox** build the test reaches the VM through the **QEMU Guest Agent
  over the Proxmox REST API** — not `vagrant ssh`. This needs no network path into
  the guest, so it works after the provisioning NIC (net0) is torn down and the VM
  has rebooted onto its isolated static VLAN (the state that broke the legacy
  suite). The transport is in `lib/helpers/proxmox_connection.rb`
  (`exec_qemu_guest`, `qemu_agent_get_ip`, `qemu_agent_running?`).
- At build time `project_files_creator` writes `test_context.json`
  (url + user, **no password**) and copies the client into the project `lib/`.
  The test reads the password from `ENV['SECGEN_PROXMOX_PASS']` at run time, and
  the node/VMID from `.vagrant/machines/<system>/proxmox/id`.
- `PostProvisionTest.proxmox?` guards all of this; the Vagrant path is unchanged.

### Caveats that change how you write/read tests

- **Guest commands run as root.** For "as the intended user" checks use
  `run_as_user(user, cmd)` or pass `user:` to `test_local_command` /
  `test_command_succeeds` (wraps `runuser -u <user> -- bash -lc`, falling back
  to `su`).
- **The dev server can't reach the VMs' VLAN IPs directly.** So on Proxmox
  `test_service_up`, `test_banner`, `test_http` and `test_html_returned_content`
  all run **inside the guest** via the agent (port check with `ss`, HTTP with
  curl → wget → bash `/dev/tcp`, against 127.0.0.1 then the guest's own IP), not
  from the host. Remote/exploit-from-attacker tests must run **from a VM on the
  scenario VLAN** (e.g. a Kali box in the scenario), not from the host.
- **Each API call ~3s** from this dev server; batch guest checks into one
  command where you can rather than many round-trips. The system IP is only
  looked up (one `agent/network-get-interfaces` call) if something needs it.
- On Proxmox, `secgen.rb` runs the tests **after** net0 teardown and the
  reboot (see the loop below). Other providers keep the old in-build runner
  (vagrant halt/up, before any post-build).
- **A test is a standalone `ruby` subprocess.** `test_results.rb` runs each
  `secgen_test` as its own `bundle exec ruby <script>`; it does **not** load
  `constants.rb` or `Print`, so `ROOT_DIR`/`BASES_DIR`/`Print.std` are not
  available. Derive paths from the base class instead (`get_project_path`,
  `get_system_name`, `secgen_root`, `module_path`) and record via the check API
  (`pass_check`/`fail_check`/`skip_check`), not `puts`. **Reuse the base-class
  helpers** below rather than re-implementing guest exec, IP lookup or node/VMID
  parsing; if you need something new and reusable, add it to `PostProvisionTest`
  and have both the self and sibling cases share it.

## Writing a secgen_test

**What to assert is decided in the `write-module-secgen-tests` skill** — which
tiers a module gets, which helper proves what, and checking every `<read_fact>`
through `self.json_inputs` so the test holds for any parameterised deployment,
not just the defaults. Use it whenever you write or change a test; this section
is the quick reference for running and debugging one.

Subclass `PostProvisionTest`, set `module_name`/`module_path`, call `super`, then
assert in `test_module`. Every check is recorded with a **tier**:

1. **Provisioned** — the package/files/accounts exist (`test_local_command`,
   default tier 1).
2. **Service/tool works** — the service listens / answers / the tool runs from a
   terminal (`test_service_up`, `test_banner`, `test_http`,
   `test_command_succeeds`; default tier 2). For utilities actually invoke the
   binary, as the intended user, so PATH and missing-lib problems surface.
3. **Exploitable** — the intended vuln is actually exploitable with a real
   exploit (Metasploit or a crafted request) run **from an attacker VM** in the
   same project. See [Tier 3: exploit from an attacker VM](#tier-3-exploit-from-an-attacker-vm).

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
      test_service_up                                 # port from json_inputs
      test_banner('220 ', send: nil)                  # first bytes from the port
      test_http('/login.php', match: 'Sign in')       # status 2xx/3xx + body match
      test_command_succeeds('foo runs', 'foo --version', user: 'alice')
      # a value the module takes as an input: check it only if it was supplied
      if (motd = self.json_inputs['motd']&.first)
        test_local_command('motd applied', 'cat /etc/foo/motd', motd)
      end
    end
    # Tier 3: real exploit from an attacker VM (see below)
    test_msf_exploit('exploit/unix/misc/foo_rce', rport: self.port, tier: 3)
  end
end
FooTest.new.run
```

API (all in `lib/objects/post_provision_test.rb`):

| Helper | Passes when |
|---|---|
| `test_service_up(port: self.port)` | port is listening (SKIP if there's no port input) |
| `test_local_command(label, cmd, substr, user: nil)` | `substr` in stdout (add `2>&1` to match stderr, but then never match the program's own name: `x: command not found` would match; use `test_command_succeeds` for "x runs") |
| `test_command_succeeds(label, cmd, user: nil)` | exit status 0 |
| `test_banner(match, port:, send: nil)` | what the port sends (after `send` + CRLF) contains `match` |
| `test_http(path, match: nil, status: nil, port:, scheme: 'http')` | status matches (default 2xx/3xx) and body contains `match` |
| `test_html_returned_content(page, match, hide = false)` | legacy: body contains `match` |
| `pass_check` / `fail_check` / `skip_check(name, detail = nil, tier:, evidence:)` | record your own check |
| `skip!(reason)` | stop now, report SKIP (prerequisite missing) |
| `run_command(cmd)` / `run_as_user(user, cmd)` / `http_get(path)` | raw `{stdout, stderr, exit_status}` / `{status, body, error}` |
| `add_evidence(name, cmd)` | extra command whose output is saved if the test FAILs |
| `test_msf_exploit(module, rhost:, rport:, attacker:, payload:, collect:, force:, options:, sentinel_wait:, tier: 3)` | a Metasploit exploit run from the attacker VM gets RCE on the target (see below). `sentinel_wait: <s>` polls the sentinel for up to s seconds for deferred-execution exploits (default 0 = read once) |
| `test_http_exploit(path, method:, data:, headers:, expect:, expect_status:, sentinel:, include_headers:, collect:, tier: 3)` | a non-Metasploit web exploit run as HTTP request(s) from the attacker VM: PASSes when the response matches `expect` and/or a target-side `sentinel` proves command execution (see below) |
| `http_from_attacker(path, attacker:, rhost:, method:, data:, headers:, include_headers:)` | raw: one `curl` request from the attacker VM → `{status, body, error, curl}` |
| `test_smb_share_listed(share, comment:)` / `test_smb_anonymous_write(share, dir, expect_writable:)` | an anonymous `smbclient` from the attacker VM lists the share (with `comment`) / puts a file that lands in `dir` on the target (or is refused) |
| `test_smb_share_setting(share, param, value)` | the target's `testparm` gives `value` for that share parameter (defaults included) |
| `smbclient_from_attacker(attacker:, rhost:, share:, commands:)` / `samba_share_name` | raw: one anonymous `smbclient` from the attacker VM → `{stdout, exit_status, cmd}` / the `[share]` name and comment the samba module's `smb_share.conf.erb` renders (follows `organisation`) |
| `run_on_system(name, cmd)` / `other_system_ip(name)` | run a command on / get the IP of **another** VM in the project (Proxmox, over its own guest agent) |
| `system_present?(name)` / `attack_system` | a sibling VM by name exists / the sibling whose base is `<type>attack</type>` (nil if none) |

Every helper takes `tier:`; a `tier(n) { ... }` block sets it for the checks
inside. Legacy tests that push `"PASSED: ..."` / `"FAILED: ..."` onto `outputs`
and set `all_tests_passed` still work — those lines are recorded as checks.

### Tier 3: exploit from an attacker VM

A tier-3 check proves the vuln is really exploitable by attacking the target
**from another VM in the project** — network/exploit traffic has to come from
the scenario VLAN, not the SecGen host. Each sibling VM is reached over **its
own** QEMU Guest Agent (so this works after net0 teardown, like the rest).

**1. Put an attacker VM in the test scenario.** Add a second system on the same
private network as the target, built from a base of `<type>attack</type>`
(`<base distro="Kali" name="MSF"/>` — ships Metasploit). Give both systems
static IPs on one subnet/VLAN so the attacker can reach the target. Minimal
precedent: `scenarios/tests/test_scenario_distcc.xml` (Debian 12 target + Kali
attacker on `10.88.0.0/24`). The helper finds the attacker by base type, so the
system can be named anything; if there is no `type=attack` sibling, tier 3
SKIPs and the module still tests fine on its own.

**2. Use `test_msf_exploit`** for a Metasploit module (metadata often names it
in `<msf_module>`):

```ruby
test_msf_exploit('exploit/unix/misc/distcc_exec',
                 rport: 3632,                     # distcc has no port input; use self.port when the module has one
                 collect: 'cat /home/distccd/*',  # extra shell appended to the proof cmd (optional)
                 force: true,                     # set ForceExploit (see pitfall below; optional)
                 options: { 'LHOST' => '...' },   # extra/override msf datastore opts (optional)
                 tier: 3)
```

It resolves the attacker, SKIPs cleanly if there's none, runs `msfconsole -q -x`
on the attacker via `run_on_system`, and proves RCE by a **sentinel file** the
exploit drops on the target, which the target's own guest agent reads back and
checks for `uid=`. msf output and the sentinel are attached as evidence. It
defaults to the no-session `cmd/unix/generic` payload — the exploit runs a
command on the target directly, so there's no reverse/bind shell to race.
Pass `payload:` to override (e.g. a `cmd/<os>/http/...` command-stager "fetch"
payload — the helper then auto-sets `FETCH_SRVHOST` to the attacker), and
`force: true` to set `ForceExploit`.

**Gotchas (all handled by `test_msf_exploit`; mind them in any custom
attacker-side command):**

- **Export `HOME`.** The guest agent runs commands with no `HOME`, and
  `msfconsole`'s rb-readline aborts on startup without it — prefix
  `export HOME=/root TERM=dumb;`.
- **Avoid a reverse/bind shell for the assertion.** A session can open and close
  before you interact with it. Prefer a payload/command that executes on the
  target and leaves a durable artefact you verify out-of-band (the sentinel).
- **Don't assume a payload name — Metasploit changes module payload
  compatibility between versions, and a *global/auto default payload* can
  silently take over.** A `set PAYLOAD <name>` for a payload the current module
  no longer lists is rejected (`The value specified for PAYLOAD is not valid`);
  msf then keeps the *configured* default — on these dev Kali boxes that is a
  `cmd/linux/http/.../meterpreter_reverse_tcp`, which needs `LHOST` and aborts
  with `One or more options failed to validate: LHOST`. The exploit never fires
  and the sentinel is absent, so the test FAILs for a reason that has nothing to
  do with the target. This bit the `vsftpd_234_backdoor` tier-3 test: in the
  installed Metasploit that module has **no `cmd/unix/interact`** payload (the
  classic "just run it and you get a shell" default is gone) — its compatible
  set is huge but the no-session **`cmd/unix/generic`** (distcc's default) is in
  it and works with `force: true`. Diagnose by running `use <module>; show
  payloads` on the attacker (the list is long — grep it, don't eyeball the first
  screen) and confirm the name before wiring it into a test. Prefer the default
  `cmd/unix/generic` (arch-independent, no HTTP-fetch infrastructure).
- **Inconclusive automatic check.** Some modules can't self-verify the target
  (`Cannot reliably check exploitability ... set ForceExploit true to override`)
  and abort before exploiting. Pass `force: true` (the vsftpd backdoor needs
  this). This is distinct from a payload problem — read `msf_output` evidence to
  tell them apart (`LHOST`/`not valid` = payload; `Cannot reliably check` =
  AutoCheck).
- **AutoCheck says `not-vulnerable`? Suspect a patched bundled version first.**
  If `msf_output` shows the module's check returning *not-vulnerable* ("did not
  respond ... the expected response") while tiers 1-2 pass (the service serves
  fine), the app is usually a *patched* build, not a test bug. This bit `roxy_wi`
  (PR #264): the PR bundled `roxy-wi-master.zip` — the latest master, at/after
  the CVE-2022-31137 fix — so the injection sink was gone. **When authoring a
  vuln module's test, confirm the bundled artefact's version is inside the CVE's
  vulnerable range before building** (check a `VERSION` file / dated source), and
  say so in the test comments. A module that ships "master"/"latest" of its target
  is a red flag for a fixed vuln.
- **PHP-platform exploits that `eval()` the payload FAIL on PHP 8 (Debian 12).**
  Modules whose payload runs as `php -r eval(base64_decode(...))` (e.g.
  `gravcms_exec`, PR #263) die with `PHP Parse error: ... unexpected token "?",
  expecting end of file ... eval()'d code`: every msf php payload ends in a `?>`
  close tag, and PHP 8.0+ rejects a trailing `?>` inside `eval()` (PHP 7 tolerated
  it). The vuln is real and the job fires; only the payload won't parse. The only
  target-side fix is pointing `/usr/bin/php` at PHP 7 — a de-facto system
  downgrade that breaks every other PHP-8 module composed into the same VM, so
  don't. Treat tier 3 as a documented PHP-8 limitation (passes on a PHP<8 base or
  with a patched exploit); tiers 1-2 still prove the module. Also note the default
  `cmd/unix/generic` is rejected on a php-platform exploit — its twin is
  `php/unix/cmd/generic` (confirm with `show payloads`).
- **Deferred-execution exploits need `sentinel_wait:`, not a one-shot read.** If
  the exploit implants a cron/scheduler job that fires seconds later (rather than
  running the command inline), the sentinel is absent when msf returns. Pass
  `sentinel_wait: <seconds>` to `test_msf_exploit` to poll the sentinel every 5s
  up to that deadline (default 0 = read once, unchanged). AND make sure the module
  actually installs whatever runs the job — `gravcms_exec` implants a *Grav
  scheduler* job that only fires if a cron invokes `bin/grav scheduler`, so the
  module must ship that cron (via `/etc/cron.d`, since `cron` isn't a Puppet-core
  type on Debian 12).
- **Feasibility walls worth catching before a build.** Some WIP modules can't
  reach tier 3 on the Debian 12 base no matter the test: EOL container stacks
  (Rancher 1.x needs Docker ~17.x, but the vendored docker module installs latest
  Docker CE and Docker <20.10 can't run on bookworm's cgroup v2 — PR #262); apps
  pinned to PHP 7.x that won't run on PHP 8.2; heavy JVM stacks needing an old JDK
  or lots of RAM. Assess the target's runtime/version needs against the base
  *before* sinking time into repeated builds, and stop early (don't downgrade
  system libraries to force it; a module that mangles the base is a bad citizen in
  a randomly-composed `<vulnerability/>` scenario). A feasibility wall isn't always
  a runtime/version mismatch — a WIP module can be an **unfinished skeleton** that
  the cheap read-through catches before any build: none of its `<read_fact>`s are
  consumed by the Puppet, the app is never bootstrapped (no `composer install`, no
  `.env`/config, no DB migration, no admin account for an authenticated exploit),
  or the manifests reference a runtime version they never install (e.g. editing
  `/etc/php/7.3/...` while installing unversioned php = 8.2 on Debian 12). Confirm
  every read_fact is consumed and the app is actually configured, not just
  unpacked, as an early VM-free signal (ties into `review-secgen-module` R3/R8).

**For non-Metasploit exploits** (web vulns with no msf module), use the
`test_http_exploit` helper: it crafts the HTTP request(s) with `curl` **on the
attacker VM** (`http_from_attacker`) and asserts on the response body/header
(`expect:` / `include_headers:`) and/or a target-side `sentinel:` for command
injection — same attacker-VM / guest-agent shape, non-Metasploit path. Precedent:
`vuln_parameterised_website` (SQLi auth-bypass, `expect: /location:\s*index\.php/i`
on the 302). For anything more bespoke, run the attack directly with
`run_on_system(attack_system, '<curl ...>')` and assert with `run_command`.

### Results and exit codes

`run` prints `PASSED:` / `FAILED:` / `SKIPPED:` lines, writes
`projects/<id>/test_results/<system>/<module>.json`
(`{module, module_path, system, backend, started_at, duration_s, status,
tier_reached, results: [{tier, name, status, detail, evidence?}]}`), and exits:

- `0` **PASS** — every check passed.
- `1` **FAIL** — a check failed. Evidence (failed units, `systemctl status
  *<module>*`, the boot journal, listening ports, processes, plus any
  `add_evidence`) is collected in one guest call into
  `test_results/<system>/evidence/<module>/`.
- `2` **SKIP** — could not test: no `SECGEN_PROXMOX_PASS`, guest agent not
  answering (waits `SECGEN_AGENT_WAIT`, default 60s), no IP when one was needed
  (DHCP on Vagrant), or the test itself raised. **A SKIP is never a pass** —
  usually a harness problem, not the module.

A breakage Puppet itself notices (e.g. the service fails to (re)start during
provisioning) is a **build** failure, not a test FAIL: no tests run, the build
is retried and then destroyed; read `build.log`. A test FAIL means Puppet was
happy but the check wasn't (e.g. proftpd up on the wrong port), and the
evidence usually shows why (`listening_ports.txt` showed it on 2121).

`tier_reached` is the highest tier whose checks (and every lower tier's) all
passed. The format is the results contract in `README-Testing.md`.

## The build + test loop

### One shot (preferred): `test-scenario` / `test-module`

`scripts/secgen-dev-run --test -s scenarios/tests/<scn>.xml` (or
`scripts/secgen-dev-run -m modules/<type>/.../<mod>` for a generated one-system
scenario holding just that module on `modules/bases/debian_bookworm_desktop_kde`;
`-- --test-base <name>` picks another base from `modules/bases/`) runs
`secgen.rb test-scenario` / `test-module`. The test-module scenario is built by
`lib/test/module_test_scenario.rb` and regenerated on every run. If the module's
`secgen_metadata.xml` contains `<msf_module>exploit/...`, the generated scenario
automatically includes a `kali_light_msf` attacker system — no per-module
configuration needed; tier 3 uses the attack VM that is already there. If the
module declares a `<conflict>` with the chosen base, SecGen fails to resolve it
before any VM is built:

build (with `--retries 1`) → `net0` teardown → snapshot if `--snapshot` →
start (the one full reboot: static IPs up, reboot-dependent modules settle) →
wait for the guest agent (`SECGEN_AGENT_WAIT_BOOT`, default 600s) → settle
(`SECGEN_TEST_SETTLE`, default 30s) → every module's `secgen_test` (each with a
`SECGEN_TEST_TIMEOUT`, default 900s; `SECGEN_TEST_JOBS`, default 4, run side by
side) → `test_results/<project-id>/` →
destroy the VMs via the API and remove the project.

A build whose VMs outlive the tests (`run`/`build-vms`, `secgen-dev-run` without
`--test`, or `--keep-vms`) always takes the `original` snapshot after the `net0`
teardown, before the test boot. On PASS each VM is hard-stopped and rolled back
to it, so the tests leave no traces (throwaway users, MSF payloads and sessions,
logs, crashed services); the snapshot is then deleted unless `--snapshot` asked
for it, and the VMs are started again only with `--proxmox-post-boot` (or
`--keep-vms`). `summary.json` records this under `revert`; a VM that can't be
rolled back turns the run into a FAIL and is destroyed like any other failure.
A FAIL/SKIP is never rolled back: the VMs keep the evidence.

- **Exit code:** 0 all PASS, 1 any FAIL (or the build failed), 2 any SKIP.
- **Results** (gitignored, survive teardown): `test_results/<project-id>/`
  holds `summary.json` (build status/attempts, counts, per-system modules with
  status and `tier_reached`, SecGen commit/branch, `masked_secrets`),
  `scenario.xml` (the resolved scenario: what was actually tested),
  `build.log`, and `<system>/<mod>.json`, `<mod>.log`, `evidence/<mod>/`.
  Every copied file has the Proxmox password masked; `masked_secrets` > 0
  means something leaked it and should be fixed at source.
- `-- --keep-vms` keeps the VMs and project for debugging (even on PASS);
  `-- --no-destroy-on-failure` keeps them only if the build fails or the
  tests don't PASS. Destroy them afterwards with
  `scripts/secgen-dev-destroy projects/<id>`.
- A plain `secgen.rb run` on Proxmox without `--no-tests` uses the same
  order and writes the same report. On PASS it shuts the VMs down unless
  `--proxmox-post-boot`; on a **FAIL or SKIP it destroys them** (the project
  dir and results stay) unless `--no-destroy-on-failure`, and never retries,
  because batches treat surviving VMs as good builds (they get pulled into
  Hacktivity) and a SKIP is unverified. It exits 1/2 on FAIL/SKIP. The other
  providers' in-build runner does the same now (so on VirtualBox a system
  whose network test SKIPs, e.g. DHCP, is destroyed).

### A build that never finishes

`vagrant up` can hang indefinitely: blocked in `poll()` on an ESTABLISHED SSH
connection to a guest that has gone (rebooted onto its VLAN, torn down or
destroyed) without the connection closing. SecGen runs vagrant under a PTY in
its own session, and its 30-minute command timeout kills only the process it
spawned, so the Ruby `vagrant` child can outlive `secgen.rb`, the build and
even the project directory. Signs:

- the build log has stopped growing while `secgen-dev-run` is still running;
- `ss -tnp | grep ruby` shows connections to `172.33.x.x:22` for a guest that
  `scripts/pve-check --list` no longer lists, or that refuses a fresh
  `nc -z <ip> 22`;
- `readlink /proc/<vagrant pid>/cwd` ends in `(deleted)`.

Kill the `vagrant up` process group (`kill -- -<pgid>`, from
`ps -o pgid= -p <pid>`) and the build's own group, then destroy the project's
VMs with `scripts/secgen-dev-destroy projects/<id>`. Look the PIDs up first:
`pkill -f` with a pattern from your own command line kills your shell. A
pipeline that drives many builds should watch each build for output and
connection traffic rather than relying on a fixed timer; a rebuild after an
error can legitimately take a long time.

### Step by step (to iterate on one VM)

1. Make a minimal test scenario in `scenarios/tests/` (one `<system>`, the module,
   a `parameterised_accounts` user if required, a `<network>`, and the **required**
   `build type="cleanup"` root-password reset). Pick a base whose Proxmox template
   exists (`scripts/pve-check`). Debian 12 provisions reliably. See the
   `review-secgen-scenario` skill for scenario rules.
2. Validate + resolve cheaply first (see CLAUDE.md "Check cheaply"): XSD validate,
   then `build-project` (no VMs).
3. Build: `scripts/secgen-dev-run -p <name> -s scenarios/tests/<scn>.xml`
   (`--dry-run` first). It runs the tests after net0 teardown + reboot and
   writes `test_results/<id>/`, but leaves the VM running whatever the result
   (on PASS, rolled back to its pre-test snapshot; on FAIL/SKIP, as the tests left it) (`-- --no-tests` to skip them). It passes `--retries 1` (`SECGEN_RETRIES`) to absorb the
   intermittent provisioning-net flake (no DHCP lease → vagrant times out
   "waiting for SSH to configure network interfaces" with no Puppet run); when
   vagrant can't say which VM failed, SecGen now destroys all and retries.
4. Re-run a test against the running VM (e.g. after changing the test): `scripts/secgen-test-run <project>/puppet/<system>/modules/<mod>/secgen_test/<mod>.rb`
   — expect `PASSED: ...` / exit 0 (1 FAIL, 2 SKIP). `scripts/secgen-test-run` injects
   `SECGEN_PROXMOX_PASS` from the config without printing it. The JSON result
   and any FAIL evidence land in `<project>/test_results/<system>/`.
5. **If it fails**, start from the collected evidence
   (`test_results/<system>/evidence/<mod>/`), then diagnose further via the guest agent (`scripts/agent-check <vmid>`, or a small
   script calling `exec_qemu_guest` for `systemctl status`, `journalctl`,
   config-syntax checks). A failing test on a genuinely broken module is the
   pipeline working — fix the **module template/manifest**, not the generated
   project, then rebuild.
6. **Clean up**: `scripts/secgen-dev-destroy projects/<id>`
   hard-stops and deletes the project's VMs via the API, checks they're gone,
   and removes the project dir (`--keep-dir` keeps it).
   Remove any scratch files/logs too. Verify no orphans with
   `scripts/pve-check --all | grep <vmid>`.

## Worked precedent

`scenarios/tests/test_scenario_proftpd.xml` caught a real regression: proftpd
wouldn't start on Debian 12 (`fatal: unknown configuration directive 'IdentLookups'`
— removed in modern ProFTPD). The test reported `FAILED: Port 21 is closed`; after
dropping the stale directive from the module template it reported
`PASSED: Port 21 is open`. That is the detect → fix → re-verify loop this skill is for.

For a **tier-3** precedent, `scenarios/tests/test_scenario_distcc.xml` +
`modules/vulnerabilities/unix/misc/distcc_exec/secgen_test/distcc_exec.rb`: a
Kali attacker runs `exploit/unix/misc/distcc_exec` against the Debian target and
the test PASSes tier 3 on the sentinel it drops (`uid=119(distccd)`). It is a
4-line `test_msf_exploit` call on top of the framework.

## Then

Recommend `review-secgen-module` on the module and `review-secgen-scenario` on the
test scenario — static review and live testing are complementary.
