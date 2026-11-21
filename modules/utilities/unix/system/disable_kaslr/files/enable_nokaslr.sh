#!/bin/sh
# Append nokaslr to the kernel command line (preserving existing parameters),
# then regenerate the GRUB config. Idempotent: does nothing if already set.
set -e

grub=/etc/default/grub

if grep -qE '^GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\bnokaslr\b' "$grub"; then
  exit 0
fi

if grep -qE '^GRUB_CMDLINE_LINUX_DEFAULT="' "$grub"; then
  sed -i -E 's/^(GRUB_CMDLINE_LINUX_DEFAULT=")([^"]*)(")/\1\2 nokaslr\3/' "$grub"
else
  printf 'GRUB_CMDLINE_LINUX_DEFAULT="nokaslr"\n' >> "$grub"
fi

# Trim a leading space if the previous value was empty.
sed -i -E 's/^(GRUB_CMDLINE_LINUX_DEFAULT=") +/\1/' "$grub"

update-grub
