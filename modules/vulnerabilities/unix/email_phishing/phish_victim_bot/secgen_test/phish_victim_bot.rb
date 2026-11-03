require_relative '../../../../../lib/post_provision_test'

# install.pp deploys a Java "MailReader" bot under /opt/mailreader (run per user
# from an @reboot cron under Xvfb), always creates a 'guest' user, and installs
# LibreOffice + a JDK. Without a mail server the bot can't poll, so tier 2 proves
# the bot is installed and its main class loads, not that it processes mail.
class PhishVictimBotTest < PostProvisionTest
  MR = '/opt/mailreader'.freeze

  def initialize
    self.module_name = 'phish_victim_bot'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_command_succeeds('mail.jar present', "test -f #{MR}/mail.jar")
      test_command_succeeds('MailReader.class present', "test -f #{MR}/MailReader.class")
      test_command_succeeds('activation jar present', "test -f #{MR}/activation-1.1-rev-1.jar")
      test_local_command('java runtime installed', 'java -version 2>&1', 'version')
      test_local_command('guest user exists', 'id -un guest', 'guest')
    end
    tier(2) do
      # Run the bot's main class exactly as the cron does. With no mail config it
      # exits or is killed by the timeout, but a broken install would instead fail
      # to load the class — so a classloader error is the only failure we reject.
      cp = "#{MR}/mail.jar:#{MR}/activation-1.1-rev-1.jar:#{MR}/"
      test_local_command('MailReader main class loads',
        "timeout 25 java -cp #{cp} MailReader >/tmp/mr.out 2>&1; " \
        "grep -qiE 'could not find or load main class|ClassNotFoundException|NoClassDefFoundError' /tmp/mr.out " \
        "&& echo CLASS_LOAD_FAIL || echo CLASS_LOAD_OK",
        'CLASS_LOAD_OK')
    end
    # No tier 3: the phishing payload path needs a live mail server and attacker interaction.
  end
end

PhishVictimBotTest.new.run
