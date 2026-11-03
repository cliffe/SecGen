require_relative '../../../../../lib/post_provision_test'

class Gitlab13102Test < PostProvisionTest
  def initialize
    self.module_name = 'gitlab_13102'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    # read_facts: strings_to_leak, leaked_filenames, strings_to_pre_leak, difficulty.
    # All four have an observable effect on the box and are checked below.
    # difficulty controls which of two leak mechanisms configure.pp uses, so
    # the easy-mode flat-file check only runs when difficulty isn't 'hard'.
    difficulty = self.json_inputs['difficulty']&.first || 'easy'
    root_password = self.json_inputs['strings_to_leak']&.first
    secondary_leak = self.json_inputs['strings_to_leak']&.dig(1)
    leaked_filename = self.json_inputs['leaked_filenames']&.first
    pre_leak = self.json_inputs['strings_to_pre_leak']&.first

    tier(1) do
      test_local_command('gitlab-ce package installed', 'dpkg -l gitlab-ce | grep -E "^ii"', 'gitlab-ce')

      # root password is always leaked via /home/git/.credentials regardless of difficulty
      test_local_command('root password leaked in git home', 'cat /home/git/.credentials', root_password) if root_password

      if pre_leak
        test_local_command('pre-leak string present in robots.txt',
                            'cat /opt/gitlab/embedded/service/gitlab-rails/public/robots.txt', pre_leak)
      end

      if difficulty == 'hard'
        # hard mode leaks the secondary string via a .env removed from a git
        # repo's history rather than a flat file; the file read back here
        # would need an attacker-side git clone, so this is covered by tier 3.
      elsif leaked_filename && secondary_leak
        test_local_command('secondary leaked file present', "cat /home/git/#{leaked_filename}", secondary_leak)
      end
    end
    tier(2) do
      test_service_up(port: 80)
      test_http('/users/sign_in', port: 80, match: 'GitLab')
    end
    # The module's default target ("Linux Dropper", index 1) runs the chosen
    # payload through Msf::Exploit::CmdStager, which needs its own SRVHOST set
    # to host the stager's HTTP fetch -- the test harness only auto-points
    # FETCH_SRVHOST for a `cmd/<os>/http/...` command-stager payload (see
    # test_msf_exploit), not this module's own dropper server, and leaving it
    # unset previously crashed the exploit (empty dropper URL). Target 0
    # ("Unix Command") instead runs the CMD directly with no HTTP server at
    # all, so stick with the harness's default cmd/unix/generic payload.
    test_msf_exploit('exploit/multi/http/gitlab_exif_rce',
                     rport: 80,
                     options: { 'TARGET' => 0 },
                     expect_privilege: 'user_rwx',
                     sentinel_wait: 60,
                     tier: 3)
  end
end

Gitlab13102Test.new.run
