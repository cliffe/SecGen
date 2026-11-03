require_relative '../../../../../lib/post_provision_test'

class LlmRelayTest < PostProvisionTest
  def initialize
    self.module_name = 'llm_relay'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    conf = '/etc/nginx/conf.d/secgen_llm_relay.conf'
    # listen_port / upstream_url come from the inputs; if the build did not record them, read what nginx was given
    port = (json_inputs['listen_port']&.first || run_command("grep -oP 'listen \\K\\d+' #{conf} | head -1")[:stdout].strip).to_i
    upstream_cfg = json_inputs['upstream_url']&.first&.sub(%r{/+$}, '')
    # allowed_networks / lab_inbound_ports: empty strings mean "not set" (the defaults are empty)
    allowed = (json_inputs['allowed_networks'] || []).reject(&:empty?)
    inbound = (json_inputs['lab_inbound_ports'] || []).reject(&:empty?)
    # whether the relay adds the key itself (secgen.rb --llm-api-key) or passes clients' through
    adds_key = run_command('grep -q "proxy_set_header Authorization" /etc/nginx/conf.d/secgen_llm_relay.conf && echo yes')[:stdout].include?('yes')
    tier(1) do
      test_local_command('nginx installed', 'which nginx', 'nginx')
      test_local_command('nftables installed', 'which nft', 'nft')
      test_command_succeeds('relay config file present', "test -f #{conf}")
      # the config holds the API key, so it is root-only
      test_local_command('relay config is mode 600', "stat -c %a #{conf}", '600')
      test_command_succeeds('firewall generator script present', 'test -x /usr/local/sbin/secgen-llm-relay-firewall')
      test_command_succeeds('nftables.conf generated', 'test -s /etc/nftables.conf')
      test_local_command('nftables enabled at boot', 'systemctl is-enabled nftables', 'enabled')
      test_command_succeeds('sysctl drop-in present', 'grep -q "net.ipv4.ip_forward = 0" /etc/sysctl.d/90-secgen-llm-relay.conf')
      test_local_command('nginx enabled at boot', 'systemctl is-enabled nginx', 'enabled')
      # listen_port: the relay listens where it was told to
      test_local_command("nginx configured to listen on #{port}", "grep -E '^\\s*listen ' #{conf}", "listen #{port};")
      # upstream_url: proxied to the configured API
      test_local_command('nginx proxies to upstream_url', "grep proxy_pass #{conf}", upstream_cfg) if upstream_cfg
      # allowed_networks: each CIDR is an nginx allow rule and a firewall client network
      allowed.each do |net|
        test_local_command("allow #{net} in nginx", "grep allow #{conf}", "allow #{net};")
        test_local_command("#{net} in nftables.conf", 'cat /etc/nftables.conf', net)
      end
      # lab_inbound_ports: each extra port is accepted from the lab subnets
      inbound.each do |p|
        test_local_command("lab_inbound_ports #{p} in nftables.conf", 'cat /etc/nftables.conf', p)
      end
      test_command_succeeds('nginx config valid', 'nginx -t')
      pass_check('relay key mode', adds_key ? 'relay adds the API key' : "passes the client's Authorization header through")
      # the relay's own firewall, loaded at boot
      test_command_succeeds('firewall rules loaded', 'nft list table inet secgen_llm_relay')
      test_local_command('IP forwarding off', 'sysctl -n net.ipv4.ip_forward', '0')
      add_evidence('nftables ruleset', 'nft list ruleset')
    end
    tier(2) do
      test_service_up(port: port)
      test_local_command('nginx service active', 'systemctl is-active nginx | grep -x active', 'active', tier: 2)
      test_local_command('nftables firewall script --check passes', '/usr/local/sbin/secgen-llm-relay-firewall --check; echo rc=$?', 'rc=0', tier: 2)
      test_http('/', status: 403, port: port)
      # only the two endpoints are relayed: anything else on the gateway is refused by the relay
      test_http('/api/v1/admin', status: 403, port: port)
      # Through the relay to the upstream API: any reply from the gateway (401 without a key) shows the relay VM
      # kept its internal NIC and can reach the gateway; 502/504 = it can't.
      code = run_command("curl -s -m 30 -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json' " \
                         "-d '{}' http://127.0.0.1:#{port}/api/v1/chat/completions")[:stdout].strip
      if %w[200 400 401 422].include?(code)
        pass_check('relay reaches the upstream LLM API', "HTTP #{code}")
      else
        fail_check('relay reaches the upstream LLM API', "HTTP #{code.empty? ? '000' : code}")
      end
      # ... and nothing else on the internal network. The target must answer when unfiltered (checked from the
      # internal network on 2026-10-10: the Spark gateway's LiteLLM port 4000 does), otherwise "blocked" proves
      # nothing. HTTP 000 = no connection.
      upstream = upstream_cfg || run_command("grep -oP 'proxy_pass \\K[^;]+' #{conf} | head -1")[:stdout].strip
      upstream_host = upstream[%r{//([\d.]+)}, 1]
      other_port = upstream.end_with?(':4000') ? 8080 : 4000
      blocked = lambda do |label, url|
        next fail_check("#{label} blocked", "no upstream host found in #{conf}") if upstream_host.nil?
        r = run_command("curl -s -m 8 --noproxy '*' -o /dev/null -w '%{http_code}' #{url}")
        code = r[:stdout].strip
        # curl 7 = could not connect, 28 = timed out; anything else (e.g. 3, bad URL) proves nothing
        if code == '000' && [7, 28].include?(r[:exit_status])
          pass_check("#{label} blocked", url)
        else
          fail_check("#{label} blocked", "#{url} answered HTTP #{code} (curl exit #{r[:exit_status]})")
        end
      end
      blocked.call("upstream host's other port", "http://#{upstream_host}:#{other_port}/")
      add_evidence('relay interfaces and routes', 'ip -4 -o addr show; ip route')
      add_evidence('nginx error log', 'tail -n 50 /var/log/nginx/error.log')
    end
    # With a key on the relay, talk to the model itself: the LLM service is online and answers through the relay
    tier(3) { test_llm_interaction(port) } if adds_key
  end

  def test_llm_interaction(port)
    base = "http://127.0.0.1:#{port}/api/v1"
    models_out = run_command("curl -s -m 30 -w '\\n%{http_code}' #{base}/models")[:stdout]
    models_body, _, models_code = models_out.rpartition("\n")
    ids = (JSON.parse(models_body)['data'] || []).map { |m| m['id'] } rescue []
    if models_code.strip == '200' && !ids.empty?
      pass_check('models listed through the relay', ids.join(', '))
    elsif models_code.strip == '200'
      # the gateway accepted the key, but its account has access to no models (an Open WebUI permission setting)
      fail_check('models listed through the relay',
                 "key accepted, but its account can see no models: grant it access in Open WebUI (#{models_body[0, 100]})")
      return
    else
      fail_check('models listed through the relay', "HTTP #{models_code.strip}: #{models_body[0, 200]}")
      return
    end

    # smart is the ghidra module's default model; it reasons first, so allow it more tokens than the reply needs
    model = %w[smart fast].find { |m| ids.include?(m) } || ids.first
    payload = { model: model, max_tokens: 400,
                messages: [{ role: 'user', content: 'Reply with exactly one word: PONG' }] }.to_json
    started = Time.now
    chat_out = run_command("curl -s -m 120 -w '\\n%{http_code}' -H 'Content-Type: application/json' " \
                           "-d '#{payload}' #{base}/chat/completions", timeout: 150)[:stdout]
    chat_body, _, chat_code = chat_out.rpartition("\n")
    reply = (JSON.parse(chat_body).dig('choices', 0, 'message', 'content') rescue nil).to_s.strip
    secs = (Time.now - started).round(1)
    if chat_code.strip == '200' && !reply.empty?
      pass_check("model '#{model}' answers through the relay", "#{secs}s: #{reply[0, 120].inspect}")
    else
      fail_check("model '#{model}' answers through the relay", "HTTP #{chat_code.strip} after #{secs}s: #{chat_body[0, 300]}")
    end
  end
end

LlmRelayTest.new.run
