require_relative '../../../../../lib/post_provision_test'

class Php7Test < PostProvisionTest
  def initialize
    self.module_name = 'php7'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # No read_facts or default inputs: nothing to parameterise.
  def test_module
    super
    tier(1) do
      test_local_command('php7.4 installed?', 'dpkg -l php7.4-cli | grep -E "^ii"', 'php7.4-cli')
      test_local_command('sury repo configured?', 'test -f /etc/apt/sources.list.d/php7-sury.list && echo ok', 'ok')
      test_local_command('sury apt key present', 'test -s /etc/apt/trusted.gpg.d/php7-sury.gpg && echo ok', 'ok')
      %w[php7.4 php7.4-common php7.4-mbstring php7.4-curl php7.4-xml php7.4-zip php7.4-gd libapache2-mod-php7.4].each do |pkg|
        test_local_command("#{pkg} installed?", "dpkg -l #{pkg} | grep -E '^ii'", pkg)
      end
      test_local_command('apache php 7.4 handler module present', 'test -f /usr/lib/apache2/modules/libphp7.4.so && echo ok', 'ok')
      test_local_command('php CLI alternative points at 7.4', 'readlink -f /usr/bin/php', '/usr/bin/php7.4')
    end
    tier(2) do
      test_command_succeeds('php7.4 version', 'php7.4 --version')
      test_local_command('default php CLI is 7.4', 'php --version', 'PHP 7.4')
      test_local_command('default php CLI is 7.4 for an unprivileged user', 'php -r "echo PHP_VERSION;"', '7.4', user: 'nobody')
      %w[mbstring curl xml zip gd].each do |ext|
        test_local_command("php extension #{ext} loaded", "php -m | grep -ix #{ext}", ext, user: 'nobody')
      end
      test_local_command('php runs code using mbstring', 'php -r "echo mb_strtoupper(\'hello-php\');"', 'HELLO-PHP', user: 'nobody')
    end
  end
end

Php7Test.new.run
