require_relative '../../../../../lib/post_provision_test'

class EbpfTracingTest < PostProvisionTest
  def initialize
    self.module_name = 'ebpf_tracing'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    tier(1) do
      test_local_command('bpftrace package installed?', "dpkg -l bpftrace | grep '^ii'", 'bpftrace')
      test_local_command('tracee installed', 'test -x /opt/tracee/dist/tracee && readlink /usr/local/bin/tracee', '/opt/tracee/dist/tracee')
      test_local_command('kernel exposes BTF', 'test -r /sys/kernel/btf/vmlinux && echo btf-present', 'btf-present')
    end

    add_evidence('kernel', 'uname -a')

    # Both tools load eBPF programs, so these run as root (as students do, with sudo).
    tier(2) do
      test_local_command('bpftrace runs a program',
                         %q(timeout 60 bpftrace -e 'BEGIN { printf("bpftrace-ok\n"); exit(); }' 2>&1), 'bpftrace-ok')
      # A syscall tracepoint fires for a command started while the trace is attached.
      test_local_command('bpftrace traces execve',
                         %q{(sleep 5; /usr/bin/true) & timeout 60 bpftrace -e 'tracepoint:syscalls:sys_enter_execve /str(args->filename) == "/usr/bin/true"/ { printf("saw-exec %s\n", str(args->filename)); exit(); }' 2>&1},
                         'saw-exec /usr/bin/true')
      # Tracee takes a while to attach, so the probe command repeats until Tracee reports it.
      probe = '( for i in $(seq 1 20); do sleep 4; /usr/bin/true secgen-tracee-probe; done ) & p=$!; ' \
              'timeout 90 tracee --events execve --output json 2>&1 | grep -m1 -o secgen-tracee-probe; kill $p 2>/dev/null; true'
      result = run_vagrant_ssh(probe, timeout: 150)
      if result[:stdout].to_s.include?('secgen-tracee-probe')
        pass_check('tracee records an execve event')
      else
        fail_check('tracee records an execve event', "#{result[:stdout]} #{result[:stderr]}".strip[0, 1000])
      end

      # A detection signature fires: TRC-102 reports a process that calls ptrace(PTRACE_TRACEME).
      probe = '( for i in $(seq 1 20); do sleep 4; python3 -c "import ctypes; ctypes.CDLL(None).ptrace(0, 0, 0, 0)"; done ) & p=$!; ' \
              'timeout 90 tracee --events anti_debugging --output json 2>&1 | grep -m1 -o anti_debugging; kill $p 2>/dev/null; true'
      result = run_vagrant_ssh(probe, timeout: 150)
      if result[:stdout].to_s.include?('anti_debugging')
        pass_check('tracee signature detects anti-debugging')
      else
        fail_check('tracee signature detects anti-debugging', "#{result[:stdout]} #{result[:stderr]}".strip[0, 1000])
      end
    end

    # student_wrapper: a user without root runs Tracee through sudo tracee-watch, for their own programs only.
    if json_inputs['student_wrapper']&.first.to_s == 'true'
      user = regular_user
      if user.nil?
        skip_check('tracee-watch as a regular user', 'no regular user account on this system', tier: 2)
      else
        tier(1) do
          test_local_command('tracee-watch wrapper installed', 'stat -c %U:%a /usr/local/sbin/tracee-watch', 'root:755')
          test_local_command('sudoers allows only the wrapper', 'visudo -cf /etc/sudoers.d/tracee-watch && cat /etc/sudoers.d/tracee-watch',
                             'NOPASSWD: /usr/local/sbin/tracee-watch')
        end
        tier(2) do
          # A copy of true under a distinctive name, run repeatedly by the user until Tracee reports its exec.
          probe = 'cp /bin/true /tmp/sgwatchprobe && ( for i in $(seq 1 20); do sleep 4; /tmp/sgwatchprobe; done ) & p=$!; ' \
                  'timeout 90 sudo -n /usr/local/sbin/tracee-watch sgwatchprobe 2>&1 | grep -m1 -o "sched_process_exec.*sgwatchprobe"; kill $p 2>/dev/null; true'
          result = run_as_user(user, probe, timeout: 150)
          if result[:stdout].to_s.include?('sched_process_exec')
            pass_check("tracee-watch traces a program as #{user}")
          else
            fail_check("tracee-watch traces a program as #{user}", "#{result[:stdout]} #{result[:stderr]}".strip[0, 1000])
          end
          # The wrapper refuses anything but a plain program name, and sudo grants nothing else.
          test_local_command('tracee-watch rejects extra arguments',
                             'sudo -n /usr/local/sbin/tracee-watch "x --capture exec" 2>&1; sudo -n /usr/local/sbin/tracee-watch a b 2>&1', 'Usage:', user: user)
          test_local_command('sudo grants no other command', 'sudo -n /opt/tracee/dist/tracee --help >/dev/null 2>&1 && echo granted || echo refused',
                             'refused', user: user)
        end
      end
    end
  end
end

EbpfTracingTest.new.run
