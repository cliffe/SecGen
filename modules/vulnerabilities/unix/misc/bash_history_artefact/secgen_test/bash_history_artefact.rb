require_relative '../../../../../lib/post_provision_test'

class BashHistoryArtefactTest < PostProvisionTest
  def initialize
    self.module_name = 'bash_history_artefact'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Flag comes from this module's received inputs, so the test holds for any
    # parameterised deployment, not just the default flag_generator value.
    flag = json_inputs['flag'] ? json_inputs['flag'][0] : nil

    tier(1) do
      test_local_command('history decoder built?',
                         'test -x /usr/local/sbin/.hist-decode && echo ok', 'ok')
      test_local_command('plaintext source removed after build?',
                         'test ! -f /opt/.audit/hist.c && echo gone', 'gone')
      test_local_command('tmux installed?',
                         'command -v tmux >/dev/null && echo ok', 'ok')
      test_local_command('service enabled?',
                         'systemctl is-enabled session-audit-shell.service 2>&1', 'enabled')
    end

    tier(2) do
      # The launcher daemonises a detached interactive shell under tmux; it must
      # still be running at capture time (and after the post-provision reboot).
      # The oneshot service recreates the session a few seconds into boot (it
      # sleeps to let the shell settle), so a test firing immediately after the
      # guest agent comes up can beat it to the session. Poll rather than read
      # once: a student captures minutes later, when it is long settled.
      up = ''
      deadline = Time.now + 30
      loop do
        up = run_command('tmux has-session -t audit-shell 2>/dev/null && echo UP')[:stdout].to_s
        break if up.include?('UP') || Time.now >= deadline
        sleep 3
      end
      if up.include?('UP')
        pass_check('detached audit shell still running?',
                   'tmux session audit-shell is present', tier: 2)
      else
        fail_check('detached audit shell still running?',
                   'tmux has-session -t audit-shell found no session within 30s', tier: 2)
      end
    end

    tier(3) do
      if flag.nil?
        skip_check('flag recoverable from a live shell\'s in-memory history?',
                   'no flag input available to test', tier: 3)
      else
        # The flag-bearing command lives only in a running bash's heap history,
        # never in an on-disk history file. Prove that: it is absent from every
        # ~/.bash_history yet present in a live bash process's writable memory.
        memscan = <<~BASH
          cat > /tmp/.histscan.py <<'PYEOF'
          import os, sys
          flag = os.environ['FLAG'].encode()
          hits = []
          for p in os.listdir('/proc'):
              if not p.isdigit():
                  continue
              try:
                  comm = open('/proc/%s/comm' % p).read().strip()
              except OSError:
                  continue
              if comm != 'bash':
                  continue
              try:
                  regions = []
                  for line in open('/proc/%s/maps' % p):
                      parts = line.split()
                      if len(parts) < 2 or not parts[1].startswith('rw'):
                          continue
                      a, b = parts[0].split('-')
                      regions.append((int(a, 16), int(b, 16)))
                  fh = open('/proc/%s/mem' % p, 'rb', 0)
              except OSError:
                  continue
              for s, e in regions:
                  try:
                      fh.seek(s); data = fh.read(e - s)
                  except OSError:
                      continue
                  if flag in data:
                      hits.append(p)
                      break
              if hits:
                  break
          print('FLAGFOUND' if hits else 'NOFLAG')
          PYEOF
          FLAG=#{Shellwords.escape(flag)} python3 /tmp/.histscan.py; rm -f /tmp/.histscan.py
        BASH
        test_local_command('flag recoverable from a live shell\'s in-memory history?',
                           memscan, 'FLAGFOUND')
        # Confirm it is NOT in any on-disk history file (so RAM is the only source).
        ondisk = "grep -rqF #{Shellwords.escape(flag)} /root/.bash_history " \
                 '/home/*/.bash_history 2>/dev/null && echo ONDISK || echo ABSENT'
        test_local_command('token absent from on-disk history files?',
                           ondisk, 'ABSENT')
      end
    end
  end
end

BashHistoryArtefactTest.new.run
