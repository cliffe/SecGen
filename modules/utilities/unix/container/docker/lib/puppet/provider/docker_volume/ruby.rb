require 'json'

Puppet::Type.type(:docker_volume).provide(:ruby) do
  desc 'Support for Docker Volumes'

  mk_resource_methods
  commands docker: 'docker'

  def volume_conf
    flags = %w[volume create]
    multi_flags = lambda { |values, format|
      filtered = [values].flatten.compact
      filtered.map { |val| sprintf(format, val) }
    }

    [
      ['--driver=%s', :driver],
      ['--opt=%s', :options],
    ].each do |(format, key)|
      values = resource[key]
      new_flags = multi_flags.call(values, format)
      flags.concat(new_flags)
    end
    flags << resource[:name]
  end

  def self.instances
    output = docker(%w[volume ls])
    lines = output.split("\n")
    lines.shift # remove header row
    lines.map do |line|
      driver, name = line.split(' ')
      inspect = docker(['volume', 'inspect', name])
      obj = JSON.parse(inspect).first
      new(
        :name => name,
        :mountpoint => obj['Mountpoint'],
        :options => obj['Options'],
        :ensure  => :present,
        :driver  => driver,
      )
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def exists?
    Puppet.info("Checking if docker volume #{name} exists")
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.info("Creating docker volume #{name}")
    docker(volume_conf)
  end

  def destroy
    Puppet.info("Removing docker volume #{name}")
    docker(['volume', 'rm', name])
  end
end
