# SecGen helper scripts (Proxmox dev/test)

Small wrappers for building and testing on a Proxmox cluster. Run them by path
from the checkout or worktree you're working in (`scripts/secgen-dev-run ...`): each
script uses the checkout it lives in, so a worktree builds its own code. If that
checkout has no `vendor/bundle` but the main checkout does, the scripts point
bundler at the main checkout's gems.

| Script | What it does |
|---|---|
| `scripts/secgen-dev-run -s <scenario.xml> [-p name] [--dry-run] [-- extra secgen args]` | Proxmox build with prefix `<owner>-<name>-NN` (per-name counter) and the next VLAN in the range (shared counter). Runs the secgen_tests after net0 teardown + reboot and writes `test_results/<project_id>/`, but leaves the VM running whatever the result (rolled back to its pre-test snapshot on PASS, as the tests left it otherwise) (`--shutdown --proxmox-post-boot --no-destroy-on-failure`; `-- --no-tests` to skip the tests). Exits 0 PASS / 1 FAIL or build failed / 2 SKIP. Logs to `log/[ERROR_]<project_id>`. `--dry-run` shows the command and numbers without using them. Passes `--retries 1` (`SECGEN_RETRIES`) unless you give one. |
| `scripts/secgen-dev-run --test -s <scenario.xml>` / `scripts/secgen-dev-run -m <module path>` | Build, test and destroy (`secgen.rb test-scenario` / `test-module`): tests run after net0 teardown and the reboot; results in `test_results/<project_id>/` (`summary.json`, resolved `scenario.xml`, masked `build.log`, per-module JSON/logs/evidence). Exits 0 PASS / 1 FAIL / 2 SKIP. `-- --keep-vms` keeps the VMs. |
| `scripts/secgen-dev-destroy [--keep-dir] <projects/<id>>...` | Deletes a kept project's VMs with `secgen.rb destroy-project`, passing the options file by path: on Proxmox they are hard-stopped and deleted through the API (only those in its `.vagrant/machines/*/proxmox/id`), elsewhere `vagrant destroy` is used; then removes the project dir unless `--keep-dir`. |
| `scripts/secgen-test-run <projects/.../secgen_test/<mod>.rb>` | Runs one module's post-provision test against its built VM over the QEMU Guest Agent. Exits 0 PASS / 1 FAIL / 2 SKIP; writes `<project>/test_results/<system>/<mod>.json` (plus evidence on FAIL). |
| `scripts/pve-check [--all \| --list \| --nodes]` | Read-only: PVE version and the QEMU Guest Agent option on every template (or all VMs). `--list` prints just `VMID NODE NAME STATUS` for every VM from one API call. `--nodes` prints `NODE STATUS MEM_PCT CPU_PCT` for every cluster node (memory and CPU in use, as whole percentages), for picking a node to build on. |
| `scripts/agent-check <vmid> [node]` | Read-only guest-agent smoke test (`id`, `hostname`, IPs) via `lib/helpers/proxmox_connection.rb`. |

## Setup

- **Credentials:** a SecGen `--read-options` file, by default `secgen.conf` in the
  main checkout (gitignored, mode 600; worktrees use that same file, not a copy
  of their own), with at least `--proxmox-url`,
  `--proxmoxuser`, `--proxmoxpass` and `--proxmox-node`. The scripts never print
  the password or put it on a command line; `secgen-test-run` passes it to the
  test as `SECGEN_PROXMOX_PASS`.
- **Personal settings** (optional) go in `~/.config/secgen/secgen-dev-run.env`
  (an existing `secgen-run.env` is read if that is absent), which is sourced by
  every script:

  ```sh
  SECGEN_RUN_OWNER=tom        # prefix owner (default: $USER)
  SECGEN_VLAN_MIN=200         # VLAN range secgen-dev-run cycles through
  SECGEN_VLAN_MAX=1000
  # SECGEN_PROXMOX_NODE=pmox02  # build on another node, cloning its <template>-pmox02 copies
  #                           # (unset: the options file's node, which holds the originals)
  # SECGEN_CONF=...           # alternative creds file (absolute path); if SecGen/secgen.conf
  #                           # is missing, ~/.config/secgen/secgen.conf is used
  # SECGEN_STATE=...          # counter file (default ~/.config/secgen/run_counter)
  ```

- The counter file holds `vlan <last>` plus one `<name> <last_index>` line per
  name; edit it by hand to jump numbers. It is locked, so parallel runs don't clash.

Real `secgen-dev-run` builds create VMs on shared hardware: dry-run first, and
destroy the VMs you built when you're done (see the `secgen-test-pipeline` skill).
