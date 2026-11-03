---
name: secgen-puppet
description: Write, modify, and debug the Puppet code inside SecGen modules (modules/{vulnerabilities,services,utilities}/**/<name>.pp and manifests/*.pp) - reading SecGen inputs with get_parameters, using the secgen_functions defines (create_directory, leak_files, leak_data, install_setgid_binary, ...), installing tools from packages / bundled files / pip / git, per-account config loops, and avoiding the known Puppet pitfalls on SecGen bases. Use when asked to add or change what a module installs, fix a module that fails during provisioning ("Could not set 'file' on ensure", "Duplicate declaration", "Invalid parameter", "Unable to locate package", "externally-managed-environment"), or when writing a new module's manifests. Trigger words - "puppet", "manifest", "install.pp", "secgen_functions", "ensure_packages", "the module fails to provision".
---

# SecGen Puppet

> **Paths** in this skill are relative to the SecGen repository root (or your
> worktree of it). If your session runs from a parent directory holding several
> repos, prefix them with the SecGen checkout, e.g. `SecGen/scripts/secgen-dev-run`.

How to write the Puppet side of a SecGen module so that it provisions cleanly on the current bases. This skill is about **authoring and debugging manifests**. For checking that `secgen_metadata.xml` and the manifests agree (read_facts, default_inputs, leaks reaching the attacker) use `review-secgen-module`; for cross-module wiring use `review-secgen-scenario`.

Everything below is derived from the current tree (~430 modules, ~1550 `.pp` files). Counts in brackets are "number of `.pp` files using this", to show what is idiomatic.

## How SecGen runs Puppet (know this before debugging)

- **Puppetfile per system** (`lib/templates/Puppetfile.erb`): contains only `secgen_functions` (from `modules/build/puppet/secgen_functions`), **the modules selected for that system**, and `puppetlabs-stdlib` from the Forge (latest compatible). librarian-puppet installs them into `projects/<proj>/puppet/<system>/modules/`.
  - Consequence: `puppet:///modules/<other_module>/...` and `include other_module::x` only work if `<other_module>` is also selected. Do not reach into another module's `files/`; vendor a copy (e.g. `reversing_tools/files/upx` is a copy of `coconut/files/upx`) or declare it in `<requires>`.
  - Third-party Puppet modules are themselves SecGen utilities pulled in via `<requires>`: `utilities/unix/puppet_module/{cron_legacy,cron_new,sudo,host,wordpress}`, `utilities/unix/system/accounts_newer` (the `accounts` module), Apache and MySQL (`<software_name>apache</software_name>` / `mysql`, which picks `services/unix/http/apache` or `database/mysql` on Debian and the `*_kali_compatible` ones on Kali), etc. stdlib is always there; `apt` and `translate` live in `modules/build/puppet/`.
- **One `vagrant provision "puppet"` run per module** (`lib/templates/Vagrantfile.erb`), in module selection order (`<requires>` deps come first; most modules require `<type>update</type>`, i.e. `unix_update` running `apt-get update`).
  - `manifests_path` = the module dir, `manifest_file` = **`<module_dir_name>.pp`**. That top-level file is the entry point, not `manifests/init.pp`.
  - Each module is a separate catalog: resource titles only need to be unique **within one module's run**, but within that run they must be unique even across defines (see `create_directory` below).
- **Inputs**: SecGen writes the module's `received_inputs` as base64 JSON to `secgen_functions/files/json_inputs/<module>_<random>` and passes the filename as the fact `base64_inputs_file`. That fact **only exists if the module received at least one input** - which is why every `<read_fact>` needs a `<default_input>`.
- **Puppet version varies by base** (old Debian/Kali boxes through Debian 12). Stick to syntax that works across them: `$::fact`/`$operatingsystemrelease` legacy facts [~140 files] are the norm, `$facts['x']` [43] also fine; avoid Puppet 6+-only functions and data types.
- The build VM has internet access at provision time (scenario `private_network` is the runtime network), so downloads/`git clone` work, but they are a reliability risk - prefer bundled files for anything that has disappeared upstream before.

## Module layout and entry point

```
modules/utilities/unix/audit_tools/reversing_tools/
  secgen_metadata.xml
  reversing_tools.pp        # entry point: include reversing_tools::install
  manifests/install.pp      # class reversing_tools::install { ... }
  manifests/config.pp       # optional: reads params, writes config, leaks
  manifests/service.pp      # optional: service { ... ensure => running }
  files/                    # served as puppet:///modules/reversing_tools/<file>
  templates/                # template('reversing_tools/foo.erb')
```

Entry point first lines across modules: `include X::install` [117], `require X::init` [21], `include X::config` [19], `require X::install` / `contain X::install` [6 each]. Manifest names: `install.pp` [165], `config.pp` [71], `init.pp` [64], `service.pp` [48]. Follow `install` -> `config` -> `service`; when config depends on install, use `require`/`->` rather than relying on include order.

## Naming and comments

**Name the module after its Metasploit module.** When the vuln (or service) has
an MSF module, the directory takes that module's own name, not a shortened one:
`exploit/linux/http/gravcms_exec` -> `.../webapp/gravcms_exec`, not `gravcms`.
Keep the metadata `<msf_module>`, the `secgen_test` class/filename, and the
scenario's `module_path` selector on that same name. The selector is matched
anchored (`^...$`), so `.*/gravcms` will **not** select `gravcms_exec` and the
scenario silently fails to resolve. With no MSF module, name it for what it is.

**Comment the code, not the lab.** A comment says what this manifest does and
why it does it that way — the repo a package comes from, why an `exec` is
guarded or ordered, a base-specific package quirk. Keep out:

- the scenario or vulnerability the module happens to serve. A `php7` utility
  installs PHP 7.4 for anything that wants it; it must not mention GravCMS, a
  CVE, or "the critical fix for the exploit". Describe the behaviour, not the
  caller — the same goes for a helper you add to `PostProvisionTest`.
- changelog and war-story prose: "NOTE (resolved): ... used to die before ...",
  residual-risk essays, "verified PASS on <date>". That history belongs in the
  commit message, not the source.
- anything that merely restates the line below it.

A class header is one or two lines on what the class installs or configures. If
a comment runs longer than the code it explains, cut it back.

## Reading SecGen inputs

```puppet
class mymodule::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)  # [170]
  $port             = $secgen_parameters['port'][0]           # scalars arrive as 1-element arrays [102]
  $strings_to_leak  = $secgen_parameters['strings_to_leak']   # lists stay arrays
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $enabled          = str2bool($secgen_parameters['enabled'][0])  # booleans arrive as strings
}
```

- **Every value is an array of strings.** Index `[0]` for scalars; `str2bool()` for "true"/"false".
- Structured values (accounts, `secgen_leaked_data`) are JSON strings: `parsejson($raw)` [48].
- Accounts loop (canonical, from `parameterised_accounts` / `kde_minimal`):
  ```puppet
  $accounts = $secgen_parameters['accounts']
  unless $accounts == undef {
    $accounts.each |$raw_account| {
      $account  = parsejson($raw_account)
      $username = $account['username']
      # per-user resources: titles MUST include $username to stay unique
    }
  }
  ```
- Guard optional inputs (`if $x { ... }` / `unless $x == undef`) - indexing `[0]` on a missing key gives `undef`, which then fails somewhere less obvious.
- A module with **no** `<read_fact>` must not call `get_parameters` (the fact is unset and `file()` fails). Install-only utilities like `reversing_tools` just don't read params.

## secgen_functions reference

Source: `modules/build/puppet/secgen_functions/` (the copy in `modules/code_examples/puppet_modules/secgen_functions/` is **not** used by builds). Call with the leading `::secgen_functions::`.

| Define / function | Use for | Key params | Gotchas |
|---|---|---|---|
| `get_parameters($::base64_inputs_file)` [170] | Read inputs | - | Fact only exists if the module has inputs. |
| `create_directory` [5] | `mkdir -p` a path whose parents may not exist | `path`, `res` (default `'create-dir'`) | Implemented as `exec "secgen_create_directory_$res"`: **pass a unique `res`** whenever it can be declared more than once in a run, or you get a Duplicate declaration. Runs `mkdir -p` every time; sets no owner/mode. Order the dependent file with `notify => File[...]` (or `before`). |
| `leak_files` [69] | Leak `strings_to_leak` into `leaked_filenames` in a dir | `storage_directory`, `leaked_filenames`, `strings_to_leak`, `leaked_from` (**required**, unique per caller), `owner`, `group`, `mode`, `images_to_leak` | Zips strings with filenames; extra strings are appended to the first file. Empty arrays = silently leaks nothing. Creates parent dirs itself (`mkdir -p` + chown). |
| `leak_file` [2] | Single file version | `leaked_filename`, `storage_directory`, `strings_to_leak`, ... | Appends via `file_line` if that path is already a `File`. Usually call `leak_files` instead. |
| `leak_data` [3] | Leak base64 `secgen_leaked_data` JSON blobs (binary files, subdirs) | `data_to_leak`, `storage_directory`, `owner/group/mode`, `leaked_from` | Fails if an element is not `secgen_leaked_data` JSON. Uses `create_directory` with unique `res`. |
| `install_setgid_binary` [6] | CTF: setgid binary + flag in `/home/<user>/<challenge>/` | `challenge_name`, `source_module_name`, `group`, `account` (parsed hash), `flag`, `flag_name`, `binary_path` | Without `binary_path` it calls `compile_binary_module` passing `gcc_params`, **which that define does not declare** -> "Invalid parameter gcc_params" (hit by `simple_bof`). Pass a precompiled `binary_path` (as `metactf` does) or fix the define. |
| `install_setuid_root_binary` [4] | CTF: compile module's `files/` with `make`, install 4755 root | `challenge_name`, `source_module_name`, `account`, `flag`, `flag_name` | Module `files/` must contain a Makefile producing `<challenge_name>`. Calls `create_directory` without `res` - only one per run. |
| `compile_binary_module` [3] | Copy module `files/` to a dir and run `make` | `source_module_name`, `binary_directory`, `challenge_name` | No `gcc_params` - put flags in the Makefile. |

## Installing software

**From the distro** (preferred when the package exists on every target base):
- `ensure_packages(['gdb', 'ltrace'])` [65] - safe to repeat across classes/defines; use it rather than `package {}` [173] for anything another class might also declare.
- Packages disappear between releases (e.g. `upx-ucl` is not in Debian 12, `ncat` split from `nmap` in Debian 10+). Kali rolling tracks Debian testing and drops packages without notice (`procyon-decompiler` removed 2026-04; `md5deep` transitional gone - install `hashdeep`, which ships the `md5deep` binary). When a module gains a Kali system, check every package at `https://pkg.kali.org/pkg/<source>`. Branch on release:
  ```puppet
  case $operatingsystemrelease {
    /^(1[0-9]).*/: { ensure_packages('ncat') }   # buster+
    default:       { }
  }
  ```
  Or `case $operatingsystem { 'Debian': {...} 'Kali': {...} }` (Kali is its own value).

**From a file bundled in the module** [83 use `puppet:///modules/`] - the fix when a package vanished or must be pinned:
```puppet
file { '/usr/local/bin/upx':        # /usr/local/bin always exists; no parent-dir problem
  ensure => file,
  source => 'puppet:///modules/reversing_tools/upx',
  mode   => '0755',
}
```
Large archives: copy or download into `/opt` or `/var/tmp`, then `exec` tar/unzip with `creates =>` the extracted path. **Not `/tmp` on Kali**: kali-rolling (like Debian 13) mounts `/tmp` as a RAM-backed tmpfs (half of RAM), so a few hundred MB fails with `curl: (23) Failure writing output to destination` / "No space left on device". The `ghidra` module's Kali branch is a worked example of a large build-time download (checksum, stall/resume handling, `timeout => 0`).

Upstream `.deb` (e.g. `reversing_tools` radare2): copy it with a `file`, then `package { 'x': provider => dpkg, source => '/opt/x.deb', require => File[...] }`. dpkg does **not** resolve dependencies - check the `.deb`'s `Depends:` and the highest `GLIBC_x.y` its binaries need against the oldest target base before bundling. Don't dpkg-install a package the distro also ships under the same name if another module may `apt install` it (use apt on that distro instead).

Adding a tool that only exists on newer bases to a module older scenarios still use: guard it rather than branching per-release forever:
```puppet
if $operatingsystem == 'Kali' or ($operatingsystem == 'Debian' and versioncmp($operatingsystemmajrelease, '12') >= 0) {
  ensure_packages(['python3-pwntools'])
}
```
Before changing a shared module, `grep -rl '<module_name>' scenarios` and note which bases those scenarios use. Keep licence files in `files/` for compliance; you don't have to deploy them.

**Downloads / git** [14 wget/curl, 5 git clone] - always idempotent and bounded:
```puppet
exec { 'clone theZoo':
  command => 'git clone https://github.com/cliffe/theZoo.git',
  cwd     => '/opt/',
  creates => '/opt/theZoo',
  path    => ['/usr/bin', '/usr/sbin'],
  timeout => 600,
}
```

**pip on Debian 12 / Kali** - system pip is blocked by PEP 668 (`externally-managed-environment`). Either a venv (preferred: `python3 -m venv /opt/<tool>` then `/opt/<tool>/bin/pip install ...` with `creates => '/opt/<tool>/bin/<entrypoint>'`, and symlink the entrypoint into `/usr/local/bin`), or `pip install --break-system-packages ...` (as `labtainers` does) when the tool must be importable from system python. Needs `ensure_packages(['python3-pip', 'python3-venv'])` first. Both `--break-system-packages` and `python3 -m venv` behave differently on older bases - branch on release if the module still supports them.

**exec hygiene** [196 files use exec]:
- Set a path once per class: `Exec { path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'] }` [64], or give absolute commands.
- Make every exec idempotent: `creates =>` [53], `unless =>` [40], `onlyif =>` [28], or `refreshonly => true` + `notify` [34].
- `provider => shell` [18] when you need pipes, `&&`, backticks or `source`.
- `timeout => 0` or a large value for builds/downloads (default is 300s); `logoutput => true` to see output in the provisioning log.

## Files and directories

- **Puppet does not create parent directories.** `file { '/a/b/c/x': ensure => file }` fails ("Could not set 'file' on ensure: No such file or directory") unless `/a/b/c` exists or is managed. Options:
  1. Install into a directory that always exists (`/usr/local/bin`, `/opt`, `/etc`, `/home/<user>` after the user exists).
  2. `::secgen_functions::create_directory { "create_$dir": res => "create_$dir", path => $dir, notify => File["$dir/x"] }`.
  3. Declare every level explicitly as an array (autorequire then orders them): `file { ["/home/$u/", "/home/$u/.config/", "/home/$u/.config/autostart/"]: ensure => directory, owner => $u, group => $u }` (from `kde_minimal`).
- Per-user files: set `owner`/`group` to the user and make sure the account exists first (`require` the account resource, or depend on `parameterised_accounts`/`accounts` via `<requires>`).
- Templates: `content => template('<module>/<file>.erb')` [301] - variables in scope are available as `@var`.
- `file_line` [30] to append/replace a line in an existing config (e.g. `~/.gdbinit`, `/etc/ssh/sshd_config`).
- Use quoted string modes: `mode => '0755'`.

## Ordering and uniqueness

- `require =>` [383], `notify =>` [241], `before =>` [205], `->`/`~>` [133]. A `File` autorequires its managed parent directory and owner `User` - nothing else is automatic. `exec`s are **not** ordered after packages unless you say so.
- Every resource title in a run must be unique. Inside loops and defines, include the loop key / `$title` in titles. Use `ensure_resource('file', $dir, {...})` [43] or `ensure_packages` for things several callers may declare. `defined('class_name')` guards are used for optional shared services.
- `create_directory` without `res` declared twice in one run = Duplicate declaration of `Exec[secgen_create_directory_create-dir]`.

## Debugging a provisioning failure

1. Find the failing module in the Vagrant output: each run is labelled by `module_path_name` (path with `/` -> `_`).
2. Generated project: `projects/SecGen<timestamp>/puppet/<system>/modules/` holds the exact modules + `secgen_functions/files/json_inputs/<module>_*` (base64 JSON - decode it to see the inputs the module received).
3. Iterate without regenerating: `ruby secgen.rb --project projects/SecGen... build-vms` rebuilds VMs from an existing project, so you can edit the copied manifests under `projects/.../puppet/<system>/modules/` and retry (copy fixes back to `modules/` afterwards). On a running VM, `vagrant provision` from the project dir re-runs all module provisioners.
4. Syntax check locally if Puppet is installed: `puppet parser validate manifests/*.pp`.
5. Common messages:
   - `Could not set 'file' on ensure: No such file or directory` -> missing parent dir (see above).
   - `Duplicate declaration` -> non-unique title (loops, `create_directory` default `res`, two classes declaring the same `package`).
   - `Invalid parameter X` on a `secgen_functions::` define -> the define doesn't declare it (e.g. `gcc_params`).
   - `file()` error mentioning `secgen_functions/json_inputs/` (could not find any files) -> module received no inputs (`$::base64_inputs_file` unset) but calls `get_parameters`, or a `read_fact` lacks a `<default_input>`.
   - `Could not retrieve information from environment production source(s) puppet:///modules/<m>/<f>` -> file missing from `<m>/files/`, or `<m>` not selected for the system.
   - `Unable to locate package` -> package gone on this release; branch on `$operatingsystemrelease` or bundle it.
   - `externally-managed-environment` -> pip on Debian 12; use a venv.
   - HTTP on `/` returns 200 but the wrong content (e.g. Apache's default page instead of the app) even though files are installed correctly -> **vhost priority conflict** with the required Apache module. That dependency registers its own default vhost at `priority => '15'`; add `priority => '05'` (or any value below 15) to the module's `apache::vhost` so it takes precedence. See `gitlist_040` for the pattern.
   - `Unknown resource type: 'cron'` -> `cron` left Puppet core in 6+ (now puppetlabs-cron_core). On a Debian 12 base it isn't loaded. Either `<requires>` the `cron_new`/`cron_legacy` puppet_module utility, or - cleaner for a vuln module composed randomly as an unspecified `<vulnerability/>`, where a required cron variant could clash with another module's - drop a self-contained `/etc/cron.d/<job>` file (`ensure => file`, a `www-data`/user field in the line, trailing newline) and `ensure_packages(['cron'])`.
   - `Could not find class <name>` (e.g. after `include docker`) -> the manifest `include`s a foreign Puppet class whose utility isn't declared. A vuln/service module that uses another module's class must list it in `<requires>` (e.g. `utilities/unix/container/docker`), or the catalog won't compile. `build-project` catches this with zero VMs.

## Puppet Forge module dependency conflicts

**Symptom:** librarian-puppet fails with `Could not resolve the dependencies` before any VMs are created. The message names a module and a conflicting stdlib (or other dep) version, e.g. `puppetlabs-stdlib (>= 5.0.0, < 9.0.0) required by accounts_newer conflicts with puppetlabs-stdlib (>= 4.6.0 < 5.0.0) from ntp`.

**Do not widen the ceiling in `metadata.json`.** The Puppet code in the module was written against the older API. Widening the range lets librarian pick a newer, incompatible version and the failure shifts to `puppet apply` time — e.g. `Concat::Fragment has no parameter named 'ensure'`, `Unknown function: validate_string`, `params_lookup` not found. These are harder to diagnose and the fix is the same: the module needs replacing.

**Identify what kind of module it is:**

- **Bundled Puppet Forge module** — the directory contains `checksums.json`, `CHANGELOG.md`, and a `metadata.json` whose `"author"` field is a Forge username (e.g. `"puppetlabs"`, `"jfryman"`). This is a full Forge download vendored in-tree. Don't patch it: **upgrade it to a newer release of the same Forge module yourself.** This is a routine fix and needs no human sign-off.
  1. List the releases: `https://forgeapi.puppet.com/v3/releases?module=<author>-<name>&sort_by=release_date` (reached through the same proxy as librarian). Pick the newest release whose `metadata.json` dependencies overlap what the other bookworm modules require (e.g. stdlib `>= 5.0.0 < 9.0.0`) and whose Puppet requirement includes 7.
  2. Download its tarball (`https://forgeapi.puppet.com/v3/files/<author>-<name>-<version>.tar.gz`) to a temp directory outside the repo and unpack it there.
  3. Replace the vendored files with the release's, **keeping the SecGen files**: `secgen_metadata.xml`, the entry manifest `<dir_name>.pp`, `secgen_test/`, and anything else the Forge tarball doesn't contain (`git diff` after the swap shows them as deleted if you missed one).
  4. Check the SecGen entry manifest still matches the new release's classes and parameters (renamed or removed parameters are the usual break), and that every dependency in the new `metadata.json` is a module SecGen already bundles.
  5. Commit with the old and new versions in the message (e.g. `xinetd: upgrade bundled puppetlabs-xinetd 2.0.0 -> 3.4.0 (stdlib < 5 conflict)`), then let the build and test prove it.

  Escalate only if no release of that module supports current stdlib and Puppet 7, if the newer release needs a Forge dependency SecGen doesn't bundle, or if the only fix is switching to a different Forge module (another author or a fork). Print `ESCALATE: bundled Forge module cannot be upgraded in place — <module-dir> <current-version>: <why>`.

- **SecGen-authored module with its own `metadata.json`** — the module's Puppet code is ours but it declares a dependency ceiling that is now too low. Before touching the ceiling, check whether the module is intentionally for older bases only (e.g. it uses `example42-*` deps that never supported newer stdlib). If so, add a `<conflict>` to `secgen_metadata.xml` to exclude it from bookworm builds — this prevents `accounts_newer` (bookworm-only) from being co-built with it:
  ```xml
  <conflict>
    <module_path>.*bases/.*bookworm.*</module_path>
  </conflict>
  ```
  If the module genuinely should work on bookworm and the Puppet code is safe with the newer dep version (you have verified it doesn't use removed functions), widening is acceptable — but verify first.

Add to the debugging messages (§ above): `Could not resolve the dependencies` → dependency conflict; see this section.

## Checklist for a new/changed manifest

- [ ] Directory name follows the Metasploit module name where there is one; the metadata `<msf_module>`, the scenario `module_path` selector and the test agree on it.
- [ ] Comments describe what the code does, not the scenario/CVE it serves; no changelog or residual-risk prose; none merely restate the code.
- [ ] Entry point `<dir_name>.pp` includes the classes; class names are `<dir_name>::<file>`.
- [ ] Inputs read via `get_parameters` only if the module has `<read_fact>`s; scalars indexed `[0]`; optional inputs guarded.
- [ ] Every file's parent directory exists or is created first.
- [ ] Every `exec` is idempotent and has a path; long ones have `timeout`.
- [ ] Packages exist on every base the module claims to support (or are branched/bundled).
- [ ] No `puppet:///modules/<other>/` unless `<other>` is in `<requires>`.
- [ ] Titles unique within loops/defines; `create_directory` gets a unique `res`.
- [ ] Leaks use `leak_files` with a unique `leaked_from`; then run `review-secgen-module`.
- [ ] If the module requires Apache (`<software_name>apache</software_name>`), the `apache::vhost` has `priority => '05'` (prevents the dependency's own default vhost from taking precedence).
