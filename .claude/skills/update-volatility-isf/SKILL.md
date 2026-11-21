---
name: update-volatility-isf
description: Regenerate and commit a Volatility 3 Linux symbol table (ISF) for the SecGen volatility3 module when a base kernel changes. Use when the volatility3 secgen_test fails with "NO BUNDLED ISF FOR: <banner>", after updating a Debian base image, or to add ISF support for a new kernel or base. Covers identifying the target (post-reboot) kernel, generating the ISF on a workstation (snapshot.debian.org + dwarf2json, no live VM needed) or on a VM, writing the banner sidecar, committing and verifying. Trigger words - "volatility ISF", "symbol table", "NO BUNDLED ISF FOR", dwarf2json, "regenerate volatility symbols", "memory forensics kernel".
---

# Update the Volatility 3 ISF for a new kernel

> **Paths** in this skill are relative to the SecGen repository root (or your
> worktree of it). If your session runs from a parent directory holding several
> repos, prefix them with the SecGen checkout, e.g. `SecGen/modules/...`. The
> bundled `scripts/` are relative to this skill's own directory (printed when the
> skill is invoked).

The `volatility3` module
(`modules/utilities/unix/audit_tools/volatility3`) ships per-kernel symbol tables
as `files/isf/<kernelrelease>.json.xz` with a `<kernelrelease>.banner` sidecar.
At provision time `install.pp` copies **all** of them into Volatility's symbol
path, and Volatility matches the right one to a memory image by its kernel banner
at analysis time. An ISF is tied to the exact kernel build it came from, so a new
base kernel needs a new ISF.

## The post-reboot kernel is the one that matters

SecGen's `update` module installs the newest kernel during provisioning, but the
VM keeps running the old one until the post-provision reboot. The lab then boots
the **newest** kernel, and that is what students capture. So:

- The ISF must match the **post-reboot** kernel, not the one running during the
  build. On a workstation, target the newest kernel version, not whatever the
  build logs happened to show mid-provision.
- The check lives in the module's `secgen_test`, which runs **after** the reboot
  and so sees the real kernel. It fails with `NO BUNDLED ISF FOR: <banner>` when
  no shipped ISF covers the running kernel. That failure is the trigger for this
  skill. (Puppet can't do this check - it runs before the reboot.)

## Step 1 — identify the target kernel

- From the failing test: the `NO BUNDLED ISF FOR:` line prints the exact
  `/proc/version` banner, e.g.
  `Linux version 6.1.0-54-amd64 ... Debian 6.1.190-1 (2026-10-16)` - giving the
  release `6.1.0-54-amd64` and package version `6.1.190-1`.
- Or on a base after `apt full-upgrade`: `ls -1 /lib/modules | sort -V | tail -1`
  is the newest installed kernel (what it will boot next); its package version is
  `dpkg -s linux-image-<that> | awk '/^Version:/{print $2}'`.

## Step 2 — generate the ISF (workstation method, preferred)

`dwarf2json` only reads the kernel's `vmlinux`, so this runs anywhere - no live
VM, and the heavy download stays off Proxmox storage (see "Why not generate at
build time"). The bundled script does it all:

```bash
scripts/generate_isf_workstation.sh 6.1.0-54-amd64 6.1.190-1
# -> writes modules/utilities/unix/audit_tools/volatility3/files/isf/
#      6.1.0-54-amd64.json.xz  and  6.1.0-54-amd64.banner
```

It resolves the debug package on `snapshot.debian.org`, downloads it, extracts
`vmlinux`, fetches a prebuilt `dwarf2json`, produces the compressed ISF, and
writes the banner sidecar (the `#<digit>` form of `linux_banner`, byte-for-byte
what `/proc/version` prints). Omit the version to take the newest. Needs `curl`,
`xz`, `dpkg-deb`, `tar`, `strings`, ~6 GB free disk and internet.

> Sandbox note: the script runs a downloaded `dwarf2json` binary. If you are an
> agent and execution is blocked, do everything up to it and ask the user to run
> the single `dwarf2json ... | xz -9 > <kver>.json.xz` line, then continue.

## Step 2 (alternative) — generate on a VM

`files/generate_isf.sh` runs on a machine with the target kernel installed, root
and internet. It targets the newest **installed** kernel (what the VM boots after
reboot), installs that kernel's dbgsym (enabling the `debian-debug` archive) and
builds `dwarf2json`. Use it when you can't fetch the vmlinux on a workstation.
Catch: a built SecGen VM loses internet after `net0` teardown, so run this during
provisioning (before teardown) or on a VM that still has a network - not on a
finished, isolated lab VM.

## Step 3 — commit and verify

```bash
git add modules/utilities/unix/audit_tools/volatility3/files/isf/
git commit -m "volatility3: ISF for <kernelrelease> (<package version>)"
```

Keep older ISFs: Volatility matches on the banner, so shipping several lets the
module cover more than one base kernel at once. Then rebuild a scenario that uses
the module (e.g.
`scenarios/labs/response_and_investigation/7_live_analysis.xml`) and confirm the
`volatility3` secgen_test passes `a bundled ISF matches the running (post-reboot)
kernel?`. A full end-to-end check: capture RAM with LiME on the target VM and run
`vol -f <dump> linux.pslist` on the analyst VM - it should list processes, not
fail with "symbol table requirement not fulfilled".

## Gotchas learned the hard way

- **Target the post-reboot kernel.** The single biggest trap: the kernel running
  mid-build is not the one the lab runs. Generate for the newest kernel, and let
  the post-reboot `secgen_test` confirm coverage.
- **Banner match is exact and uses the `#<digit>` form.** `/proc/version` is the
  `linux_banner` with the build counter (`#1 SMP ...`); the vmlinux also holds a
  pre-build `# ` template string, so match `) #[0-9]`. The sidecar holds the
  banner with no trailing newline (`printf '%s'`), matching how the test compares.
- **`go build` under Puppet needs `HOME`/`GOPATH`/`GOCACHE` set**, or it aborts
  with "module cache not found". The on-VM `generate_isf.sh` sets them.
- **The kernel dbgsym is in the debug archive, not main.** On a VM,
  `generate_isf.sh` adds `deb http://deb.debian.org/debian-debug <codename>-debug main`.
  On a workstation the script uses `snapshot.debian.org`, which has every build.
- **Match the captured kernel, not the analyst's.** They are the same base in the
  live-analysis lab, so one ISF covers both. If a capture scenario mixes bases,
  ship an ISF for each captured kernel.

## Why not generate at build time

Fetching the dbgsym (~855 MB) and installing it (~5.7 GB on disk) per build is
slow and hammers Proxmox storage I/O, and depends on an external archive being up
mid-build. Shipping the ISF (a ~2 MB file copied in at provision) avoids that, at
the cost of this occasional manual refresh - hence regenerate-on-drift rather
than build-time generation.
