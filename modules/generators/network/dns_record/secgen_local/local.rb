#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class DnsRecordGenerator < StringGenerator
  attr_accessor :hostname
  attr_accessor :type
  attr_accessor :value
  attr_accessor :priority

  SUPPORTED_TYPES = %w[a aaaa cname txt ns ptr mx].freeze

  def initialize
    super
    self.module_name = 'DNS Record Generator'
    self.hostname = ''
    self.type = 'a'
    self.value = ''
    self.priority = '10'
  end

  def get_options_array
    super + [['--hostname', GetoptLong::REQUIRED_ARGUMENT],
             ['--type',     GetoptLong::REQUIRED_ARGUMENT],
             ['--value',    GetoptLong::REQUIRED_ARGUMENT],
             ['--priority', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--hostname' then self.hostname = arg
    when '--type'     then self.type     = arg.downcase
    when '--value'    then self.value    = arg
    when '--priority' then self.priority = arg
    end
  end

  def generate
    unless SUPPORTED_TYPES.include?(type)
      Print.err "dns_record: unsupported type '#{type}'. Supported: #{SUPPORTED_TYPES.join(', ')}"
      exit 1
    end
    if hostname.empty? || value.empty?
      Print.err 'dns_record: hostname and value are required'
      exit 1
    end

    record = if type == 'mx'
               "#{hostname}|#{type}|#{value}|#{priority}"
             else
               "#{hostname}|#{type}|#{value}"
             end

    self.outputs << record
  end
end

DnsRecordGenerator.new.run
