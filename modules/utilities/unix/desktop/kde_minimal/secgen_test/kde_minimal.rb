require_relative '../../../../../lib/post_provision_test'

class KdeMinimalTest < PostProvisionTest
  def initialize
    self.module_name = 'kde_minimal'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    usernames = (self.json_inputs['accounts'] || []).map do |raw|
      begin
        JSON.parse(raw)['username']
      rescue JSON::ParserError
        nil
      end
    end.compact
    autologin = self.json_inputs['autologin_user']&.first
    konsole = self.json_inputs['autostart_konsole']&.first

    tier(1) do
      test_local_command('kde-plasma-desktop installed?', 'dpkg -l kde-plasma-desktop | grep -E "^ii"', 'kde-plasma-desktop')
      %w[kate qtcurve].each do |pkg|
        test_local_command("#{pkg} installed?", "dpkg -l #{pkg} | grep -E '^ii'", pkg)
      end
      # Test fix: ksnapshot was removed after Debian 10, so the old check could never pass on
      # bookworm. The module installs kde-spectacle on Debian 11-12, spectacle on 13+, ksnapshot before 11.
      test_local_command('screenshot tool installed (kde-spectacle on 11-12, ksnapshot before)',
                         "if grep -qE '^(7|8|9|10)' /etc/debian_version; then pkg=ksnapshot; " \
                         "elif grep -qE '^(11|12)' /etc/debian_version; then pkg=kde-spectacle; else pkg=spectacle; fi; " \
                         "dpkg -l $pkg | grep -E '^ii'",
                         'ii')
      # bundled auto-resolution script, installed executable
      test_command_succeeds('auto-resolution script is executable', 'test -x /opt/auto-resolution/auto-resolution.sh', tier: 1)

      # autologin_user: when a real user was supplied, the display manager config names them
      # (sddm.conf on Debian 9-12, kdmrc on Debian 7)
      if autologin && autologin != 'false'
        test_local_command("autologin configured for #{autologin}",
                           "grep -hE '^(User|AutoLoginUser)=#{autologin}$' /etc/sddm.conf /etc/kde4/kdm/kdmrc 2>/dev/null",
                           "=#{autologin}")
      end

      usernames.each do |user|
        autostart = "/home/#{user}/.config/autostart"
        test_local_command("#{user} auto-resolution autostart entry",
                           "stat -c '%U %n' #{autostart}/auto-resolution.desktop", "#{user} #{autostart}/auto-resolution.desktop")
        # autostart_konsole: entry present only when true
        if konsole
          if konsole == 'true'
            test_local_command("#{user} konsole autostart entry",
                               "stat -c '%U %n' #{autostart}/org.kde.konsole.desktop", "#{user} #{autostart}/org.kde.konsole.desktop")
          else
            test_command_succeeds("#{user} has no konsole autostart entry", "! test -e #{autostart}/org.kde.konsole.desktop", tier: 1)
          end
        end
        # per-release settings files (Debian 12: breeze/power; Debian 9-10: screen locker)
        test_command_succeeds("#{user} release-specific KDE settings",
                              "if grep -q '^12' /etc/debian_version; then " \
                              "test -f /home/#{user}/.config/breezerc && test -f /home/#{user}/.config/powermanagementprofilesrc; " \
                              "elif grep -qE '^(9|10)' /etc/debian_version; then test -f /home/#{user}/.config/kscreenlockerrc; fi",
                              tier: 1)
      end
    end

    # The accounts, autologin_user and autostart_konsole inputs are covered above; nothing else to skip.
    tier(2) do
      test_command_succeeds('plasmashell binary exists', 'test -x /usr/bin/plasmashell')
      # Test fix: plasmashell is a Qt app that initialises a platform plugin before printing
      # --version, so without a display it aborts on the xcb plugin and prints nothing. Run it
      # under the offscreen platform (as the kate check below already does) so it can emit output.
      test_local_command('plasmashell runs', 'QT_QPA_PLATFORM=offscreen plasmashell --version', 'plasmashell')
      test_command_succeeds('auto-resolution script parses', 'bash -n /opt/auto-resolution/auto-resolution.sh')
      (usernames.empty? ? [nil] : usernames).each do |user|
        # Test fix: `kate --version` prints `kate 22.12.3` (lowercase binary name), so the old
        # 'Kate' match could never hit under the case-sensitive substring compare.
        test_local_command("kate runs#{user ? " as #{user}" : ''}", 'QT_QPA_PLATFORM=offscreen kate --version', 'kate', user: user)
      end
    end
  end
end

KdeMinimalTest.new.run
