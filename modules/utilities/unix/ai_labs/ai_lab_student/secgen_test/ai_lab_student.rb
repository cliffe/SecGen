require_relative '../../../../../lib/post_provision_test'
require 'json'

# Checks the accounts, lab and pool_size inputs: each account gets its lab's notebook and data, and
# the marking script runs as that account.
class AiLabStudentTest < PostProvisionTest
  NOTEBOOKS = { 'model_stealing' => 'model_stealing.ipynb', 'backdoor' => 'backdoor.ipynb', 'evasion' => 'evasion.ipynb' }.freeze
  DATA = { 'model_stealing' => 'query_pool.npy', 'backdoor' => 'train_data.npz' }.freeze

  def initialize
    self.module_name = 'ai_lab_student'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def usernames
    (json_inputs['accounts'] || []).reject(&:empty?).map { |a| JSON.parse(a)['username'] }
  end

  def test_module
    super
    lab = json_inputs['lab'].first
    data = DATA[lab]
    tier(1) do
      usernames.each do |user|
        test_local_command("#{user}'s notebook", "stat -c %U /home/#{user}/lab/#{NOTEBOOKS[lab]}", user)
        test_local_command("#{user}'s launcher", "stat -c %U /home/#{user}/Desktop/jupyterlab.desktop", user)
        test_local_command("#{user}'s data", "stat -c %U /home/#{user}/lab/#{data}", user) if data
      end
      test_local_command('no MNIST archive left behind', "ls -a /opt/ai_lab; test ! -e /opt/ai_lab/.mnist.npz && echo clean", 'clean')
    end
    user = usernames.first
    return skip_check('marking script as an account', 'no accounts input', tier: 2) unless user

    if data == 'query_pool.npy'
      size = json_inputs['pool_size'].first
      test_local_command('pool has the configured size and no labels', "/opt/python_ml_env/bin/python -I -c \"import numpy as n; print(n.load('/home/#{user}/lab/#{data}').shape)\"", "(#{size}, 28, 28)", tier: 2)
    end
    r = run_as_user(user, "env -i HOME=/home/#{user} /opt/python_ml_env/bin/python -I /opt/ai_lab/predict_student.py < /dev/null", timeout: 300)
    if r[:stdout].to_s.include?('NOMODEL')
      pass_check("marking script runs as #{user}", 'reports no model yet', tier: 2)
    else
      fail_check("marking script runs as #{user}", 'expected NOMODEL', tier: 2, evidence: "#{r[:stdout]}\n#{r[:stderr]}")
    end
  end
end

AiLabStudentTest.new.run
