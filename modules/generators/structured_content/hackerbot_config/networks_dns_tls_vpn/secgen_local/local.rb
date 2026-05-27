#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_hackerbot_config_generator.rb'
class NetworksDnsTlsVpn < HackerbotConfigGenerator
  attr_accessor :IP_addresses
  attr_accessor :dns_fix_flag
  attr_accessor :vpn_connect_flag
  attr_accessor :domain
  def initialize
    super
    self.module_name = 'Hackerbot Config Generator Networks DNS TLS VPN'
    self.title = 'Secure Communications: VPNs, SSL/TLS and DNS Security'
    self.local_dir = File.expand_path('../../', __FILE__)
    self.templates_path = "#{self.local_dir}/templates/"
    self.config_template_path = "#{self.local_dir}/templates/lab.xml.erb"
    self.html_template_path = "#{self.local_dir}/templates/labsheet.html.erb"
    self.IP_addresses = []
    self.dns_fix_flag = ''
    self.vpn_connect_flag = ''
    self.domain = ''
  end
  def get_options_array
    super + [
      ['--IP_addresses',   GetoptLong::REQUIRED_ARGUMENT],
      ['--dns_fix_flag',   GetoptLong::REQUIRED_ARGUMENT],
      ['--vpn_connect_flag', GetoptLong::REQUIRED_ARGUMENT],
      ['--domain',            GetoptLong::REQUIRED_ARGUMENT],
    ]
  end
  def process_options(opt, arg)
    super
    case opt
    when '--IP_addresses'
      self.IP_addresses << arg
    when '--dns_fix_flag'
      self.dns_fix_flag << arg
    when '--vpn_connect_flag'
      self.vpn_connect_flag << arg
    when '--domain'
      self.domain << arg
    end
  end
  def encoding_print_string
    "IP_addresses: #{self.IP_addresses}, dns_fix_flag: #{self.dns_fix_flag}, " \
      "vpn_connect_flag: #{self.vpn_connect_flag}, domain: #{self.domain}, "
  end
end
NetworksDnsTlsVpn.new.run