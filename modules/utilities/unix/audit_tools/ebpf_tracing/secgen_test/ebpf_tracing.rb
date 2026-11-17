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
    end
  end
end

EbpfTracingTest.new.run
