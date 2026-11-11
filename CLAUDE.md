# SecGen

SecGen builds randomised vulnerable VMs. Scenarios (`scenarios/**/*.xml`) select
modules, SecGen resolves them into a project (`projects/<prefix>_<timestamp>/`:
Vagrantfile + Puppet), then Vagrant builds the VMs (VirtualBox, oVirt or Proxmox).

## Repo map

- `secgen.rb` — CLI entry point (`ruby secgen.rb --help`). Commands: `run`/`r`,
  `build-project`/`p`, `build-vms`/`v`, `test-scenario`, `test-module`, `list-scenarios`,
  `proxmox-post-build`.
- `lib/` — readers, objects (`lib/objects/post_provision_test.rb` is the test base
  class), output generators, `lib/helpers/proxmox*.rb`, XSD schemas in `lib/schemas/`,
  Vagrantfile template in `lib/templates/Vagrantfile.erb`.
- `modules/{bases,networks,vulnerabilities,services,utilities,build}` — configure VMs.
  `modules/{generators,encoders}` — run locally at build time to produce data.
- `scenarios/` — `ctf/`, `labs/`, `examples/`, `tests/`, `dev/` …
- `projects/` — generated output (gitignored). Never edit; regenerate instead.
- `README-*.md` — longer docs (Modules-Metadata, Modules-Puppet, Creating-Scenarios, Networking,
  Testing: tiers, statuses and the `test_results/` contract).

## Module anatomy

```
modules/<type>/<platform>/<category>/<name>/
  secgen_metadata.xml    # what it is, inputs (read_fact/default_input), requires/conflicts, CyBOK
  <name>.pp              # entry manifest: includes the manifests below
  manifests/{install,config,service}.pp
  files/ templates/      # bundled files and ERB templates
  secgen_test/<name>.rb  # post-provision test (subclass of PostProvisionTest)
```

## Hard rules

- **Secrets.** Never put credentials on a command line. Never read, cat, grep or
  print `secgen.conf` or other SecGen config files holding credentials, `projects/*/Vagrantfile` (contains
  the Proxmox password), or git remote URLs. If you need a value from them, ask.
- **Git.** Ask before `reset --hard`, rebase, or renaming/deleting branches. Never
  push to `master`. Do work in a worktree / feature branch. Several agents may be
  working in parallel — never use bare `git stash`.
- **VMs.** Only stop/destroy VMs you created in this session. Never modify Proxmox
  templates.
- **Dependencies.** Don't add gems or other external dependencies without asking.
- **Generated code.** Fix the template/module, not the generated project.
- **Reuse, don't re-roll.** Before adding a helper, check what SecGen already
  provides. Paths/dirs are constants in `lib/helpers/constants.rb` (`ROOT_DIR`,
  `PROJECTS_DIR`, `MODULES_DIR`, `BASES_DIR`, the `*_SCHEMA_FILE`s …); output
  goes through `Print` (`lib/helpers/print.rb`); Proxmox calls go through
  `lib/helpers/proxmox_connection.rb`. **Exception:** a `secgen_test` runs as a
  standalone `ruby` subprocess that doesn't load `constants.rb`/`Print`, so it
  must self-derive paths (via `PostProvisionTest`'s `get_project_path` /
  `secgen_root` …) and use its own check/record API — don't reach for `ROOT_DIR`
  there. When you do add something reusable, put it on the base class and have
  the specific case call it (see `PostProvisionTest`).

## Check cheaply before building VMs

1. `ruby lib/CyBOK/validate_xml_all_modules.rb` / `validate_xml_all_scenarios.rb` —
   XSD validation.
2. `ruby secgen.rb -s <scenario.xml> build-project` — resolves modules and generates
   the project without creating VMs; catches unsatisfiable requires/conflicts and
   missing inputs.
3. Only then build VMs. VM builds are slow (often 10–40 min) and use shared hardware.

## Testing modules/scenarios (the pipeline)

Modules can ship `secgen_test/<name>.rb` (a `PostProvisionTest` subclass). On a
**Proxmox** build these run over the **QEMU Guest Agent via the Proxmox REST API**
(`lib/helpers/proxmox_connection.rb`), which needs no network path into the guest —
so tests work after the provisioning NIC is torn down and the VM has rebooted onto
its isolated VLAN (the state that broke the legacy suite). At build time the project
gets a `test_context.json` (url + user, **no password**; that comes from
`ENV['SECGEN_PROXMOX_PASS']` at test time) and a copy of the client. How to write
a `secgen_test` (tiers, and checking every read_fact through `json_inputs` so it
holds for any parameterised deployment) is in the **`write-module-secgen-tests`**
skill; the build→provision→test→fix loop and cleanup are in the
**`secgen-test-pipeline`** skill. Helpers live in `scripts/` (see
`scripts/README.md`): `scripts/secgen-dev-run` (build), `scripts/secgen-test-run` (run one
`secgen_test`), `scripts/pve-check`, `scripts/agent-check`; delete a kept project's VMs with
`scripts/secgen-dev-destroy projects/<id>` (`secgen.rb destroy-project`, given the options file by path). Run them by that path from
the checkout/worktree you're working in — they build that checkout and find the gems
themselves. A failing test on a genuinely broken
module is the pipeline working — fix the module template, not the generated project.

## Skills

Use the matching skill in `.claude/skills/` rather than working from memory:

| Task | Skill |
|---|---|
| Review a module (metadata ↔ Puppet consistency) | `review-secgen-module` |
| Author a scenario XML from scratch (valid, resolvable) | `build-secgen-scenario` |
| Review a scenario (wiring, solvable kill chain) | `review-secgen-scenario` |
| Write or fix a module's `secgen_test`: what each tier asserts, checking every read_fact via `json_inputs` | `write-module-secgen-tests` |
| Build and run a module/scenario's tests on Proxmox; diagnose failures | `secgen-test-pipeline` |
| Hackerbot labs / `hackerbot_config` generators | `secgen-hackerbot` |
| CTF scenario descriptions | `write-secgen-ctf-description` |
| Create or modify a randomised MetaCTF reverse engineering challenge | `create-metactf-challenge` |
| Write/debug module Puppet code | `secgen-puppet` |

When you add or rename a skill (by hand or with `skill-creator`), add a row
here in the same change, and to the skills table of any workspace you run
SecGen from. Skill paths (`scripts/…`, `lib/…`) are relative to the SecGen
root; say so at the top of a new skill, as the existing ones do.

## Environment-specific notes

Deployment details (hosts, users, creds locations) belong in a personal
`CLAUDE.local.md` (gitignored), not here.
