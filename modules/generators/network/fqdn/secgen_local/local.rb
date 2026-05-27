#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
class FQDNGenerator < StringGenerator
  attr_accessor :domain
  attr_accessor :subdomains

  def initialize
    super
    self.module_name = 'FQDN Generator'
    self.domain = ''
    self.subdomains = []
  end

  def get_options_array
    super + [
      ['--domain',     GetoptLong::REQUIRED_ARGUMENT],
      ['--subdomains', GetoptLong::REQUIRED_ARGUMENT],
    ]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--domain'
      self.domain = arg
    when '--subdomains'
      self.subdomains << arg
    end
  end

  def generate
    if domain.empty?
      Print.err 'domain_generator: domain is required'
      exit 1
    end

    fqdn = (subdomains.reverse + [domain]).join('.')
    self.outputs << fqdn
  end
end
FQDNGenerator.new.run