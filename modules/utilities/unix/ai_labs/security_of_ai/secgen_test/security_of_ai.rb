require_relative '../../../../../lib/post_provision_test'
require 'json'

# Checks all three inputs: commit (the checked-out HEAD), repo_url (recorded in FETCH_HEAD by the fetch) and
# accounts (each gets an owned copy and the MNIST archive). Tier 2 runs the repo's own model-stealing API.
class SecurityOfAiTest < PostProvisionTest
  REPO = 'Security-of-AI'.freeze

  def initialize
    self.module_name = 'security_of_ai'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def usernames
    (json_inputs['accounts'] || []).reject(&:empty?).map { |a| JSON.parse(a)['username'] }
  end

  def test_module
    super
    commit = json_inputs['commit']&.first
    # git records the fetched URL in FETCH_HEAD without a trailing .git
    repo_url = json_inputs['repo_url']&.first.to_s.sub(/\.git\z/, '')
    tier(1) do
      test_local_command('clone at commit', "git -C /opt/#{REPO} rev-parse HEAD", commit)
      test_local_command('clone from repo_url', "cat /opt/#{REPO}/.git/FETCH_HEAD", repo_url)
      usernames.each do |u|
        test_local_command("#{u}'s copy", "stat -c %U /home/#{u}/#{REPO}/AI_Attacks_Material", u)
        test_local_command("#{u}'s copy at commit", "cat /home/#{u}/#{REPO}/.git/HEAD", commit)
        test_local_command("#{u}'s MNIST archive", "test -s /home/#{u}/.keras/datasets/mnist.npz && echo present", 'present')
      end
    end

    user = usernames.first
    return skip_check('model-stealing API as an account', 'no accounts input', tier: 2) unless user

    # Start the repo's model-stealing API (Flask, port 5000, unmodified) as the account, wait for /health,
    # which runs one prediction through the committed model, then stop it.
    label = "model-stealing API answers /health as #{user}"
    dir = "/home/#{user}/#{REPO}/AI_Attacks_Material/Model_Stealing_Attack"
    cmd = "cd #{dir} && (/opt/python_ml_env/bin/python deploy.py > /tmp/secgen_test_deploy.log 2>&1 &); " \
          'out=; for i in $(seq 90); do out=$(curl -s http://127.0.0.1:5000/health) && [ -n "$out" ] && break; sleep 2; done; ' \
          "echo \"$out\"; pkill -u #{user} -f 'python deploy.py'"
    r = run_as_user(user, cmd, timeout: 300)
    if r[:stdout].to_s =~ /"status":\s*"healthy"/
      pass_check(label, "#{label} on #{get_system_name}", tier: 2)
    else
      fail_check(label, "#{label}: no healthy response", tier: 2,
                 evidence: "$ #{cmd}\n--- stdout\n#{r[:stdout]}\n--- stderr\n#{r[:stderr]}\n--- log\n" +
                           run_vagrant_ssh('cat /tmp/secgen_test_deploy.log')[:stdout].to_s)
    end
  end
end

SecurityOfAiTest.new.run
