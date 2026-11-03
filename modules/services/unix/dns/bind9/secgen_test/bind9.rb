require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class Bind9Test < PostProvisionTest
  def initialize
    self.module_name = 'bind9'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Inputs: domain, ns_hostname, serial, dns_records and allow_transfer are all
  # checked below. None are skipped. The service port is not an input (DNS is 53).
  def test_module
    super
    domain         = self.json_inputs['domain']&.first
    ns_hostname    = self.json_inputs['ns_hostname']&.first
    serial         = self.json_inputs['serial']&.first
    allow_transfer = self.json_inputs['allow_transfer']&.first

    tier(1) do
      test_local_command('bind9 installed?', 'dpkg -l bind9 | grep -E "^ii"', 'bind9')
      # named.conf.options written by the module: authoritative only, queryable by anyone
      test_local_command('recursion disabled', 'cat /etc/bind/named.conf.options', 'recursion no')
      test_local_command('allow-query any', 'cat /etc/bind/named.conf.options', 'allow-query { any; }')
      test_local_command('named config is valid', 'named-checkconf && echo conf-ok', 'conf-ok')
      test_local_command('bind9 enabled at boot', 'systemctl is-enabled named || systemctl is-enabled bind9', 'enabled')
      if domain
        # the zone is declared and its file is written for the configured domain
        test_local_command("zone #{domain} declared", 'cat /etc/bind/named.conf.local', "zone \"#{domain}\"")
        test_local_command("zone file for #{domain} exists", "test -f /etc/bind/db.#{domain} && echo present", 'present')
        test_local_command("zone #{domain} is valid", "named-checkzone #{domain.shellescape} /etc/bind/db.#{domain.shellescape}", 'OK')
      end
      if allow_transfer
        test_local_command('allow-transfer in named.conf.local', 'cat /etc/bind/named.conf.local', "allow-transfer { #{allow_transfer}; }")
      end
    end

    tier(2) do
      test_local_command('named running?', 'ps -ef | grep "[n]amed"', 'named')
      test_service_up(port: 53)
      # recursion is off, so an outside name is refused rather than resolved
      test_local_command('recursion refused', 'dig @127.0.0.1 example.org A', 'REFUSED')

      if domain
        # SOA carries the configured name server and serial
        soa = "dig +short @127.0.0.1 #{domain.shellescape} SOA"
        test_local_command("#{domain} SOA names #{ns_hostname}", soa, "#{ns_hostname}.") if ns_hostname
        test_local_command("#{domain} SOA serial #{serial}", soa, serial) if serial
        test_local_command("#{domain} NS is #{ns_hostname}", "dig +short @127.0.0.1 #{domain.shellescape} NS", "#{ns_hostname}.") if ns_hostname

        # zone transfer policy: 'any' lets anyone pull the zone, 'none' refuses it
        axfr = "dig axfr @127.0.0.1 #{domain.shellescape} | grep -E 'XFR size|Transfer failed'"
        case allow_transfer
        when 'any'
          test_local_command('zone transfer allowed', axfr, 'XFR size')
        when 'none'
          test_local_command('zone transfer refused', axfr, 'Transfer failed')
        end
      end
    end

    (self.json_inputs['dns_records'] || []).each do |record|
      if record.include?('|')
        hostname, type, value, priority = record.split('|')
        type = type&.upcase
      else
        hostname, value = record.split('=')
        type = 'A'
      end
      next if hostname.nil? || type.nil? || value.nil?
      # names in the zone file are relative to the domain; '@' is the apex
      fqdn = if hostname == '@' then domain
             elsif domain then "#{hostname}.#{domain}"
             else hostname
             end
      next if fqdn.nil?
      # what dig prints for each type: names gain a trailing dot, TXT is quoted
      expected = case type
                 when 'A', 'AAAA' then value
                 when 'TXT' then value
                 when 'MX' then "#{priority || '10'} #{value}."
                 when 'CNAME', 'NS', 'PTR' then "#{value}."
                 end
      next if expected.nil?
      tier(2) { test_local_command("#{fqdn} #{type} resolves", "dig +short @127.0.0.1 #{fqdn.shellescape} #{type}", expected) }
    end
  end
end

Bind9Test.new.run
