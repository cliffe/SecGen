require_relative '../../../../../lib/post_provision_test'

class LdapPackagesTest < PostProvisionTest
  # Every package install.pp asks for (module has no inputs). libnss-ldapd/libpam-ldapd
  # replace libnss-ldap/libpam-ldap, which Debian 12 does not have.
  PACKAGES = %w[ldap-utils libnss-ldapd libpam-ldapd nslcd nscd sssd].freeze

  def initialize
    self.module_name = 'ldap_packages'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('ldap-utils installed', 'dpkg -l ldap-utils | grep -E "^ii"', 'ldap-utils')
      test_local_command('nslcd installed', 'dpkg -l nslcd | grep -E "^ii"', 'nslcd')
      test_local_command('sssd installed', 'dpkg -l sssd | grep -E "^ii"', 'sssd')
      PACKAGES.each do |pkg|
        test_local_command("#{pkg} package installed", "dpkg-query -W -f='${Status}' #{pkg}", 'install ok installed')
      end
      %w[ldapsearch ldapadd ldapmodify ldapdelete ldapwhoami ldappasswd nslcd nscd sssd].each do |bin|
        test_local_command("#{bin} present", "command -v #{bin} || ls /usr/sbin/#{bin}", bin)
      end
      test_local_command('libnss_ldap present', 'ls /lib/*/libnss_ldap.so.2 /usr/lib/*/libnss_ldap.so.2 2>/dev/null', 'libnss_ldap.so.2')
      test_local_command('pam_ldap present', 'ls /lib/*/security/pam_ldap.so /usr/lib/*/security/pam_ldap.so 2>/dev/null', 'pam_ldap.so')
    end
    tier(2) do
      test_command_succeeds('ldapsearch available', "ldapsearch --help 2>&1 | grep -q 'usage: ldapsearch'")
      test_local_command('ldapsearch on PATH', 'which ldapsearch', 'ldapsearch')
      # the --help check above always exits 0 (|| true); these fail on a broken binary or missing library
      test_command_succeeds('ldapsearch runs', 'ldapsearch -VV')
      test_command_succeeds('ldapwhoami runs', 'ldapwhoami -VV')
      test_command_succeeds('ldapadd runs', 'ldapadd -VV')
      test_command_succeeds('nslcd runs', 'nslcd --version')
      test_command_succeeds('nscd runs', 'nscd --version')
      test_command_succeeds('sssd runs', 'sssd --version')
      # a real query: with no server given, ldapsearch must reach the "can't contact" stage, not crash
      test_local_command('ldapsearch attempts a query', 'ldapsearch -x -H ldap://127.0.0.1:1 -b "" -s base 2>&1', "Can't contact LDAP server")
      test_command_succeeds('libnss_ldap links cleanly',
                            'f=$(ls /lib/*/libnss_ldap.so.2 /usr/lib/*/libnss_ldap.so.2 2>/dev/null | head -1); test -n "$f" && ! ldd "$f" | grep -q "not found"')
      test_command_succeeds('pam_ldap links cleanly',
                            'f=$(ls /lib/*/security/pam_ldap.so /usr/lib/*/security/pam_ldap.so 2>/dev/null | head -1); test -n "$f" && ! ldd "$f" | grep -q "not found"')
    end
  end
end

LdapPackagesTest.new.run
