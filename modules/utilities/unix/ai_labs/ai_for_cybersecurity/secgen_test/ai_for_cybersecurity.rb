require_relative '../../../../../lib/post_provision_test'
require 'json'

# Checks all three inputs: commit (the checked-out HEAD), repo_url (recorded in FETCH_HEAD by the fetch) and
# accounts (each gets an owned copy). Tier 2 executes one of the repo's lecturer notebooks headless.
class AiForCybersecurityTest < PostProvisionTest
  REPO = 'AI-for-Cybersecurity'.freeze
  NOTEBOOK_DIR = 'Lecturer notebooks/AI for CyberSec Spam email detection'.freeze
  NOTEBOOK = 'AI_for_Cybersecurity_Spam_email_detection.ipynb'.freeze

  def initialize
    self.module_name = 'ai_for_cybersecurity'
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
        test_local_command("#{u}'s copy", "stat -c %U '/home/#{u}/#{REPO}/Student notebooks'", u)
        test_local_command("#{u}'s copy at commit", "cat /home/#{u}/#{REPO}/.git/HEAD", commit)
      end
    end

    user = usernames.first
    return skip_check('notebook executes as an account', 'no accounts input', tier: 2) unless user

    # Run the spam-detection lecturer notebook end to end with nbconvert, writing the result outside the
    # account's copy so the repo stays unmodified. nbconvert exits non-zero, without writing, if a cell fails.
    label = "spam-detection lecturer notebook executes as #{user}"
    cmd = "out=$(mktemp -d) && cd '/home/#{user}/#{REPO}/#{NOTEBOOK_DIR}' && " \
          "/opt/python_ml_env/bin/jupyter nbconvert --to notebook --execute --output-dir \"$out\" --output executed #{NOTEBOOK} 2>&1 | tail -5; " \
          'rm -rf "$out"'
    r = run_as_user(user, cmd, timeout: 300)
    if r[:stdout].to_s =~ /Writing \d+ bytes/
      pass_check(label, "#{label} on #{get_system_name}", tier: 2)
    else
      fail_check(label, "#{label}: nbconvert did not write an executed notebook", tier: 2,
                 evidence: "$ #{cmd}\n--- stdout\n#{r[:stdout]}\n--- stderr\n#{r[:stderr]}")
    end
  end
end

AiForCybersecurityTest.new.run
