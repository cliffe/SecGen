require_relative '../../../../../lib/post_provision_test'
require 'json'

# Checks the lab_params input: the parameters reach the server, stay private, and (for labs with a
# target model) the API is serving the budget they set.
class AiLabServerTest < PostProvisionTest
  def initialize
    self.module_name = 'ai_lab_server'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    params = JSON.parse(json_inputs['lab_params'].first)
    tier(1) do
      test_local_command('parameters match the input', 'cat /opt/ai_lab/private/params.json', %("seed":#{params['seed']}))
      test_local_command('parameters are root-only', 'stat -c %a /opt/ai_lab/private/params.json', '600')
      test_local_command('private directory is root-only', 'stat -c %a /opt/ai_lab/private', '700')
      test_local_command('training finished', 'test -s /opt/ai_lab/model/public.json && echo present', 'present')
    end
    return unless params['api']

    # The API takes tens of seconds to import TensorFlow after boot.
    r = run_vagrant_ssh('for i in $(seq 90); do o=$(curl -s -m 10 http://127.0.0.1:5000/info) && [ -n "$o" ] && break; sleep 3; done; echo "$o"', timeout: 400)
    budget = %("query_budget":#{params['query_budget']})
    if r[:stdout].to_s.include?(budget)
      pass_check('API serves the configured query budget', r[:stdout].to_s[0, 200], tier: 2)
    else
      fail_check('API serves the configured query budget', "expected #{budget}", tier: 2, evidence: r[:stdout].to_s)
    end
    test_local_command('API runs as the unprivileged user', "ps -o user= -C gunicorn | sort -u", 'ai_lab', tier: 2)
  end
end

AiLabServerTest.new.run
