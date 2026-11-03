require_relative '../../../../../lib/post_provision_test'

# Gitlist 0.4.0 RCE (primary CVE-2014-4511) on patched PHP 7.4 (php7_patched).
# tier 2 proves GitList serves via Apache -> php-fpm and that the php2shell fix
# is present, so only GitList's own application-level RCE is exploitable, not a
# generic PHP shell.
# tier 3 runs two Metasploit modules from the attacker VM, both unauthenticated
# and both working against this 0.4.0 build:
#   - exploit/linux/http/gitlist_exec (CVE-2014-4511): command injection through
#     a crafted filename in the blame/file-browser endpoint (the primary vuln).
#   - exploit/multi/http/gitlist_arg_injection (CVE-2018-1000533): argument
#     injection into git log --grep (escapeshellarg-bypassed) in the search path.
# Both run the injected command as the web server user (www-data) and read the
# leaked flag from /home/git/ (owner www-data, mode 0750, readable by www-data).
# TARGETURI '/gitlist/' because Apache serves GitList from that subdirectory
# (Alias to /var/www/gitlist, RewriteBase /gitlist/), whose prefixed repository
# links both exploits' repository discovery needs.
# No credentials are required.
# Tier 3 SKIPs cleanly when there is no attacker sibling (single-VM run).
class Gitlist040Test < PostProvisionTest
  REPO = '/home/git/repositories/secret_files'
  FIX_COMMIT = '712e60f9edfd03f0960fc4fc3c2c375f42b90aa2'.freeze

  def initialize
    self.module_name = 'gitlist_040'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('gitlist docroot exists', 'test -d /var/www/gitlist && echo ok', 'ok')
      test_local_command('git installed', 'which git', '/usr/bin/git')
      test_local_command('patched php present', 'test -x /opt/php-7.4-patched/bin/php && echo ok', 'ok')
    end
    tier(2) do
      test_service_up
      # Match the page body (not curl %{http_code}: the % is eaten by the
      # guest-agent exec path). Retry while GitList/php-fpm warm up.
      test_local_command('gitlist serves (Apache+php-fpm)',
                         "for i in $(seq 1 15); do curl -s http://127.0.0.1:#{self.port}/gitlist/ | grep -q GitList && { echo SERVED_GITLIST; break; }; sleep 2; done", 'SERVED_GITLIST')
      test_local_command('php2shell fix present (CVE-2026-109618/109619)',
                         'cat /opt/php-7.4-patched/PHP2SHELL_FIX_COMMIT', FIX_COMMIT)
    end
    # Tier 3 (primary): blame/file-browser command injection from the attacker
    # VM (CVE-2014-4511, exploit/linux/http/gitlist_exec). cmd/unix/generic is a
    # compatible payload (the module's RequiredCmd list includes 'generic') and
    # the module runs on the unix/ARCH_CMD platform, unlike the PHP-platform
    # arg_injection module below. The module declares space a bad char, so
    # Metasploit encodes the injected command for the ${IFS} sink itself.
    # TARGETURI '/gitlist/' matches the Apache Alias; the module's repository
    # discovery keys off the /gitlist/-prefixed links on that page. collect reads
    # the same leaked flag from /home/git/ as www-data.
    test_msf_exploit('exploit/linux/http/gitlist_exec',
                     rport: self.port,
                     payload: 'cmd/unix/generic',
                     collect: 'cat /home/git/*',
                     options: { 'TARGETURI' => '/gitlist/' },
                     tier: 3)

    # Tier 3: argument-injection RCE from the attacker VM (CVE-2018-1000533).
    # php/unix/cmd/generic: the module is PHP-platform (cmd/unix/generic is
    # incompatible). The argument injection runs the CMD via the PHP exec call
    # to git, outside the php2shell-patched function restrictions, so the
    # patched PHP 7.4 still allows this execution path. collect reads the
    # leaked flag from /home/git/ (owner www-data, mode 0750 — readable by
    # the exploit process running as www-data).
    test_msf_exploit('exploit/multi/http/gitlist_arg_injection',
                     rport: self.port,
                     payload: 'php/unix/cmd/generic',
                     collect: 'cat /home/git/*',
                     options: { 'TARGETURI' => '/gitlist/' },
                     tier: 3)

    # Deleted-history leak: opt-in via strings_to_leak_in_history. When a scenario
    # buries a secret in history, prove the mechanism actually worked: the file is
    # gone from HEAD (not browsable in GitList), a later commit deleted it, and its
    # content is still recoverable from history. When the input is absent/blank
    # (the default build and the other gitlist CTFs) these checks SKIP, so the test
    # still passes there.
    #
    # Inputs considered: strings_to_leak_in_history + history_leaked_filenames are
    # checked below. port/strings_to_leak/leaked_filenames/strings_to_pre_leak/
    # pre_leaked_filenames/images_to_leak drive the served web/repo content exercised
    # by the tier 1-3 checks above; history_commit_message/
    # history_removal_commit_message only affect commit-message text and are not
    # asserted here.
    secret = self.json_inputs['strings_to_leak_in_history']&.first
    if secret && !secret.strip.empty?
      fname = self.json_inputs['history_leaked_filenames']&.first
      fname = 'secret' if fname.nil? || fname.strip.empty?
      # -C sets the repo dir; safe.directory lets git operate on the www-data repo
      # when the command is run as www-data (avoids "dubious ownership").
      g = "git -C #{REPO} -c safe.directory=#{REPO}"

      tier(2) do
        # Gone from the working tree / HEAD -> not shown by GitList's file browser.
        test_local_command('history secret absent at HEAD',
          "#{g} ls-files -- #{fname} | grep -q . && echo PRESENT || echo ABSENT",
          'ABSENT', user: 'www-data')

        # A commit that *deleted* the file exists -> it was committed then removed.
        test_local_command('history secret removed in a later commit',
          "#{g} log --all --diff-filter=D --oneline -- #{fname} | grep -q . && echo DELETED || echo NODEL",
          'DELETED', user: 'www-data')

        # The content is still recoverable from history (git log -p across the file).
        # Grep for the longest word-ish token in the resolved secret (shell-safe).
        token = secret.scan(/[A-Za-z0-9_]{5,}/).max_by(&:length) || fname
        test_local_command('history secret content recoverable from git history',
          "#{g} log --all -p -- #{fname} | grep -F -- #{token} | head -n1",
          token, user: 'www-data')
      end
    end
  end
end

Gitlist040Test.new.run
