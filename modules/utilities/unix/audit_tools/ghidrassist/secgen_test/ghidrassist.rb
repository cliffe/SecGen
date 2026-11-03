require_relative '../../../../../lib/post_provision_test'

class GhidrAssistTest < PostProvisionTest
  def initialize
    self.module_name = 'ghidrassist'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    test_llm_assistant(json_inputs || {})
  end

  def test_llm_assistant(inputs)
    tier(1) do
      test_command_succeeds('GhidrAssist extension installed', 'test -s /opt/ghidra/Ghidra/Extensions/GhidrAssist/lib/GhidrAssist.jar')
      # the settings dir is ghidra_<application.version>_<release.name>: check the version we wrote matches the install
      props = run_command('grep -E "^application\.(version|release\.name)=" /opt/ghidra/Ghidra/application.properties')[:stdout]
      version = props[/application\.version=(\S+)/, 1]
      release = props[/application\.release\.name=(\S+)/, 1]
      prefs = "~/.config/ghidra/ghidra_#{version}_#{release}/preferences"
      test_command_succeeds('preferences up to date for all users', '/usr/local/sbin/secgen-ghidra-llm-prefs --check')
      test_command_succeeds("/etc/skel has #{prefs}", "grep -q '^GhidrAssist.APIProviders=' /etc/skel/#{prefs.sub('~/', '')}")
      add_evidence('ghidra settings dirs', 'ls -la /home/*/.config/ghidra/ /root/.config/ghidra/ 2>&1')
      check_provider_prefs(inputs, "/etc/skel/#{prefs.sub('~/', '')}")
    end

    # Does the configured API answer? Any reply from the gateway (401 with the placeholder key) means the route
    # (relay or direct) works; 000 = unreachable, 403/404 = relay refused, 502/504 = relay can't reach the gateway.
    url = expected_llm_url(inputs)
    model = llm_models(inputs).first
    # No API key is sent (keeps it off the command line), so a working route answers 401. Only the first model is
    # queried (a reasoning model can take longer than the timeout); every model is checked in the preferences.
    tier(2) do
      if url.nil? || model.nil?
        skip_check('LLM API answers', 'no llm_api_url / llm_relay_ip and llm_models inputs to test against')
        next
      end
      cmd = "curl -s -m 30 --noproxy '*' -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' " \
            "-d '{\"model\":\"#{model}\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"max_tokens\":1}' " \
            "#{url}chat/completions"
      code = run_command(cmd)[:stdout].strip
      if %w[200 401].include?(code)
        pass_check("LLM API answers at #{url}", "HTTP #{code}")
      else
        fail_check("LLM API answers at #{url}", "HTTP #{code.empty? ? '000' : code}")
      end
    end
  end

  # Models the module writes a provider for (empty values are dropped, as in the template)
  def llm_models(inputs)
    (inputs['llm_models'] || []).reject { |m| m.to_s.empty? }
  end

  # The base URL the providers use: the relay when llm_relay_ip is set, else llm_api_url; always one trailing slash
  def expected_llm_url(inputs)
    relay_ip = inputs['llm_relay_ip']&.first.to_s
    url = if relay_ip.empty?
            inputs['llm_api_url']&.first
          else
            "http://#{relay_ip}:#{inputs['llm_relay_port']&.first}/api/v1/"
          end
    return nil if url.nil? || url.empty?
    url.end_with?('/') ? url : "#{url}/"
  end

  # Parse the provider list in a Ghidra preferences file and compare it with the inputs. The file is read here and
  # compared in Ruby, so the API key is never put on a command line or into a check name.
  def check_provider_prefs(inputs, path)
    text = run_command("cat #{path}")[:stdout].to_s
    line = text.lines.find { |l| l.start_with?('GhidrAssist.APIProviders=') }
    selected = text.lines.find { |l| l.start_with?('GhidrAssist.SelectedAPIProvider=') }
    providers = begin
      JSON.parse(line.strip.sub('GhidrAssist.APIProviders=', '').gsub('\\\\', '\\'))
    rescue StandardError
      nil
    end
    if providers.nil?
      fail_check("providers parse in #{path}", 'GhidrAssist.APIProviders is missing or not JSON')
      return
    end

    models = llm_models(inputs)
    unless models.empty?
      got = providers.map { |p| p['model'] }
      got == models ? pass_check('one provider per llm_models entry, in order', got.join(', ')) :
                      fail_check('one provider per llm_models entry, in order', "expected #{models.join(', ')}; got #{got.join(', ')}")
      active = selected.to_s.strip.sub('GhidrAssist.SelectedAPIProvider=', '')
      first = providers.find { |p| p['model'] == models.first }
      if first && active == first['name']
        pass_check('first llm_models entry is the selected provider', active)
      else
        fail_check('first llm_models entry is the selected provider', "selected '#{active}'")
      end
    end

    url = expected_llm_url(inputs)
    if url
      bad = providers.reject { |p| p['url'] == url }
      providers.any? && bad.empty? ? pass_check('providers use the configured API URL', url) :
                   fail_check('providers use the configured API URL', "expected #{url}; got #{bad.map { |p| p['url'] }.join(', ')}")
    end

    if (key = inputs['llm_api_key']&.first)
      bad = providers.reject { |p| p['key'] == key }
      providers.any? && bad.empty? ? pass_check('providers hold the configured llm_api_key') :
                   fail_check('providers hold the configured llm_api_key', "#{bad.size} provider(s) have a different key")
    end
  end
end

GhidrAssistTest.new.run
