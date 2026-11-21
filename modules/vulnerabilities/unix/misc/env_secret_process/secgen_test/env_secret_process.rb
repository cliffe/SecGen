require_relative '../../../../../lib/post_provision_test'

class EnvSecretProcessTest < PostProvisionTest
  def initialize
    self.module_name = 'env_secret_process'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    # Flag comes from this module's received inputs, so the test holds for any
    # parameterised deployment, not just the default flag_generator value.
    flag = json_inputs['flag'] ? json_inputs['flag'][0] : nil

    tier(1) do
      test_local_command('telemetry binary built?',
                         'test -f /usr/local/sbin/net-telemetryd && echo ok', 'ok')
      test_local_command('plaintext source removed after build?',
                         'test ! -f /opt/.telemetry/telemetry.c && echo gone', 'gone')
      test_local_command('service enabled?',
                         'systemctl is-enabled net-telemetry.service 2>&1', 'enabled')
    end

    tier(2) do
      # A running process carries the token in its environment block (which a
      # strings search of a capture finds), while nothing on disk does.
      scan = 'for p in /proc/[0-9]*; do tr "\\0" "\\n" < "$p/environ" 2>/dev/null; done | ' \
             'grep -q "TELEMETRY_TOKEN=" && echo TOKEN_IN_ENV'
      test_local_command('a process carries a secret in its environment?',
                         scan, 'TOKEN_IN_ENV')
    end

    tier(3) do
      if flag.nil?
        skip_check('flag recoverable from a process environment?',
                   'no flag input available to test', tier: 3)
      else
        recover = "for p in /proc/[0-9]*; do tr '\\0' '\\n' < \"$p/environ\" 2>/dev/null; done | " \
                  "grep -qF #{Shellwords.escape(flag)} && echo FLAGFOUND"
        test_local_command('flag recoverable from a process environment?',
                           recover, 'FLAGFOUND')
      end
    end
  end
end

EnvSecretProcessTest.new.run
