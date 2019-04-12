$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

require 'pathname'
require 'puppet/util/filetype'

require 'puppet_x/elastic/es_versioning'

Puppet::Type.type(:elasticsearch_service_file).provide(:ruby) do
  desc <<-ENDHEREDOC
    Provides management of elasticsearch service files.
  ENDHEREDOC

  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.services
    [
      '/usr/lib/systemd/system/elasticsearch-',
      '/lib/systemd/system/elasticsearch-',
      '/etc/init.d/elasticsearch.',
      '/etc/init.d/elasticsearch-',
      '/etc/rc.d/elasticsearch_'
    ].map do |path|
      Pathname.glob(path + '*').map do |service|
        {
          :name => service.to_s,
          :ensure => :present,
          :provider => :ruby,
          :content => Puppet::Util::FileType.filetype(:flat).new(service.to_s).read
        }
      end
    end.flatten.compact
  end

  def self.instances
    services.map do |instance|
      new instance
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy?
    @property_flush[:ensure] = :absent
  end

  def flush
    opt_flag, opt_flags = Puppet_X::Elastic::EsVersioning.opt_flags(
      resource[:package_name], resource.catalog
    )
    # This should only be present on systemd systems.
    opt_flags.delete('--quiet') unless resource[:name].include?('systemd')

    template = ERB.new(resource[:content], 0, '-')
    result = template.result(binding)

    Puppet::Util::FileType.filetype(:flat).new(resource[:name]).write(result)

    @property_hash = self.class.services.detect do |t|
      t[:name] == resource[:name]
    end
  end
end # of .provide
