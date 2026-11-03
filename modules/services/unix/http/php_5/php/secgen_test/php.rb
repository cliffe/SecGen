require_relative '../../../../../lib/post_provision_test'

class Php5Test < PostProvisionTest
  def initialize
    self.module_name = 'php'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) { test_local_command('php installed?', 'php --version', 'PHP 5') }
    %w[php5.6 php5.6-mysql php5.6-cli php5.6-common php5.6-curl php5.6-mbstring php5.6-xml ca-certificates apt-transport-https].each do |pkg|
      tier(1) { test_local_command("#{pkg} installed", "dpkg -s #{pkg}", 'Status: install ok installed') }
    end
    tier(1) { test_local_command('php7.0-common removed', 'dpkg -s php7.0-common 2>&1', 'not installed') }
    tier(1) { test_local_command('sury repo configured', 'cat /etc/apt/sources.list.d/php.list', 'packages.sury.org') }
    tier(1) { test_local_command('sury apt key present', 'test -s /etc/apt/trusted.gpg.d/php.gpg && echo ok', 'ok') }
    tier(2) { test_command_succeeds('php -r works', 'php -r "echo phpversion();"') }
    # the CLI really is 5.6 and the extensions the packages provide load
    tier(2) { test_local_command('php runs as 5.6', 'php -r "echo PHP_MAJOR_VERSION . \".\" . PHP_MINOR_VERSION;"', '5.6') }
    %w[mysql curl mbstring xml].each do |ext|
      tier(2) { test_local_command("php extension #{ext} loads", 'php -m', ext) }
    end
  end
end

Php5Test.new.run
