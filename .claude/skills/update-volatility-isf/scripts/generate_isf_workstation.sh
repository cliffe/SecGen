#!/usr/bin/env bash
# Generate a Volatility 3 Linux ISF (symbol table) for a given Debian kernel on a
# workstation, without a live VM. Downloads the kernel debug image from
# snapshot.debian.org, extracts its vmlinux, runs a prebuilt dwarf2json, and
# writes the compressed ISF + the banner sidecar straight into the volatility3
# module's files/isf/.
#
# Usage:
#   scripts/generate_isf_workstation.sh <kernelrelease> [package_version] [out_dir]
#
#   <kernelrelease>   e.g. 6.1.0-50-amd64  (the "Running kernel:" from a build's
#                     hard-fail, or `uname -r` on the base)
#   [package_version] e.g. 6.1.176-1       (optional; newest is resolved if omitted)
#   [out_dir]         where to write the pair (default: the volatility3 module's
#                     files/isf under the current git checkout)
#
# Needs: curl, xz, dpkg-deb, tar, strings (binutils), ~6 GB free disk, internet.
# NOTE for agents: this runs a downloaded dwarf2json binary; a sandbox may block
# that. If so, ask the user to run this script (or the dwarf2json line) directly.
set -euo pipefail

KVER=${1:?Usage: generate_isf_workstation.sh <kernelrelease> [package_version] [out_dir]}
PKGVER=${2:-}
DBG_PKG="linux-image-${KVER}-dbg"
DWARF2JSON_VERSION=v0.9.0

# --- where to put the result ----------------------------------------------
if [ -n "${3:-}" ]; then
  OUT_DIR=$3
else
  ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
  [ -n "$ROOT" ] || { echo "Not in a git checkout; pass an out_dir." >&2; exit 1; }
  OUT_DIR="$ROOT/modules/utilities/unix/audit_tools/volatility3/files/isf"
fi
mkdir -p "$OUT_DIR"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
echo "[*] Target: $DBG_PKG  (kernel $KVER)"
echo "[*] Work dir: $WORK"

api() { curl -fsS --max-time 60 "$@"; }

# --- 1. resolve the package version + file hash on snapshot.debian.org -----
if [ -z "$PKGVER" ]; then
  echo "[*] Resolving newest version of $DBG_PKG"
  PKGVER=$(api "https://snapshot.debian.org/mr/binary/${DBG_PKG}/" \
    | tr ',' '\n' | grep -o '"binary_version":"[^"]*"' | cut -d'"' -f4 \
    | sort -V | tail -1)
  [ -n "$PKGVER" ] || { echo "Could not resolve a version for $DBG_PKG" >&2; exit 1; }
fi
echo "[*] Version: $PKGVER"

HASH=$(api "https://snapshot.debian.org/mr/package/linux/${PKGVER}/binfiles/${DBG_PKG}/${PKGVER}?fileinfo=1" \
  | grep -o '"hash":"[0-9a-f]*"' | head -1 | cut -d'"' -f4)
[ -n "$HASH" ] || { echo "Could not find the .deb hash for $DBG_PKG $PKGVER on snapshot.debian.org" >&2; exit 1; }
echo "[*] dbgsym file hash: $HASH"

# --- 2. download the dbgsym .deb and extract only the vmlinux --------------
echo "[*] Downloading dbgsym (hundreds of MB)..."
api -o "$WORK/dbg.deb" "https://snapshot.debian.org/file/${HASH}"
echo "[*] Extracting vmlinux"
dpkg-deb --fsys-tarfile "$WORK/dbg.deb" \
  | tar -x --wildcards -C "$WORK" './usr/lib/debug/boot/vmlinux-*'
VMLINUX=$(find "$WORK/usr/lib/debug/boot" -name "vmlinux-${KVER}" | head -1)
[ -n "$VMLINUX" ] && [ -f "$VMLINUX" ] || { echo "vmlinux-${KVER} not in the package." >&2; exit 1; }

# --- 3. prebuilt dwarf2json ------------------------------------------------
if command -v dwarf2json >/dev/null 2>&1; then
  D2J=dwarf2json
else
  echo "[*] Fetching dwarf2json ${DWARF2JSON_VERSION}"
  curl -fsSL --max-time 120 -o "$WORK/dwarf2json" \
    "https://github.com/volatilityfoundation/dwarf2json/releases/download/${DWARF2JSON_VERSION}/dwarf2json-linux-amd64"
  chmod +x "$WORK/dwarf2json"
  D2J="$WORK/dwarf2json"
fi

# --- 4. generate ISF + banner ---------------------------------------------
echo "[*] Running dwarf2json (a minute or two)"
"$D2J" linux --elf "$VMLINUX" > "$WORK/${KVER}.json"
xz -9 -f "$WORK/${KVER}.json"
cp "$WORK/${KVER}.json.xz" "$OUT_DIR/${KVER}.json.xz"

# The banner must byte-match /proc/version on the captured VM. The vmlinux holds
# two banner strings - a pre-build template with a bare "# " and the real one
# with the build counter "#1"; /proc/version is the "#<digit>" form, so match
# that. printf (no trailing newline) matches how select_isf.sh compares via
# $(cat ...).
# grep -m1 closes the pipe on the first match, so strings dies with SIGPIPE (141);
# under pipefail that would abort the script even though grep already captured the
# line. Swallow the pipeline status (|| true) and let the -n guard below catch a
# genuine no-match.
BANNER=$(strings -n 20 "$VMLINUX" | grep -m1 -E "^Linux version ${KVER} .*\) #[0-9]" || true)
[ -n "$BANNER" ] || { echo "Could not extract the kernel banner from vmlinux." >&2; exit 1; }
printf '%s' "$BANNER" > "$OUT_DIR/${KVER}.banner"

echo "[+] Wrote:"
echo "      $OUT_DIR/${KVER}.json.xz"
echo "      $OUT_DIR/${KVER}.banner"
echo "[+] Banner: $BANNER"
echo "[+] Commit both, then rebuild the lab to confirm select_isf.sh matches."
