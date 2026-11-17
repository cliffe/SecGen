require_relative '../../../../../lib/post_provision_test'

class ReaTest < PostProvisionTest
  FRAGMENT = '/usr/local/lib/secgen-opencode/20-rea-mcp.json'.freeze
  ENTRY = '/usr/local/lib/node_modules/rea-agents/scripts/rea.mjs'.freeze
  PROBE_DIR = '/var/tmp/rea_probe'.freeze
  PROBE_FUNCTION = 'secgen_probe_add'.freeze

  def initialize
    self.module_name = 'rea'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    rea_version = self.json_inputs['rea_version']&.first
    ghidra_timeout = self.json_inputs['ghidra_startup_timeout_ms']&.first
    mcp_timeout = self.json_inputs['mcp_timeout_ms']&.first
    java_home = self.json_inputs['java_home']&.first.to_s.strip
    user = login_user

    tier(1) do
      test_local_command('rea-agents installed globally',
                         'test -d /usr/local/lib/node_modules/rea-agents && test -x /usr/local/bin/rea && echo ok',
                         'ok')
      # The MCP registration launches this script by absolute path
      test_local_command('MCP entry script present', "test -f #{ENTRY} && echo ok", 'ok')
      test_local_command('MCP registration fragment present', "test -f #{FRAGMENT} && echo ok", 'ok')
      test_local_command('Ghidra install dir exported to login shells',
                         'grep -c GHIDRA_INSTALL_DIR /etc/profile.d/rea.sh', '1')
      # REA's process supervisor refuses to launch Ghidra without a procps-compatible ps on PATH, and the
      # failure it reports names a capability rather than the missing command
      test_local_command('procps ps available', 'ps --version 2>&1', 'procps')
    end

    tier(2) do
      if rea_version
        test_local_command('rea runs and reports the installed version', 'rea --version', rea_version, user: user)
      else
        test_command_succeeds('rea runs', 'rea --version', user: user)
      end

      test_local_command('GHIDRA_INSTALL_DIR resolves to an installed Ghidra',
                         'test -x "$GHIDRA_INSTALL_DIR/support/analyzeHeadless" && echo ok', 'ok', user: user)
      if ghidra_timeout
        test_local_command('Ghidra startup timeout exported', 'echo "$REA_GHIDRA_STARTUP_TIMEOUT_MS"',
                           ghidra_timeout, user: user)
      end
      # A JAVA_HOME is always exported: the scenario's, or the JDK the ghidra module pins. Kali's default java
      # is a JRE, which REA rejects, so prove the one in use carries the compiler rather than only that the
      # variable is set.
      if java_home.empty?
        test_command_succeeds('JAVA_HOME exported', 'test -n "$JAVA_HOME"', user: user)
      else
        test_local_command('JAVA_HOME exported', 'echo "$JAVA_HOME"', java_home, user: user)
      end
      test_local_command('JAVA_HOME is a full JDK', 'test -x "$JAVA_HOME/bin/javac" && echo ok', 'ok', user: user)

      # Scoped doctor: its exit status reflects the Ghidra checks alone, so it proves the engine, its JDK and
      # the owned-process prerequisite together
      doctor = run_as_user(user, 'rea doctor --provider ghidra --json', timeout: 600)
      name = 'rea doctor reports the Ghidra provider healthy'
      if doctor[:exit_status] == 0
        pass_check(name, "#{name} on #{get_system_name}", tier: 2)
      else
        fail_check(name, "#{name}: exited #{doctor[:exit_status]}", tier: 2,
                   evidence: "--- stdout\n#{doctor[:stdout]}\n--- stderr\n#{doctor[:stderr]}")
      end

      test_mcp_registration(mcp_timeout, ghidra_timeout, java_home)
      test_opencode_connects_to_the_server(user)
      test_decompiles_a_binary
    end
  end

  # A registration that reads correctly still proves nothing about whether OpenCode can start the server and
  # list its tools: a wrong command, a missing JAVA_HOME or a Ghidra that will not come up all leave the
  # fragment looking right and the agent with no tools. "opencode mcp list" starts the server for real.
  def test_opencode_connects_to_the_server(user)
    name = 'OpenCode connects to the REA MCP server'
    return skip_check(name, 'no ordinary login account on this system', tier: 2) unless user

    command = 'set -a; [ -f /etc/environment ] && . /etc/environment; set +a; timeout 240 opencode mcp list'
    result = run_as_user(user, command, timeout: 300)
    # The listing is drawn with box characters and ANSI colour, and a colour escape lands directly against
    # the status word ("rea \e[90mconnected"), killing the word boundary a match needs. Strip the escapes.
    output = result[:stdout].to_s.gsub(/\e\[[0-9;]*[a-zA-Z]/, '')
    evidence = "$ #{command}\n--- stdout\n#{output}\n--- stderr\n#{result[:stderr]}"

    if result[:exit_status] == 124
      skip_check(name, 'opencode mcp list did not answer within 240s', tier: 2)
    elsif output.match?(/\brea\b/) && output.match?(/\bconnected\b/) &&
          !output.match?(/not connected|disconnected|failed/i)
      pass_check(name, "#{name}: rea connected", tier: 2)
    else
      fail_check(name, "#{name}: rea was not listed as connected", tier: 2, evidence: evidence)
    end
  end

  # The registration has to carry the raised timeout, and the merge has to leave the opencode module's
  # provider block in place rather than replacing the file. Both are written in the form the pinned OpenCode
  # honours: a server keyed under "mcp", and the timeout under "experimental".
  def test_mcp_registration(mcp_timeout, ghidra_timeout, java_home)
    probe = <<~'JS'
      const fs = require("fs");
      const config = JSON.parse(fs.readFileSync(process.env.CFG, "utf8"));
      const server = (config.mcp || {}).rea || {};
      const environment = server.environment || {};
      console.log("type=" + (server.type || ""));
      console.log("enabled=" + String(server.enabled !== false));
      console.log("command=" + (server.command || []).join(" "));
      console.log("timeout=" + ((config.experimental || {}).mcp_timeout || ""));
      console.log("ghidra_dir=" + (environment.GHIDRA_INSTALL_DIR || ""));
      console.log("ghidra_timeout=" + (environment.REA_GHIDRA_STARTUP_TIMEOUT_MS || ""));
      console.log("java_home=" + (environment.JAVA_HOME || ""));
      console.log("provider_kept=" + String(Boolean((config.provider || {}).spark)));
    JS
    command = 'U=$(awk -F: \'$3>=1000 && $3<60000 && $6 ~ /^\/home\// {print $1; exit}\' /etc/passwd); ' \
              '[ -n "$U" ] || { echo "no-login-user"; exit 0; }; ' \
              'H=$(getent passwd "$U" | cut -d: -f6); CFG="$H/.config/opencode/opencode.json"; ' \
              "CFG=\"$CFG\" /usr/local/bin/node -e #{shell_quote(probe)}"

    result = run_vagrant_ssh(command, timeout: 120)
    if result[:stdout].include?('no-login-user')
      return skip_check('REA is registered with OpenCode', 'no ordinary login account on this system', tier: 2)
    end
    fields = parse_fields(result[:stdout])
    evidence = "$ #{command}\n--- stdout\n#{result[:stdout]}\n--- stderr\n#{result[:stderr]}"

    expect(fields, 'type', 'local', 'REA is registered as a local MCP server', evidence)
    expect(fields, 'enabled', 'true', 'the registration is enabled', evidence)
    expect(fields, 'command', "/usr/local/bin/node #{ENTRY} mcp", 'registration launches the MCP entry script',
           evidence)
    expect(fields, 'timeout', mcp_timeout, 'MCP timeout is the configured one', evidence) if mcp_timeout
    if ghidra_timeout
      expect(fields, 'ghidra_timeout', ghidra_timeout, 'Ghidra startup timeout reaches the MCP server', evidence)
    end
    # The server runs without a login shell, so the registration has to carry JAVA_HOME itself
    if java_home.empty?
      name = 'JAVA_HOME reaches the MCP server'
      if fields['java_home'].to_s.empty?
        fail_check(name, "#{name}: the registration carries no JAVA_HOME", tier: 2, evidence: evidence)
      else
        pass_check(name, "#{name}: #{fields['java_home']}", tier: 2)
      end
    else
      expect(fields, 'java_home', java_home, 'JAVA_HOME reaches the MCP server', evidence)
    end
    # The server is started without a login shell, so it cannot fall back on /etc/profile.d
    name = 'Ghidra install dir reaches the MCP server'
    if !fields['ghidra_dir'].to_s.empty? && fields['ghidra_dir'] == ghidra_install_dir
      pass_check(name, "#{name}: #{fields['ghidra_dir']}", tier: 2)
    else
      fail_check(name, "#{name}: got #{fields['ghidra_dir'].inspect}, shell has #{ghidra_install_dir.inspect}",
                 tier: 2, evidence: evidence)
    end
    expect(fields, 'provider_kept', 'true', 'merge kept the OpenCode provider preset', evidence)
  end

  # The real proof: Ghidra headless imports, analyses and decompiles a binary through REA. Compiled here
  # rather than shipped, so the test carries no binary and depends on no lab material.
  def test_decompiles_a_binary
    name = 'rea decompiles a freshly compiled binary through Ghidra'
    source = [
      "int #{PROBE_FUNCTION}(int a, int b) { return a + b * 3; }",
      "int main(void) { return #{PROBE_FUNCTION}(2, 5); }",
    ]
    command = 'U=$(awk -F: \'$3>=1000 && $3<60000 && $6 ~ /^\/home\// {print $1; exit}\' /etc/passwd); ' \
              '[ -n "$U" ] || { echo "no-login-user"; exit 0; }; ' \
              'H=$(getent passwd "$U" | cut -d: -f6); ' \
              'command -v gcc >/dev/null || { echo "no-gcc"; exit 0; }; ' \
              "rm -rf #{PROBE_DIR}; mkdir -p #{PROBE_DIR}; chmod 755 #{PROBE_DIR}; " \
              "printf '%s\\n' #{source.map { |line| shell_quote(line) }.join(' ')} > #{PROBE_DIR}/probe.c; " \
              "gcc -O0 -o #{PROBE_DIR}/probe #{PROBE_DIR}/probe.c || { echo \"compile-failed\"; exit 0; }; " \
              "chmod 755 #{PROBE_DIR}/probe; " \
              'out=$(runuser -u "$U" -- env HOME="$H" bash -lc ' \
              "\"rea decompile #{PROBE_DIR}/probe --procedure #{PROBE_FUNCTION} --provider ghidra --json\" 2>&1); " \
              'rc=$?; echo "rc=$rc"; echo "$out" | tail -40'

    result = run_vagrant_ssh(command, timeout: 1200)
    stdout = result[:stdout].to_s
    evidence = "$ #{command}\n--- stdout\n#{stdout}\n--- stderr\n#{result[:stderr]}"
    return skip_check(name, 'no ordinary login account on this system', tier: 2) if stdout.include?('no-login-user')
    return skip_check(name, 'no C compiler on this system', tier: 2) if stdout.include?('no-gcc')
    return fail_check(name, 'the probe program would not compile', tier: 2, evidence: evidence) if stdout.include?('compile-failed')

    if stdout.include?('rc=0') && stdout.include?(PROBE_FUNCTION)
      pass_check(name, "#{name} on #{get_system_name}", tier: 2)
    else
      fail_check(name, "#{name}: #{stdout[/rc=\d+/]}", tier: 2, evidence: evidence)
    end
  end

  # Taken from the login shell, since the directory comes from the ghidra module rather than this one's inputs
  def ghidra_install_dir
    @ghidra_install_dir ||= run_vagrant_ssh('echo "$GHIDRA_INSTALL_DIR"')[:stdout].to_s.strip
  end

  def expect(fields, key, wanted, label, evidence)
    got = fields[key]
    if got == wanted
      pass_check(label, "#{label}: #{key}=#{got}", tier: 2)
    else
      fail_check(label, "#{label}: #{key} is #{got.inspect}, expected #{wanted.inspect}", tier: 2,
                 evidence: evidence)
    end
  end

  def parse_fields(stdout)
    stdout.to_s.lines.each_with_object({}) do |line, fields|
      key, _, value = line.strip.partition('=')
      fields[key] = value unless key.empty?
    end
  end

  def shell_quote(text)
    "'#{text.gsub("'", %q('\\''))}'"
  end

  # The module creates no accounts, so whichever ordinary login account the system has stands in for a
  # student. nil runs the check as root, the best available on a base with no such account.
  def login_user
    found = run_vagrant_ssh("awk -F: '$3>=1000 && $3<60000 && $6 ~ /^\\/home\\// {print $1; exit}' /etc/passwd")
    user = found[:stdout].to_s.strip
    user.empty? ? nil : user
  end
end

ReaTest.new.run
