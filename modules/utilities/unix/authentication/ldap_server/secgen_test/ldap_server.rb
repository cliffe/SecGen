require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class LdapServerTest < PostProvisionTest
  def initialize
    self.module_name = 'ldap_server'
    self.module_path = get_module_path(__FILE__)
    super
    # slapd's own protocol port; the module has no port input, so the base
    # class would otherwise leave this unset (-1) and skip the port check.
    self.port = 389
  end

  def test_module
    super
    tier(1) do
      test_local_command('slapd installed', 'dpkg -l slapd | grep -E "^ii"', 'slapd')
      test_local_command('ldap-utils installed', 'dpkg -l ldap-utils | grep -E "^ii"', 'ldap-utils')
      test_local_command('phpldapadmin installed', 'dpkg -l phpldapadmin | grep -E "^ii"', 'phpldapadmin')
    end

    # domain -> base DN, as the module derives it (example.com -> dc=example,dc=com)
    domain = self.json_inputs['domain']&.first
    base_dn = domain && domain.split('.').map { |c| "dc=#{c}" }.join(',')
    organization = self.json_inputs['organization']&.first
    admin_password = self.json_inputs['admin_password']&.first

    # what the module configures besides packages: slapd enabled, PHP and phpLDAPadmin conf in Apache, auto UID/GID ranges
    tier(1) do
      test_local_command('slapd enabled at boot', 'systemctl is-enabled slapd', 'enabled')
      test_local_command('Apache includes conf-enabled', 'grep conf-enabled /etc/apache2/apache2.conf', 'conf-enabled')
      test_local_command('phpldapadmin Apache conf enabled', 'ls /etc/apache2/conf-enabled/', 'phpldapadmin.conf')
      test_local_command('Apache PHP module enabled', 'ls /etc/apache2/mods-enabled/', 'php')
      test_local_command('phpldapadmin Apache 2.4 syntax', 'grep -c "Order allow,deny" /etc/apache2/conf-available/phpldapadmin.conf | grep -x 0', '0')
      test_local_command('phpldapadmin auto UID/GID start', 'grep auto_number /etc/phpldapadmin/config.php', "'uidNumber'=>10000,'gidNumber'=>5000")
      %w[ldapsearch ldapadd ldapmodify ldapdelete].each do |bin|
        test_local_command("#{bin} on PATH", "command -v #{bin}", bin)
      end
    end

    if base_dn
      # phpLDAPadmin is pointed at the configured base DN
      tier(1) do
        test_local_command("phpldapadmin config uses #{base_dn}",
                           'grep -F "server\',\'base\'" /etc/phpldapadmin/config.php', base_dn)
      end
    end

    tier(2) do
      test_service_up
      test_local_command('slapd service active', 'systemctl is-active slapd | grep -x active', 'active')
      test_local_command('apache2 service active', 'systemctl is-active apache2 | grep -x active', 'active')
      if base_dn
        test_local_command("base DN #{base_dn} in naming contexts",
                           "ldapsearch -x -H ldap://localhost -b '' -s base namingContexts 2>&1",
                           base_dn)
      else
        test_local_command('slapd answers ldap queries', 'ldapsearch -x -H ldap://localhost -b "" -s base namingContexts 2>&1', 'result:')
      end

      # organization is stored on the base entry's "o" attribute
      if base_dn && organization
        test_local_command("organization '#{organization}' on #{base_dn}",
                           "ldapsearch -x -LLL -H ldap://localhost -b #{Shellwords.escape(base_dn)} -s base o 2>&1",
                           "o: #{organization}")
      end

      # the generated admin password lets cn=admin bind (password read from stdin, not argv)
      if base_dn && admin_password
        admin_dn = "cn=admin,#{base_dn}"
        test_local_command("admin password binds as #{admin_dn}",
                           "printf %s #{Shellwords.escape(admin_password)} | ldapwhoami -x -H ldap://localhost -D #{Shellwords.escape(admin_dn)} -y /dev/stdin 2>&1",
                           "dn:#{admin_dn}")
      end

      # phpLDAPadmin web interface served by Apache
      test_http('/phpldapadmin/', port: 80, match: 'phpLDAPadmin', label: 'phpLDAPadmin web interface')
    end
  end
end

LdapServerTest.new.run
