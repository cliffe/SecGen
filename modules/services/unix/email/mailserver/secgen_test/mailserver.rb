require_relative '../../../../../lib/post_provision_test'

class MailserverTest < PostProvisionTest
  SMTP_PORT = 25
  IMAP_PORT = 143

  def initialize
    self.module_name = 'mailserver'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Inputs: server_ip is the postfix hostname the module is meant to set (a
  # name or IP for this mail server, despite the input name), so it is checked
  # below. The SMTP and IMAP ports are not inputs.
  def test_module
    super
    server_ip = self.json_inputs['server_ip']&.first

    tier(1) do
      test_local_command('postfix installed', 'dpkg -s postfix | grep ^Status', 'install ok installed')
      test_local_command('dovecot-imapd installed', 'dpkg -s dovecot-imapd | grep ^Status', 'install ok installed')
      test_local_command('dovecot-core installed', 'dpkg -s dovecot-core | grep ^Status', 'install ok installed')
      test_local_command('postfix disable_dns_lookups', 'grep -E "^disable_dns_lookups" /etc/postfix/main.cf', 'disable_dns_lookups=yes')
      test_local_command('/var/mail is world-writable', 'stat -c %a /var/mail', '777')
      test_local_command('postfix enabled at boot', 'systemctl is-enabled postfix', 'enabled')
      test_local_command('dovecot enabled at boot', 'systemctl is-enabled dovecot', 'enabled')
      test_local_command('dovecot plaintext auth enabled', 'cat /etc/dovecot/dovecot.conf', 'disable_plaintext_auth = no')
      # main.cf edits: no TLS on SMTP, local networks only
      test_local_command('postfix smtpd_use_tls off', 'postconf -h smtpd_use_tls', 'no')
      test_local_command('postfix mynetworks set', 'postconf -h mynetworks', '127.0.0.0/8')
      # the configured server name becomes postfix's hostname
      if server_ip
        test_local_command('postfix myhostname is server_ip', 'postconf -h myhostname', server_ip)
      end
    end

    tier(2) do
      # The module has no port input, so pass the ports explicitly.
      test_service_up(port: SMTP_PORT)
      test_service_up(port: IMAP_PORT)
      test_banner('220 ', port: SMTP_PORT, label: 'postfix SMTP greeting')
      test_banner('* OK', port: IMAP_PORT, label: 'dovecot IMAP greeting')
      # both daemons answer a real command, not just the greeting
      test_banner('250', port: SMTP_PORT, send: 'EHLO test.local', label: 'SMTP EHLO reply')
      test_banner('a1 OK', port: IMAP_PORT, send: 'a1 CAPABILITY', label: 'IMAP CAPABILITY reply')
      # the SMTP greeting names the configured host
      test_banner("220 #{server_ip}", port: SMTP_PORT, label: 'SMTP greeting names server_ip') if server_ip
    end
    # No tier 3: a service module has no intended vulnerability to exploit.
  end
end

MailserverTest.new.run
