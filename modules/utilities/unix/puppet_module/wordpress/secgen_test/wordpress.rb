require_relative '../../../../../lib/post_provision_test'

class WordpressTest < PostProvisionTest
  INSTALL_DIR = '/opt/wordpress'

  def initialize
    self.module_name = 'wordpress'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # No SecGen inputs. The install directory is a class parameter: /opt/wordpress by
    # default, but a module using this library can set its own (wordpress_4x uses
    # /var/www/wordpress), so test wherever WordPress actually is.
    found = run_command("find /opt /var/www /srv -maxdepth 3 -path '*/wp-includes/version.php' 2>/dev/null | head -1")[:stdout].to_s.strip
    dir = found.empty? ? INSTALL_DIR : File.dirname(File.dirname(found))
    tier(1) do
      test_local_command('wordpress directory exists', "test -d #{dir} && echo ok", 'ok')
      test_local_command('wp-config.php present', "test -f #{dir}/wp-config.php && echo ok", 'ok')
    end
    tier(1) do
      %w[wp-admin wp-content wp-includes].each do |d|
        test_local_command("wordpress #{d} directory present", "test -d #{dir}/#{d} && echo ok", 'ok')
      end
      test_local_command('wordpress version.php present',
                         "test -f #{dir}/wp-includes/version.php && echo ok", 'ok')
      test_local_command('wp-keysalts.php generated', "test -f #{dir}/wp-keysalts.php && echo ok", 'ok')
      test_local_command('wp-config.php defines database settings',
                         "grep -c \"DB_NAME\\|DB_USER\\|DB_PASSWORD\\|DB_HOST\" #{dir}/wp-config.php | grep -qv '^0$' && echo ok",
                         'ok')
    end
    tier(2) do
      test_local_command('wordpress index.php present', "test -f #{dir}/index.php && echo ok", 'ok')
      test_local_command('wordpress version is set',
                         "grep -E \"^[$]wp_version = '[0-9.]+';\" #{dir}/wp-includes/version.php", 'wp_version')
      # PHP is installed by the web server module, so lint only if it is present
      if run_command('command -v php')[:stdout].include?('php')
        test_command_succeeds('wp-config.php is valid PHP', "php -l #{dir}/wp-config.php")
        test_command_succeeds('wp-includes/version.php is valid PHP', "php -l #{dir}/wp-includes/version.php")
      else
        skip_check('wordpress PHP lint', 'php not installed on this system', tier: 2, evidence: nil)
      end
    end
  end
end

WordpressTest.new.run
