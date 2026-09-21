#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_hackerbot_config_generator.rb'

class HB < HackerbotConfigGenerator

  attr_accessor :chroot_esc_server_ip
  attr_accessor :docker_esc_server_ip

  def initialize
    super
    self.module_name = 'Hackerbot Config Generator'
    self.title = 'Lab'

    self.local_dir = File.expand_path('../../',__FILE__)
    self.templates_path = "#{self.local_dir}/templates/"
    self.config_template_path = "#{self.local_dir}/templates/lab.xml.erb"

    self.chroot_esc_server_ip = []
    self.docker_esc_server_ip = []
  end

  def get_options_array
    super + [['--chroot_esc_server_ip', GetoptLong::REQUIRED_ARGUMENT],
      ['--docker_esc_server_ip', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--chroot_esc_server_ip'
        self.chroot_esc_server_ip << arg;
      when '--docker_esc_server_ip'
        self.docker_esc_server_ip << arg;
    end
  end

end

HB.new.run
