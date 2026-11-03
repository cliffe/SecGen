require_relative '../../../../../lib/post_provision_test'

class PhishMeWebsiteTest < PostProvisionTest
  DOCROOT = '/var/www/accountingnow'

  def initialize
    self.module_name = 'phish_me_website'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('apache2 installed', 'dpkg -l apache2 | grep -E "^ii"', 'apache2')
      test_local_command('apache2 running', 'systemctl is-active apache2 | grep -x active', 'active')
      # bundled site files copied into the docroot
      %w[index.html login.html about.html apply.html services.html team.html vacancies.html friendface.html main.html
         Action/login.php Action/apply.php].each do |file|
        test_local_command("#{file} deployed", "test -s #{DOCROOT}/#{file} && echo ok", 'ok')
      end
      %w[css js images fonts people].each do |dir|
        test_local_command("#{dir}/ deployed", "test -d #{DOCROOT}/#{dir} && echo ok", 'ok')
      end
      # the vhost listens on the configured port (-R: sites-enabled entries are symlinks, which -r skips)
      if self.port.to_i > 0
        test_local_command('vhost uses the configured port',
                           "grep -RhE 'VirtualHost' /etc/apache2/sites-enabled/", ":#{self.port}>")
      end
      # the distribution default site is removed (Tidy resource)
      test_local_command('default site removed', 'test ! -e /etc/apache2/sites-enabled/000-default.conf && echo gone', 'gone')
    end
    tier(2) do
      test_service_up
      test_http('/index.html', match: 'AccountingNow')
      test_http('/login.html', match: 'AccountingNow')
      test_local_command('login.php runs as PHP', "curl -s http://127.0.0.1:#{self.port.to_i > 0 ? self.port : 80}/Action/login.php | grep -x 'Wrong credentials!'", 'Wrong credentials!')
    end
  end
end

PhishMeWebsiteTest.new.run
