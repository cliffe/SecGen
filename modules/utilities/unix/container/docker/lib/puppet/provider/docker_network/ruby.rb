require 'json'

Puppet::Type.type(:docker_network).provide(:ruby) do
  desc 'Support for Docker Networking'

  mk_resource_methods
  commands docker: 'docker'

  def network_conf
    flags = %w[network create]
    multi_flags = lambda { |values, format|
      filtered = [values].flatten.compact
      filtered.map { |val| sprintf(format, val) }
    }

    [
      ['--driver=%s',       :driver],
      ['--subnet=%s',       :subnet],
      ['--gateway=%s',      :gateway],
      ['--ip-range=%s',     :ip_range],
      ['--ipam-driver=%s',  :ipam_driver],
      ['--aux-address=%s',  :aux_address],
      ['--opt=%s',          :options],
      ['%s',                :additional_flags],
    ].each do |(format, key)|
      values    = resource[key]
      new_flags = multi_flags.call(values, format)
      flags.concat(new_flags)
    end
    flags << resource[:name]
  end

  def self.instances
    output = docker(%w[network ls])
    lines = output.split("\n")
    lines.shift # remove header row
    lines.map do |line|
      _, name, driver = line.split(' ')
      inspect = docker(['network', 'inspect', name])
      obj = JSON.parse(inspect).first
      ipam_driver = unless obj['IPAM']['Driver'].nil?
                      obj['IPAM']['Driver']
                    end
      subnet = unless obj['IPAM']['Config'].nil? || obj['IPAM']['Config'].empty?
                 if obj['IPAM']['Config'].first.key? 'Subnet'
                   obj['IPAM']['Config'].first['Subnet']
                 end
               end
      new(
        :name => name,
        :id => obj['Id'],
        :ipam_driver => ipam_driver,
        :subnet => subnet,
        :ensure => :present,
        :driver => driver,
      )
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name] # rubocop:disable Lint/AssignmentInCondition
        resource.provider = prov
      end
    end
  end

  def flush
    raise Puppet::Error, _('Docker network does not support mutating existing networks') if !@property_hash.empty? && @property_hash[:ensure] != :absent
  end

  def exists?
    Puppet.info("Checking if docker network #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating docker network #{name}")
    docker(network_conf)
  end

  def destroy
    Puppet.info("Removing docker network #{name}")
    docker(['network', 'rm', name])
  end
end
