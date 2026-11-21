require_relative '../../../../../lib/post_provision_test'

class DeletedBinaryProcessTest < PostProvisionTest
  def initialize
    self.module_name = 'deleted_binary_process'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Flag comes from this module's received inputs, so the test holds for any
    # parameterised deployment, not just the default flag_generator value.
    flag = json_inputs['flag'] ? json_inputs['flag'][0] : nil

    tier(1) do
      test_local_command('dropper binary built?',
                         'test -f /opt/.systemd-helper/.udev-net-helper && echo ok', 'ok')
      test_local_command('plaintext source removed after build?',
                         'test ! -f /opt/.systemd-helper/payload.c && echo gone', 'gone')
      test_local_command('service enabled?',
                         'systemctl is-enabled udev-net-helper.service 2>&1', 'enabled')
    end

    tier(2) do
      # A running process whose executable has been unlinked: /proc/<pid>/exe
      # resolves to a now-deleted file under /dev/shm.
      find_fileless = 'for p in /proc/[0-9]*; do l=$(readlink "$p/exe" 2>/dev/null) || continue; ' \
                      'case "$l" in /dev/shm/*) echo DELETED_PROC; break;; esac; done'
      test_local_command('a fileless (deleted-exe) process is running?',
                         find_fileless, 'DELETED_PROC')

      # The kernel task name (comm) holds the real, build-specific name, while
      # the argument vector is forged as a kernel worker thread. This is the
      # property a memory-forensics exercise recovers with psscan.
      if flag
        comm_expected = flag[0, 15]  # comm is truncated to TASK_COMM_LEN-1 (15)
        read_comm = 'for p in /proc/[0-9]*; do l=$(readlink "$p/exe" 2>/dev/null) || continue; ' \
                    'case "$l" in /dev/shm/*) cat "$p/comm"; break;; esac; done'
        test_local_command('deleted-exe process comm holds the real name?',
                           read_comm, comm_expected)
        read_argv = 'for p in /proc/[0-9]*; do l=$(readlink "$p/exe" 2>/dev/null) || continue; ' \
                    'case "$l" in /dev/shm/*) tr "\\0" " " < "$p/cmdline"; break;; esac; done'
        test_local_command('deleted-exe process argv is forged as a kernel worker?',
                           read_argv, '[kworker')
      end
    end

    tier(3) do
      if flag.nil?
        skip_check('flag recoverable from the live process memory?',
                   'no flag input available to test', tier: 3)
      else
        memscan = <<~BASH
          cat > /tmp/.memscan.py <<'PYEOF'
          import os, sys
          flag = os.environ['FLAG'].encode()
          pid = None
          for p in os.listdir('/proc'):
              if not p.isdigit():
                  continue
              try:
                  tgt = os.readlink('/proc/%s/exe' % p)
              except OSError:
                  continue
              if tgt.startswith('/dev/shm/'):
                  pid = p
                  break
          if not pid:
              print('NOPID'); sys.exit(0)
          regions = []
          for line in open('/proc/%s/maps' % pid):
              parts = line.split()
              if len(parts) < 2 or not parts[1].startswith('rw'):
                  continue
              a, b = parts[0].split('-')
              regions.append((int(a, 16), int(b, 16)))
          fh = open('/proc/%s/mem' % pid, 'rb', 0)
          for s, e in regions:
              try:
                  fh.seek(s); data = fh.read(e - s)
              except OSError:
                  continue
              if flag in data:
                  print('FLAGFOUND'); sys.exit(0)
          print('NOFLAG')
          PYEOF
          FLAG=#{flag} python3 /tmp/.memscan.py; rm -f /tmp/.memscan.py
        BASH
        test_local_command('flag recoverable from the live process memory?',
                           memscan, 'FLAGFOUND')
      end
    end
  end
end

DeletedBinaryProcessTest.new.run
