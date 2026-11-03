require_relative '../../../../../lib/post_provision_test'
require 'shellwords'
require 'json'

# Each `mail` input is a JSON message (sender_user, sender_domain, recipient_user,
# recipient_domain, sent_datetime, subject, content, id, message_id) that the
# module appends to /var/mail/<recipient_user>.
class MailTest < PostProvisionTest
  def initialize
    self.module_name = 'mail'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    messages = (self.json_inputs['mail'] || []).map { |m| m.is_a?(String) ? (JSON.parse(m) rescue nil) : m }.compact

    tier(1) do
      test_local_command('mailutils installed', 'dpkg -l mailutils | grep -E "^ii"', 'mailutils')
      test_local_command('mail binary on PATH', 'which mail', 'mail')
      messages.each do |msg|
        rcpt = msg['recipient_user']
        next if rcpt.to_s.empty?
        spool = Shellwords.escape("/var/mail/#{rcpt}")
        test_local_command("mail spool for #{rcpt} exists", "test -s #{spool} && echo ok", 'ok')
        sender = "#{msg['sender_user']}@#{msg['sender_domain']}"
        recipient = "#{rcpt}@#{msg['recipient_domain']}"
        expected = ["From: #{msg['sender_user']} <#{sender}>", "To: #{recipient}"]
        expected << "Subject: #{msg['subject']}" if msg['subject']
        expected << "Date: #{msg['sent_datetime']}" if msg['sent_datetime']
        expected << msg['message_id'].to_s if msg['message_id']
        # every line of the body must be present too
        Array(msg['content']).flat_map { |c| c.to_s.split("\n") }.each { |l| expected << l unless l.strip.empty? }
        cmd = expected.map { |s| "grep -qF -- #{Shellwords.escape(s)} #{spool}" }.join(' && ')
        test_command_succeeds("message '#{msg['subject']}' for #{rcpt} is in the spool", cmd, tier: 1)
      end
    end

    tier(2) do
      test_local_command('mail --version runs', 'mail --version', 'Mailutils')
      test_command_succeeds('/var/spool/mail exists', 'test -d /var/spool/mail')
      messages.each do |msg|
        rcpt = msg['recipient_user']
        subject = msg['subject'].to_s[0, 10]
        next if rcpt.to_s.empty? || subject.empty?
        # the mail client itself parses the mailbox and lists the message
        test_local_command("mail lists '#{msg['subject']}' for #{rcpt}",
                           "mail -H -f #{Shellwords.escape("/var/mail/#{rcpt}")} 2>&1", subject)
      end
    end
  end
end

MailTest.new.run
