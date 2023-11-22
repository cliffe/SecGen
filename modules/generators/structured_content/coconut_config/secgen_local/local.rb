#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class CocoConfigGenerator < StringEncoder
  attr_accessor :pack_binary
  attr_accessor :include_source
  attr_accessor :welcome_msg_code
  attr_accessor :bd_timeout
  attr_accessor :http_bd_port
  attr_accessor :icmp_bd_port
  attr_accessor :bind_bd_port
  attr_accessor :transport_port
  attr_accessor :bd_password

  def initialize
    super
    self.module_name = 'Account Generator / Builder'
    self.pack_binary = ''
    self.include_source = ''
    self.welcome_msg_code = ''
    self.bd_timeout = ''
    self.http_bd_port = ''
    self.icmp_bd_port = ''
    self.bind_bd_port = ''
    self.transport_port = ''
    self.bd_password = ''
  end

  def encode_all
    coconut_hash = {}
    coconut_hash['pack_binary'] = self.pack_binary
    coconut_hash['include_source'] = self.include_source
    coconut_hash['welcome_msg_code'] = self.welcome_msg_code
    coconut_hash['bd_timeout'] = self.bd_timeout
    coconut_hash['http_bd_port'] = self.http_bd_port
    coconut_hash['icmp_bd_port'] = self.icmp_bd_port
    coconut_hash['bind_bd_port'] = self.bind_bd_port
    coconut_hash['transport_port'] = self.transport_port
    coconut_hash['bd_password'] = self.bd_password

    self.outputs << coconut_hash.to_json
  end

  def get_options_array
    super + [['--pack_binary', GetoptLong::REQUIRED_ARGUMENT],
             ['--include_source', GetoptLong::REQUIRED_ARGUMENT],
             ['--welcome_msg_code', GetoptLong::REQUIRED_ARGUMENT],
             ['--bd_timeout', GetoptLong::REQUIRED_ARGUMENT],
             ['--http_bd_port', GetoptLong::REQUIRED_ARGUMENT],
             ['--icmp_bd_port', GetoptLong::REQUIRED_ARGUMENT],
             ['--bind_bd_port', GetoptLong::REQUIRED_ARGUMENT],
             ['--transport_port', GetoptLong::REQUIRED_ARGUMENT],
             ['--bd_password', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--pack_binary'
        self.pack_binary << arg;
      when '--include_source'
        self.include_source << arg;
      when '--welcome_msg_code'
        self.welcome_msg_code << arg;
      when '--bd_timeout'
        self.bd_timeout << arg;
      when '--http_bd_port'
        self.http_bd_port << arg;
      when '--icmp_bd_port'
        self.icmp_bd_port << arg;
      when '--bind_bd_port'
        self.bind_bd_port << arg;
      when '--transport_port'
        self.transport_port << arg;
      when '--bd_password'
        self.bd_password << arg;
    end
  end

  def encoding_print_string
    'pack_binary: ' + self.pack_binary.to_s + print_string_padding +
    'include_source: ' + self.include_source.to_s  + print_string_padding +
    'welcome_msg_code: ' + self.welcome_msg_code.to_s  + print_string_padding +
    'bd_timeout: ' + self.bd_timeout.to_s + print_string_padding +
    'http_bd_port: ' + self.http_bd_port.to_s + print_string_padding +
    'icmp_bd_port: ' + self.icmp_bd_port.to_s + print_string_padding +
    'bind_bd_port: ' + self.bind_bd_port.to_s + print_string_padding +
    'transport_port: ' + self.transport_port.to_s + print_string_padding +
    'bd_password: ' + self.bd_password.to_s
  end
end

CocoConfigGenerator.new.run
