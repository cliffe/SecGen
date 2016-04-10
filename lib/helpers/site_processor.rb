require 'erb'

class SiteProcessor


  def initialize(sites)
    @sites = sites
  end
  def generate_script
    print @sites
    template_path = '../../mount/puppet/module/wordpress/files/wpcli-install.sh.erb'
    renderer = ERB.new(File.read(template_path), 0, '>')
    return renderer.result(get_binding)
  end

  def get_binding
    binding
  end


end