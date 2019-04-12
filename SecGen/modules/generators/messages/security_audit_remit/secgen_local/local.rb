#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'erb'
require 'fileutils'
class SecurityAuditRemitGenerator < StringGenerator
  attr_accessor :business_name
  attr_accessor :business_location
  attr_accessor :local_backup
  attr_accessor :remote_backup
  attr_accessor :physical_security
  LOCAL_DIR = File.expand_path('../../',__FILE__)
  TEMPLATE_PATH = "#{LOCAL_DIR}/templates/security_audit_remit.md.erb"

  def initialize
    super
    self.module_name = 'Security Audit Remit Generator'
    self.business_name = ''
    self.business_location = ''
    self.local_backup = ''
    self.remote_backup = ''
    self.physical_security = ''
  end

  def get_options_array
    super + [['--name', GetoptLong::REQUIRED_ARGUMENT],
             ['--business_name', GetoptLong::REQUIRED_ARGUMENT],
             ['--business_location', GetoptLong::OPTIONAL_ARGUMENT],
             ['--local_backup', GetoptLong::OPTIONAL_ARGUMENT],
             ['--remote_backup', GetoptLong::OPTIONAL_ARGUMENT],
             ['--physical_security', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--name'
        self.name << arg;
      when '--business_name'
        self.business_name << arg;
      when '--business_location'
        self.business_location << arg;
      when '--local_backup'
        self.local_backup << arg;
      when '--remote_backup'
        self.remote_backup << arg;
      when '--physical_security'
        self.physical_security << arg;
    end
  end

  def generate

    template_out = ERB.new(File.read(TEMPLATE_PATH), 0, '<>-')
    self.outputs << template_out.result(self.get_binding)
  end

  # Returns binding for erb files (access to variables in this classes scope)
  # @return binding
  def get_binding
    binding
  end
end


SecurityAuditRemitGenerator.new.run