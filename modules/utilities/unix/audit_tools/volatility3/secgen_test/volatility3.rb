require_relative '../../../../../lib/post_provision_test'

class Volatility3Test < PostProvisionTest
  def initialize
    self.module_name = 'volatility3'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # Volatility 3 lives in a venv at /opt/volatility3, linked into PATH as `vol`.
    tier(1) do
      test_local_command('vol on PATH?', 'test -x /usr/local/bin/vol && echo ok', 'ok')
      # The first `vol` invocation enumerates ~115 plugins and writes a cache;
      # on a freshly rebooted, still-settling VM that one call can run past the
      # default command timeout and SKIP the whole test. Prime the cache once
      # with a generous deadline so the checks below run against a warm cache.
      run_vagrant_ssh('/usr/local/bin/vol --help >/dev/null 2>&1 || true', timeout: 300)
      test_local_command('vol runs?', '/usr/local/bin/vol --help 2>&1 | head -1', 'Volatility 3 Framework')
      # install.pp copied the bundled ISFs into the symbol path.
      test_local_command('a Linux ISF is installed?',
                         'ls /opt/volatility3/lib/python*/site-packages/volatility3/symbols/linux/*.json.xz 2>/dev/null | head -1',
                         '.json.xz')
      # A bundled ISF must cover the kernel of whichever VM the RAM capture is
      # taken from, byte for byte, or Volatility can't resolve symbols against it.
      verify_capture_target_isf_coverage
    end
    tier(2) do
      # Linux plugins are available (proves the Linux framework loaded).
      test_local_command('linux.pslist plugin present?',
                         '/usr/local/bin/vol --help 2>&1 | grep -o "linux.pslist" | head -1',
                         'linux.pslist')
      # isfinfo parses the bundled ISF - the symbol table is valid, not just present.
      test_local_command('bundled ISF is a valid symbol table?',
                         '/usr/local/bin/vol isfinfo 2>&1 | grep -qi "linux" && echo FOUND',
                         'FOUND')
    end
  end

  # LiME is what captures RAM in a format Volatility can parse, so the VM with
  # LiME built is the capture target. For every such VM in the scenario (a
  # sibling, or this workstation itself), assert a bundled ISF on this
  # workstation matches that VM's running kernel banner byte for byte. This runs
  # after the post-provision reboot, so each VM reports the kernel it actually
  # booted - the one the capture will be taken from. A mismatch fails loudly:
  # the signal to regenerate the ISF (update-volatility-isf skill).
  #
  # If no VM in the scenario has LiME, there is no capture target to align to, so
  # nothing is recorded here and the vol-works checks above stand on their own -
  # keeping this test valid for scenarios that bundle Volatility without LiME.
  def verify_capture_target_isf_coverage
    lime_probe = 'ls /root/LiME/src/lime-*.ko 2>/dev/null | head -1'
    targets = context_systems.map { |s| s['name'] }.select do |name|
      next false unless name == get_system_name || system_present?(name)
      out = run_on_system_or_self(name, lime_probe)
      out && !out[:stdout].to_s.strip.empty?
    end

    if targets.empty?
      self.outputs.push 'No VM in this scenario has LiME built: skipping capture-target ISF coverage check.'
      return
    end

    targets.each do |name|
      banner = run_on_system_or_self(name, 'cat /proc/version')[:stdout].to_s.strip
      if banner.empty?
        fail_check("capture target #{name}: kernel banner readable",
                   "could not read /proc/version on #{name}", tier: 1)
        next
      end
      b64 = Base64.strict_encode64(banner)
      cmd = "want=$(echo #{b64} | base64 -d); m=NONE; " \
            'for b in /opt/volatility3/isf/*.banner; do ' \
            '[ -f "${b%.banner}.json.xz" ] || continue; ' \
            '[ "$(cat "$b")" = "$want" ] && m=COVERED; done; echo "$m"'
      if run_command(cmd)[:stdout].include?('COVERED')
        pass_check("capture target #{name}: a bundled ISF matches its kernel",
                   "#{name} kernel covered by a bundled ISF on #{get_system_name}: #{banner}", tier: 1)
      else
        bundled = run_command('for b in /opt/volatility3/isf/*.banner; do echo "== $b"; cat "$b"; echo; done')[:stdout]
        fail_check("capture target #{name}: a bundled ISF matches its kernel",
                   "NO BUNDLED ISF for #{name} kernel (regenerate with update-volatility-isf): #{banner}",
                   tier: 1,
                   evidence: "capture target #{name} /proc/version:\n#{banner}\n--- bundled banners on #{get_system_name}\n#{bundled}")
      end
    end
  end

  # Run a command on `name`, whether that is a sibling VM or this system itself.
  def run_on_system_or_self(name, cmd)
    name == get_system_name ? run_command(cmd) : run_on_system(name, cmd)
  end
end

Volatility3Test.new.run
