require_relative '../../../../../lib/post_provision_test'

class GhidraTest < PostProvisionTest
  def initialize
    self.module_name = 'ghidra'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No inputs. The Puppet differs by base: Kali downloads Ghidra at build time and sets up the gdb debugger
  # packages; the Debian bases ship a bundled release. Checks for the Kali-only parts are guarded on the base.
  def test_module
    super
    kali = run_command('grep -qi "^ID=kali" /etc/os-release && echo kali')[:stdout].to_s.include?('kali')

    tier(1) do
      test_local_command('ghidra installed?', 'ls /opt/ghidra/ghidraRun /usr/local/bin/ghidra', '/usr/local/bin/ghidra')
      test_local_command('/usr/local/bin/ghidra links to ghidraRun', 'readlink /usr/local/bin/ghidra', '/opt/ghidra/ghidraRun')
      test_command_succeeds('ghidraRun is executable', 'test -x /opt/ghidra/ghidraRun', tier: 1)
      test_local_command('headless analyser present', 'test -x /opt/ghidra/support/analyzeHeadless && echo ok', 'ok')
      test_local_command('desktop launcher runs ghidraRun', 'cat /usr/share/applications/ghidra.desktop', 'ghidraRun')
      test_local_command('zip installed', 'command -v zip', '/zip')
      test_local_command('a JDK is installed', 'command -v java javac', '/javac')
      if kali
        %w[openjdk-21-jre openjdk-21-jdk curl unzip gdb python3-pip].each do |pkg|
          test_local_command("#{pkg} installed", "dpkg -l #{pkg} | grep -E \"^ii\"", pkg)
        end
        test_local_command('/opt/ghidra links to the versioned install', 'readlink /opt/ghidra', '/opt/ghidra_')
        test_local_command('launch.properties pins JDK 21', 'grep "^JAVA_HOME_OVERRIDE=" /opt/ghidra/support/launch.properties', 'java-21-openjdk')
      end
    end

    tier(2) do
      # the headless analyser starts under the installed JDK and prints its usage when given no arguments
      test_local_command('analyzeHeadless runs', 'timeout 120 /opt/ghidra/support/analyzeHeadless 2>&1', 'Headless Analyzer Usage')
      # the same, as an unprivileged user. Ghidra's LaunchSupport takes Java's user.home (from the passwd entry,
      # /nonexistent for nobody), not $HOME, and exits if it is missing; so point user.home at a scratch directory
      # (JAVA_TOOL_OPTIONS reaches both LaunchSupport and the Ghidra JVM) where Ghidra can write its settings.
      test_local_command('analyzeHeadless runs as an unprivileged user',
                         'export HOME=$(mktemp -d); export JAVA_TOOL_OPTIONS="-Duser.home=$HOME"; timeout 120 /opt/ghidra/support/analyzeHeadless 2>&1', 'Headless Analyzer Usage', user: 'nobody')
      test_command_succeeds('java runs as an unprivileged user', 'java -version', user: 'nobody')
      if kali
        # the debugger's gdb python packages were installed into gdb's embedded python
        test_local_command('gdb can import the Ghidra debugger packages',
                           'gdb -batch -ex "python import ghidragdb, ghidratrace; print(\'GHIDRA_GDB_OK\')" 2>&1', 'GHIDRA_GDB_OK')
      end
    end
  end
end

GhidraTest.new.run
