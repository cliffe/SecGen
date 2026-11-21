#!/bin/bash
# Stand up a detached interactive shell whose in-memory history holds a command
# carrying a token. HISTFILE is pointed away from disk, so the command never
# lands in ~/.bash_history; it survives only in the live shell's memory, which
# a strings search of a RAM capture recovers. tmux daemonises, so the shell
# outlives this launcher, and the service re-creates it on every boot.
set -u

SESSION=audit-shell
TOKEN=$(/usr/local/sbin/.hist-decode)

# Already up (same boot)? leave it.
if tmux has-session -t "$SESSION" 2>/dev/null; then
  exit 0
fi

tmux new-session -d -s "$SESSION" bash -i
# Give the interactive shell time to start readline before typing into it.
sleep 2
# Keep history in memory (HISTSIZE > 0) but off disk (HISTFILE discarded).
tmux send-keys -t "$SESSION" 'export HISTFILE=/dev/null HISTSIZE=2000' Enter
sleep 1
# The command the "attacker" ran; it is added to the shell's in-memory history.
# Output is discarded, so nothing about the token is written to disk.
tmux send-keys -t "$SESSION" "echo '$TOKEN' > /dev/null" Enter
sleep 1

exit 0
