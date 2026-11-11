require_relative '../../../../../lib/post_provision_test'

# The venv path and package list are fixed by the module; download_mnist decides whether the archive is expected.
class PythonMlEnvTest < PostProvisionTest
  VENV = '/opt/python_ml_env'.freeze

  def initialize
    self.module_name = 'python_ml_env'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def mnist?
    json_inputs['download_mnist']&.first != 'false'
  end

  # Like test_local_command, with a longer guest timeout: a cold TensorFlow import takes tens of seconds.
  def slow_check(label, cmd, pattern, timeout: 600)
    r = run_vagrant_ssh(cmd, timeout: timeout)
    if r[:stdout].to_s =~ pattern
      pass_check(label, "#{label} on #{get_system_name}", tier: 2)
    else
      fail_check(label, "#{label}: output did not match #{pattern.inspect}", tier: 2,
                 evidence: "$ #{cmd}\n--- stdout\n#{r[:stdout]}\n--- stderr\n#{r[:stderr]}")
    end
  end

  def test_module
    super
    tier(1) do
      test_local_command('venv python', "test -x #{VENV}/bin/python && echo present", 'present')
      test_local_command('pinned requirements', "cat #{VENV}/requirements.txt", 'tensorflow==')
      test_local_command('MNIST archive', "test -s #{VENV}/datasets/mnist.npz && echo present", 'present') if mnist?
      test_local_command('bash.bashrc activates venv', 'cat /etc/bash.bashrc', "#{VENV}/bin/activate")
    end
    tier(2) do
      slow_check('ML stack imports',
                 "#{VENV}/bin/python -c \"import tensorflow, sklearn, imblearn, pandas, seaborn, cv2, flask, flask_cors; print('ml-stack-ok', tensorflow.__version__)\" 2>/dev/null",
                 /ml-stack-ok \d/)
      next_check = mnist?
      slow_check('MNIST archive loads',
                 "#{VENV}/bin/python -c \"import numpy as np; print(np.load('#{VENV}/datasets/mnist.npz')['x_train'].shape)\"",
                 /\(60000, 28, 28\)/, timeout: 180) if next_check
      test_command_succeeds('JupyterLab runs', "#{VENV}/bin/jupyter lab --version")
      test_local_command('interactive shell uses the venv', "bash -ic 'command -v python' 2>/dev/null", "#{VENV}/bin/python", tier: 2)
    end
  end
end

PythonMlEnvTest.new.run
