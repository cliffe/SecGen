require 'erb'
require_relative '../../lib/constants'
class SiteProcessor


  def initialize(sites)
    @sites = sites
  end
  def generate_script
    print @sites
    template_path = "#{ROOT_DIR}/mount/puppet/module/wordpress/files/wpcli-install.sh.erb"
    renderer = ERB.new(File.read(template_path), 0, '>')

    File.open("#{ROOT_DIR}/mount/puppet/module/wordpress/files/wpcli-install.sh", 'w') { |file| file.write(renderer.result(get_binding)) }
  end

  def get_binding
    binding
  end


end