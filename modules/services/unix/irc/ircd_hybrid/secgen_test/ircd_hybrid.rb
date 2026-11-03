require_relative '../../../../../lib/post_provision_test'

class IrcdHybridTest < PostProvisionTest
  def initialize
    self.module_name = 'ircd_hybrid'
    self.module_path = get_module_path(__FILE__)
    super
    self.port = 6667 # module has no port input; ircd-hybrid's default
  end

  def test_module
    super
    # Tier 1: package installed and service running
    test_local_command('ircd-hybrid package', 'dpkg -s ircd-hybrid', 'Status: install ok installed', tier: 1)
    test_local_command('ircd-hybrid service', 'systemctl is-active ircd-hybrid | grep -x active', 'active', tier: 1)
    test_local_command('ircd.conf present', 'test -s /etc/ircd-hybrid/ircd.conf && echo ok', 'ok', tier: 1)
    test_local_command('init script DEFAULT bug patched', 'grep -c "^DEFAULT=" /etc/init.d/ircd-hybrid', '1', tier: 1)
    test_local_command('service enabled', 'systemctl is-enabled ircd-hybrid', 'enabled', tier: 1)
    # No read_facts or default_inputs: nothing parameterised to check.
    # Tier 2: IRC port open and the daemon greets with its AUTH notices
    test_service_up
    test_banner('NOTICE', label: 'ircd-hybrid greets with an IRC NOTICE')
    # a client can register and gets the welcome numeric. ircd-hybrid does an ident
    # lookup first ("Checking Ident" ... "No Ident response") and only sends 001 once
    # that times out, so read until 001 arrives (up to 30s) rather than a fixed 3s window.
    test_local_command('IRC registration welcomed',
                       %q{timeout 40 bash -c 'exec 3<>/dev/tcp/127.0.0.1/6667; printf "NICK secgen\r\nUSER secgen 0 * :secgen\r\n" >&3; while read -r -t 30 line <&3; do echo "$line"; case "$line" in *" 001 "*) break;; esac; done' 2>/dev/null | head -c 2000},
                       ' 001 ', tier: 2)
  end
end

IrcdHybridTest.new.run
