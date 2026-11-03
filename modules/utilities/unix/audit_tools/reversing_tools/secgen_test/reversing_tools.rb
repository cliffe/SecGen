require_relative '../../../../../lib/post_provision_test'

class ReversingToolsTest < PostProvisionTest
  def initialize
    self.module_name = 'reversing_tools'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    osr = run_vagrant_ssh('. /etc/os-release; echo "$ID ${VERSION_ID%%.*}"')[:stdout].split
    kali = osr[0] == 'kali'
    # pwntools, radare2 and GEF are installed on Kali and Debian 12+ only, as in the Puppet
    modern = kali || (osr[0] == 'debian' && osr[1].to_i >= 12)

    tier(1) do
      test_local_command('gdb installed?', 'which gdb', 'gdb')
      %w[gdb git ltrace strace valgrind pax-utils binwalk vbindiff ssdeep gcc-multilib yara nmap].each do |pkg|
        test_local_command("#{pkg} package installed?", "dpkg -l #{pkg} | grep '^ii'", pkg)
      end
      test_local_command('upx installed?', 'test -x /usr/local/bin/upx && echo "ok"', 'ok')
      # procyon-decompiler is skipped on Kali (removed from kali-rolling)
      test_local_command('procyon installed?', 'dpkg -l procyon-decompiler | grep "^ii"', 'procyon') unless kali
      if modern
        test_local_command('pwntools installed?', 'dpkg -l python3-pwntools | grep "^ii"', 'pwntools')
        test_local_command('radare2 installed?', 'which radare2', 'radare2')
        test_local_command('gef script present', 'test -f /opt/gef/gef.py && echo "ok"', 'ok')
        test_local_command('gef launcher present', 'test -x /usr/local/bin/gef && echo "ok"', 'ok')
      end
      test_local_command('cutter AppImage deployed', 'test -x /opt/Cutter/Cutter-v1.7.2-x86_64.Linux.AppImage && echo "ok"', 'ok')
      test_local_command('cutter launcher present', 'test -x /usr/local/bin/cutter && echo "ok"', 'ok')
    end

    tier(2) do
      test_command_succeeds('gdb reports version', 'gdb --version')
      # -V works on every strace; --version only from 5.x (buster has 4.26)
      test_command_succeeds('strace available', 'strace -V')
      test_local_command('upx runs', 'test -x /usr/local/bin/upx && /usr/local/bin/upx --version 2>&1', 'upx')
      test_local_command('ltrace runs', 'command -v ltrace >/dev/null && ltrace --version 2>&1', 'ltrace')
      test_local_command('valgrind runs', 'command -v valgrind >/dev/null && valgrind --version 2>&1', 'valgrind')
      test_local_command('scanelf (pax-utils) runs', 'command -v scanelf >/dev/null && scanelf -V 2>&1', 'scanelf')
      test_local_command('binwalk runs', 'command -v binwalk >/dev/null && binwalk --help 2>&1', 'inwalk')
      test_local_command('vbindiff runs', 'command -v vbindiff >/dev/null && vbindiff --help 2>&1; true', 'vbindiff')
      test_local_command('ssdeep runs', 'ssdeep -V 2>&1', '.')
      test_local_command('yara runs', 'yara --version 2>&1', '.')
      test_local_command('nmap runs', 'nmap --version 2>&1', 'Nmap')
      test_local_command('procyon runs', 'command -v procyon >/dev/null && procyon --help 2>&1', 'Usage: procyon') unless kali
      if modern
        test_local_command('radare2 runs', 'command -v radare2 >/dev/null && radare2 -v 2>&1', 'radare2')
        test_local_command('pwntools imports', "python3 -c 'import pwn; print(\"pwn-import-ok\")'", 'pwn-import-ok')
        # gef loads into gdb and reports its version
        test_local_command('gef loads in gdb', 'gef -batch -ex "gef help" 2>&1', 'GEF')
      end
      test_cutter
    end
  end

  # Cutter is a GUI, so it runs on the display manager's X server (:0) with that server's auth cookie.
  # As a non-root account it opens /bin/true, runs `aaa` analysis and must still be up when timeout stops
  # it (exit 124). On a base with no X server it can only be checked as far as connecting to a display.
  def test_cutter
    xauth = 'ps -C Xorg -o args= | sed -n "s/.* -auth \\([^ ]*\\).*/\\1/p" | head -1'
    if run_vagrant_ssh(xauth)[:stdout].strip.empty?
      test_local_command('cutter loads (no X server on this base)', 'cd /tmp && env -u DISPLAY cutter --version 2>&1', 'Could not connect to any X display')
      return
    end
    x = "A=$(#{xauth}); export DISPLAY=:0 XAUTHORITY=\"$A\"; cd /tmp; "
    test_local_command('cutter reports its version', "#{x}cutter --version 2>&1", 'Cutter 1.7.2')

    cmd = "#{x}U=$(awk -F: '$3>=1000 && $3<65534 && $6 ~ /^\\/home\\// {print $1; exit}' /etc/passwd); " \
          'H=$(getent passwd "$U" | cut -d: -f6); T=$(mktemp); cp "$A" "$T"; chown "$U" "$T"; ' \
          'out=$(runuser -u "$U" -- env DISPLAY=:0 XAUTHORITY="$T" HOME="$H" timeout 45 cutter -A 1 /bin/true 2>&1); rc=$?; ' \
          'rm -f "$T"; pkill -u "$U" -f /opt/Cutter/squashfs-root; ' \
          'echo "$out" | grep -v "^/tmp/appimage" | tail -25; echo "user=$U rc=$rc"; ' \
          'echo "$out" | grep -q "(aac)" && [ "$rc" = 124 ] && echo "cutter analysed /bin/true"'
    name = 'cutter opens and analyses a binary as a user'
    out = run_vagrant_ssh(cmd, timeout: 90)
    if out[:stdout].include?('cutter analysed /bin/true')
      pass_check(name, "#{name} (#{out[:stdout][/user=\S+/]}) on #{get_system_name}")
    else
      fail_check(name, "#{name} on #{get_system_name}: #{out[:stdout][/user=\S+ rc=\d+/]}",
                 evidence: "$ #{cmd}\n--- stdout\n#{out[:stdout]}\n--- stderr\n#{out[:stderr]}")
    end
  end
end

ReversingToolsTest.new.run
