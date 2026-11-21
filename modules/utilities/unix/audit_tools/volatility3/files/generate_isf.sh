#!/bin/bash
# Maintainer tool - NOT run by Puppet. Bundled so it travels with the module.
#
# Generates a Volatility 3 Linux symbol table (ISF) for the CURRENT kernel plus
# the matching banner sidecar, ready to commit under this module's files/isf/.
# Run it as root, with internet, on (or against) a VM booting the exact kernel
# you want symbols for - e.g. a fresh Debian 12 KDE SecGen base, or the lab's
# compromised_server before a build hard-fails for a missing ISF.
#
# Usage: sudo ./generate_isf.sh [output_dir]   (default: ./isf next to this script)
set -euo pipefail

# Target the newest INSTALLED kernel - what the VM boots into after the
# post-provision reboot - not necessarily the one running now (uname -r). Pass a
# release as $1 to override (e.g. when generating on a workstation).
case "${1:-}" in
  *-amd64|*-686*) KVER=$1; shift ;;
  *)             KVER=$(ls -1 /lib/modules | sort -V | tail -1) ;;
esac
OUT_DIR=${1:-"$(cd "$(dirname "$0")" && pwd)/isf"}
mkdir -p "$OUT_DIR"

echo "[*] Target kernel: $KVER"

# 1. Debug symbols (vmlinux with DWARF) for this exact kernel, from the Debian
#    debug archive. The package is large (hundreds of MB).
CODENAME=$(. /etc/os-release 2>/dev/null; echo "${VERSION_CODENAME:-bookworm}")
apt-get update || true
if ! apt-get install -y "linux-image-${KVER}-dbg"; then
  echo "[*] Enabling the debian-debug (dbgsym) archive for ${CODENAME}"
  echo "deb http://deb.debian.org/debian-debug ${CODENAME}-debug main" \
    > /etc/apt/sources.list.d/debian-debug.list
  apt-get update
  apt-get install -y "linux-image-${KVER}-dbg"
fi
VMLINUX="/usr/lib/debug/boot/vmlinux-${KVER}"
if [ ! -f "$VMLINUX" ]; then
  # Some builds ship the vmlinux under a build-id path instead.
  VMLINUX=$(find /usr/lib/debug -name "vmlinux-${KVER}" -o -name 'vmlinux' 2>/dev/null | head -1)
fi
[ -n "$VMLINUX" ] && [ -f "$VMLINUX" ] || { echo "[!] vmlinux with debug info not found for ${KVER}." >&2; exit 1; }

# 2. dwarf2json (converts the kernel DWARF into Volatility's ISF JSON).
if ! command -v dwarf2json >/dev/null 2>&1; then
  echo "[*] Building dwarf2json"
  apt-get install -y golang git
  tmp=$(mktemp -d)
  git clone --depth 1 https://github.com/volatilityfoundation/dwarf2json "$tmp/dwarf2json"
  # Puppet execs run with a minimal environment: Go needs HOME/GOPATH/GOCACHE set
  # explicitly or it aborts with "module cache not found".
  ( cd "$tmp/dwarf2json" && \
    HOME=/root GOPATH=/root/go GOCACHE=/root/.cache/go-build GOFLAGS=-mod=mod go build )
  install -m755 "$tmp/dwarf2json/dwarf2json" /usr/local/bin/
  rm -rf "$tmp"
fi

# 3. Generate the ISF and compress it (Volatility reads .json.xz directly).
echo "[*] Generating ISF (this takes a minute or two)"
dwarf2json linux --elf "$VMLINUX" > "$OUT_DIR/${KVER}.json"
xz -9 -f "$OUT_DIR/${KVER}.json"

# 4. Banner sidecar: the exact /proc/version this ISF was built for. The runtime
#    selector matches on this, so it must come from the same running kernel.
cat /proc/version > "$OUT_DIR/${KVER}.banner"

echo "[+] Wrote:"
echo "      $OUT_DIR/${KVER}.json.xz"
echo "      $OUT_DIR/${KVER}.banner"
echo "[+] Commit both under the module's files/isf/."
