require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class IptablesRulesTest < PostProvisionTest
  RULES_FILE = '/etc/iptables/rules.v4'

  def initialize
    self.module_name = 'iptables_rules'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Split a rule (iptables command arguments, as the iptables_rule generators
  # produce) the way templates/rules.v4.erb does: an optional '-t <table>'
  # prefix (default filter), then a policy (-P), a new chain (-N) or a rule.
  def parse_rule(raw)
    rule = raw.to_s.strip
    table = 'filter'
    table, rule = Regexp.last_match(1), Regexp.last_match(2) if rule =~ /\A-t\s+(\S+)\s+(.*)\z/
    if rule =~ /\A-P\s+(\S+)\s+(\S+)\z/
      { raw: raw, table: table, kind: :policy, chain: $1, policy: $2, line: ":#{$1} #{$2} " }
    elsif rule =~ /\A-N\s+(\S+)\z/
      { raw: raw, table: table, kind: :chain, chain: $1, line: ":#{$1} - " }
    elsif rule =~ /\A-[AI]\s+(\S+)(?:\s+\d+)?\s+(.*)\z/
      { raw: raw, table: table, kind: :rule, chain: $1, spec: $2, line: rule }
    else
      { raw: raw, table: table, kind: :other, line: rule }
    end
  end

  # rules.v4 as { table => [lines] }
  def rules_file_tables(content)
    tables = {}
    current = nil
    content.to_s.each_line do |l|
      l = l.chomp
      if l =~ /\A\*(\S+)/
        current = tables[$1] = []
      elsif current && l != 'COMMIT'
        current << l
      end
    end
    tables
  end

  # Shell test that succeeds when the parsed rule is in the live ruleset.
  def live_check(r)
    t = "-t #{Shellwords.escape(r[:table])}"
    case r[:kind]
    when :policy
      "iptables #{t} -S #{Shellwords.escape(r[:chain])} | grep -qxF -e #{Shellwords.escape("-P #{r[:chain]} #{r[:policy]}")}"
    when :chain
      "iptables #{t} -S #{Shellwords.escape(r[:chain])} >/dev/null 2>&1"
    when :rule
      # -C matches the rule semantically, so iptables' own normalisation
      # (10.0.3.10 -> 10.0.3.10/32, ESTABLISHED,RELATED order) doesn't matter
      "iptables #{t} -C #{r[:chain]} #{r[:spec]} 2>/dev/null"
    end
  end

  def test_module
    super
    rules = (self.json_inputs['rules'] || []).map(&:to_s).reject { |r| r.strip.empty? }
    forwarding = self.json_inputs['ip_forwarding']&.first
    parsed = rules.map { |r| parse_rule(r) }

    tier(1) do
      test_local_command('iptables-persistent installed',
                         'dpkg -l iptables-persistent | grep -E "^ii"',
                         'iptables-persistent')
      test_local_command('iptables installed', 'which iptables', 'iptables')

      # every configured rule is written to its table's section of rules.v4
      # (policies as the chain declaration ':CHAIN POLICY [0:0]')
      file = run_command("cat #{RULES_FILE}")
      tables = rules_file_tables(file[:stdout])
      fail_check('rules.v4 present', "#{RULES_FILE} missing or empty") if tables.empty?
      parsed.each do |r|
        lines = tables[r[:table]] || []
        found = r[:kind] == :rule || r[:kind] == :other ? lines.include?(r[:line]) : lines.any? { |l| l.start_with?(r[:line]) }
        name = "rule in rules.v4 *#{r[:table]}: #{r[:raw]}"
        if found
          pass_check(name)
        else
          fail_check(name, "#{name}: expected '#{r[:line]}' in the *#{r[:table]} section", evidence: file[:stdout])
        end
      end

      # ip_forwarding only changes anything when true
      if forwarding == 'true'
        test_local_command('ip forwarding persisted', 'cat /etc/sysctl.conf', 'net.ipv4.ip_forward=1')
      end
    end

    tier(2) do
      test_local_command('netfilter-persistent available', 'which netfilter-persistent', 'netfilter-persistent')
      test_local_command('netfilter-persistent enabled at boot',
                         'systemctl is-enabled netfilter-persistent', 'enabled')
      test_command_succeeds('iptables runs', 'iptables --version')
      # the saved rules file parses: iptables-restore --test validates without applying
      test_command_succeeds('rules.v4 is valid', "iptables-restore --test < #{RULES_FILE}")

      # every configured rule is in the live ruleset (loaded at boot), in one guest call
      checkable = parsed.each_with_index.select { |r, _| live_check(r) }
      unless checkable.empty?
        script = checkable.map { |r, i| "if #{live_check(r)}; then echo LIVE_OK_#{i}; else echo LIVE_NO_#{i}; fi" }.join("\n")
        live = run_command(script)
        ruleset = run_command('iptables-save')[:stdout]
        checkable.each do |r, i|
          name = "rule active: #{r[:raw]}"
          if live[:stdout].include?("LIVE_OK_#{i}\n") || live[:stdout].end_with?("LIVE_OK_#{i}")
            pass_check(name)
          else
            fail_check(name, "#{name}: not in the live ruleset", evidence: ruleset)
          end
        end
      end

      if forwarding == 'true'
        test_local_command('ip forwarding active', 'sysctl -n net.ipv4.ip_forward', '1')
      end
    end
  end
end

IptablesRulesTest.new.run
