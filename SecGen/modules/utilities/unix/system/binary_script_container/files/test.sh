#!/usr/local/bin/suid /bin/bash -o privileged --
set -eu
echo uid=$(id -run) euid=$(id -un)
echo gid=$(id -rgn) egid=$(id -gn)