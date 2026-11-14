require_relative '../../../../../lib/post_provision_test'

class OpencodeTest < PostProvisionTest
  FRAGMENT = '/usr/local/lib/secgen-opencode/10-provider.json'.freeze
  MERGE_TOOL = '/usr/local/sbin/secgen-opencode-merge-config'.freeze
  PROVIDER_DIR = '/opt/opencode-providers'.freeze
  SDK_PACKAGE = '@ai-sdk/openai-compatible'.freeze

  def initialize
    self.module_name = 'opencode'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    opencode_version = self.json_inputs['opencode_version']&.first
    sdk_version = self.json_inputs['provider_sdk_version']&.first
    models = (self.json_inputs['llm_models'] || []).map(&:to_s).reject { |model| model.strip.empty? }
    user = login_user

    tier(1) do
      test_local_command('opencode installed globally',
                         'test -d /usr/local/lib/node_modules/opencode-ai && test -x /usr/local/bin/opencode && echo ok',
                         'ok')
      # Installed locally and referenced by absolute path, so first run needs no npm registry
      test_local_command('provider SDK installed locally',
                         "test -d #{PROVIDER_DIR}/node_modules/#{SDK_PACKAGE} && echo ok", 'ok')
      # Root-only: it carries the API key before the merge copies it into each user's own config
      test_local_command('provider fragment is present and root-only',
                         "stat -c '%a %U' #{FRAGMENT}", '600 root')
      test_local_command('config merge tool is installed', "test -x #{MERGE_TOOL} && echo ok", 'ok')
    end

    tier(2) do
      if opencode_version
        test_local_command('opencode runs and reports the installed version',
                           'opencode --version', opencode_version, user: user)
      else
        test_command_succeeds('opencode runs', 'opencode --version', user: user)
      end

      if sdk_version
        test_local_command('provider SDK is the pinned version',
                           "node -p \"require('#{PROVIDER_DIR}/node_modules/#{SDK_PACKAGE}/package.json').version\"",
                           sdk_version)
      end

      # A re-provision must leave a config the student has edited alone. --check exits non-zero only when a
      # fragment would change something, so right after provisioning it has to be satisfied already.
      test_command_succeeds('merging the config again is a no-op', "#{MERGE_TOOL} --check")

      test_merged_provider(models)
    end
  end

  # The provider preset has to reach the user's own config, with the URL, key and models the scenario set.
  # Read as root, because the merge writes each config 0600 to its owner.
  def test_merged_provider(models)
    probe = <<~'JS'
      const fs = require("fs");
      const read = (path) => JSON.parse(fs.readFileSync(path, "utf8"));
      const config = read(process.env.CFG);
      const fragment = read("/usr/local/lib/secgen-opencode/10-provider.json");
      const provider = (config.providers || {}).spark || {};
      const settings = provider.settings || {};
      const key = settings.apiKey || "";
      console.log("baseURL=" + (settings.baseURL || ""));
      console.log("key_matches_fragment=" + (key !== "" && key === ((fragment.providers.spark.settings || {}).apiKey || "")));
      console.log("model=" + (config.model || ""));
      console.log("models=" + Object.keys(provider.models || {}).sort().join(","));
      console.log("package=" + (provider.package || ""));
    JS
    command = 'U=$(awk -F: \'$3>=1000 && $3<60000 && $6 ~ /^\/home\// {print $1; exit}\' /etc/passwd); ' \
              '[ -n "$U" ] || { echo "no-login-user"; exit 0; }; ' \
              'H=$(getent passwd "$U" | cut -d: -f6); CFG="$H/.config/opencode/opencode.json"; ' \
              'echo "user=$U"; echo "perms=$(stat -c \'%a %U\' "$CFG" 2>/dev/null)"; ' \
              "CFG=\"$CFG\" /usr/local/bin/node -e #{shell_quote(probe)}"

    result = run_vagrant_ssh(command, timeout: 120)
    if result[:stdout].include?('no-login-user')
      return skip_check('provider preset reaches a user config', 'no ordinary login account on this system',
                        tier: 2)
    end
    fields = parse_fields(result[:stdout])
    evidence = "$ #{command}\n--- stdout\n#{result[:stdout]}\n--- stderr\n#{result[:stderr]}"

    expect(fields, 'perms', "600 #{fields['user']}", 'user config is private to its owner', evidence)
    expect(fields, 'baseURL', expected_base_url, 'provider points at the scenario LLM endpoint', evidence)
    # Compared against the fragment inside the guest, so the key never crosses the wire
    expect(fields, 'key_matches_fragment', 'true', 'API key reached the user config', evidence)
    expect(fields, 'models', models.sort.join(','), 'every configured model is offered', evidence) unless models.empty?
    expect(fields, 'model', "spark/#{models.first}", 'first configured model is the default', evidence) unless models.empty?
    name = 'provider package is the local SDK copy'
    if fields['package'].to_s.start_with?("file://#{PROVIDER_DIR}/")
      pass_check(name, "#{name}: #{fields['package']}", tier: 2)
    else
      fail_check(name, "#{name}: got #{fields['package'].inspect}", tier: 2, evidence: evidence)
    end
  end

  # The scenario gives either a relay IP and port or a whole URL; the manifest prefers the relay, and the
  # template strips a trailing slash because the SDK joins the base with "/chat/completions".
  def expected_base_url
    relay_ip = self.json_inputs['llm_relay_ip']&.first.to_s.strip
    url = if relay_ip.empty?
            self.json_inputs['llm_api_url']&.first.to_s
          else
            "http://#{relay_ip}:#{self.json_inputs['llm_relay_port']&.first}/api/v1"
          end
    url.sub(%r{/+\z}, '')
  end

  def expect(fields, key, wanted, label, evidence)
    got = fields[key]
    if got == wanted
      pass_check(label, "#{label}: #{key}=#{got}", tier: 2)
    else
      fail_check(label, "#{label}: #{key} is #{got.inspect}, expected #{wanted.inspect}", tier: 2,
                 evidence: evidence)
    end
  end

  def parse_fields(stdout)
    stdout.to_s.lines.each_with_object({}) do |line, fields|
      key, _, value = line.strip.partition('=')
      fields[key] = value unless key.empty?
    end
  end

  def shell_quote(text)
    "'#{text.gsub("'", %q('\\\\''))}'"
  end

  # The module creates no accounts, so whichever ordinary login account the system has stands in for a
  # student. nil runs the check as root, the best available on a base with no such account.
  def login_user
    found = run_vagrant_ssh("awk -F: '$3>=1000 && $3<60000 && $6 ~ /^\\/home\\// {print $1; exit}' /etc/passwd")
    user = found[:stdout].to_s.strip
    user.empty? ? nil : user
  end
end

OpencodeTest.new.run
