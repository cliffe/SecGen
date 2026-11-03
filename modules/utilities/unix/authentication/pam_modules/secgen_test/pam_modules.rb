require_relative '../../../../../lib/post_provision_test'

class PamModulesTest < PostProvisionTest
  # Every package install.pp installs (module has no inputs)
  PACKAGES = %w[libpam-abl libpam-google-authenticator libpam-oath libqrencode4 pamtester
                libpam-mount libpam-encfs libpam-fscrypt libpam-passwdqc libpam-pwdfile libpam-pwquality].freeze
  # PAM module shared objects those packages provide
  PAM_SOS = %w[pam_abl.so pam_google_authenticator.so pam_oath.so pam_mount.so pam_encfs.so
               pam_fscrypt.so pam_passwdqc.so pam_pwdfile.so pam_pwquality.so].freeze

  def initialize
    self.module_name = 'pam_modules'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('libpam-google-authenticator installed',
                         'dpkg -l libpam-google-authenticator | grep -E "^ii"',
                         'libpam-google-authenticator')
      test_local_command('pamtester installed', 'dpkg -l pamtester | grep -E "^ii"', 'pamtester')
      test_local_command('libpam-pwquality installed',
                         'dpkg -l libpam-pwquality | grep -E "^ii"',
                         'libpam-pwquality')
      PACKAGES.each do |pkg|
        test_local_command("#{pkg} package installed", "dpkg-query -W -f='${Status}' #{pkg}", 'install ok installed')
      end
      PAM_SOS.each do |so|
        test_local_command("#{so} present", "ls /lib/*/security/#{so} /usr/lib/*/security/#{so} 2>/dev/null", so)
      end
    end
    tier(2) do
      test_local_command('pamtester on PATH', 'which pamtester', 'pamtester')
      test_command_succeeds('google-authenticator binary present', 'test -f /usr/bin/google-authenticator')
      # pamtester drives a real PAM stack: a throwaway service using pam_permit must authenticate root
      test_local_command('pamtester authenticates against a PAM service',
                         'echo "auth required pam_permit.so" > /etc/pam.d/secgen-test-service; ' \
                         'pamtester secgen-test-service root authenticate 2>&1; rm -f /etc/pam.d/secgen-test-service',
                         'successfully authenticated')
      # google-authenticator prints usage on --help (exit status varies by version)
      test_local_command('google-authenticator runs', 'command -v google-authenticator >/dev/null && google-authenticator --help 2>&1', 'google-authenticator')
      # every PAM module loads: no unresolved shared libraries
      PAM_SOS.each do |so|
        test_command_succeeds("#{so} links cleanly",
                              "f=$(ls /lib/*/security/#{so} /usr/lib/*/security/#{so} 2>/dev/null | head -1); test -n \"$f\" && ! ldd \"$f\" | grep -q 'not found'")
      end
    end
  end
end

PamModulesTest.new.run
