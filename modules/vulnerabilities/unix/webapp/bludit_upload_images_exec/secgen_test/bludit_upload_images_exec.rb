require_relative '../../../../../lib/post_provision_test'

# Bludit 3.9.2 (CVE-2019-16113) on patched PHP 7.4 (php7_patched).
# tier 2 proves Bludit serves via Apache -> php-fpm and that the php2shell fix
# is present, so only CVE-2019-16113 (authenticated image upload RCE) is
# exploitable. tier 3 runs the MSF module from an attacker VM using the
# known_username/known_password inputs; with no attacker sibling it SKIPs.
class BluditTest < PostProvisionTest
  FIX_COMMIT = '712e60f9edfd03f0960fc4fc3c2c375f42b90aa2'.freeze
  DOCROOT    = '/var/www/bludit-3-9-2'.freeze

  def initialize
    self.module_name = 'bludit_upload_images_exec'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    tier(1) do
      test_local_command('bludit docroot exists', "test -d #{DOCROOT} && echo ok", 'ok')
      test_local_command('apache2 installed', 'dpkg -l apache2 | grep -E "^ii"', 'apache2')
      test_local_command('patched php present', 'test -x /opt/php-7.4-patched/bin/php && echo ok', 'ok')
    end

    tier(2) do
      test_service_up
      # Body-match retry — curl %{http_code} is eaten by the guest-agent exec
      # path. Bludit renders a generator meta tag on every page; the site title
      # is randomised so <title>Bludit</title> never matches.
      test_local_command('bludit serves (Apache+php-fpm)',
                         "for i in $(seq 1 15); do curl -s http://127.0.0.1:#{self.port}/ | grep -q 'content=\"Bludit\"' && { echo SERVED_BLUDIT; break; }; sleep 2; done",
                         'SERVED_BLUDIT')
      test_local_command('php2shell fix present (CVE-2026-109618/109619)',
                         'cat /opt/php-7.4-patched/PHP2SHELL_FIX_COMMIT', FIX_COMMIT)
    end

    tier(3) do
      # Credentials are parameterised — read them from the module's inputs.
      username = self.json_inputs['known_username']&.first || 'admin'
      password = self.json_inputs['known_password']&.first

      if password.nil? || password.empty?
        skip_check('msf exploit (bludit_upload_images_exec)',
                   'known_password input not available; cannot authenticate',
                   tier: 3, evidence: nil)
        next
      end

      # TARGETURI is / — the Apache vhost docroot IS the Bludit app directory,
      # so the app is served from / not /bludit.
      # php/unix/cmd/generic: PHP-platform no-session payload (same as gravcms_exec).
      # AllowNoCleanup: php/unix/cmd/generic leaves uploaded PHP stubs behind;
      # without this flag MSF refuses to run the exploit.
      test_msf_exploit('exploit/linux/http/bludit_upload_images_exec',
                       rport: self.port,
                       payload: 'php/unix/cmd/generic',
                       options: {
                         'TARGETURI'       => '/',
                         'BLUDITUSER'      => username,
                         'BLUDITPASS'      => password,
                         'AllowNoCleanup'  => 'true',
                       },
                       collect: "cat #{DOCROOT}/bl-content/tmp/* 2>/dev/null",
                       tier: 3)
    end
  end
end

BluditTest.new.run
