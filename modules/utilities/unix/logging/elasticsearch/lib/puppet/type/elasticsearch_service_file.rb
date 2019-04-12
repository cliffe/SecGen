$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'puppet/util/checksums'

require 'puppet_x/elastic/es_versioning'

Puppet::Type.newtype(:elasticsearch_service_file) do
  @doc = 'Manages elasticsearch service files.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Fully qualified path to the service file.'
  end

  newproperty(:content) do
    include Puppet::Util::Checksums

    desc 'Service file contents in erb template form.'

    # Interploate the erb source before comparing it to the on-disk
    # init script
    def insync?(is)
      _opt_flag, opt_flags = Puppet_X::Elastic::EsVersioning.opt_flags(
        resource[:package_name], resource.catalog
      )
      # This should only be present on systemd systems.
      opt_flags.delete('--quiet') unless resource[:name].include?('systemd')

      template = ERB.new(should, 0, '-')
      is == template.result(binding)
    end

    # Represent as a checksum, not the whole file
    def change_to_s(currentvalue, newvalue)
      algo = Puppet[:digest_algorithm].to_sym

      if currentvalue == :absent
        return "defined content as '#{send(algo, newvalue)}'"
      elsif newvalue == :absent
        return "undefined content from '#{send(algo, currentvalue)}'"
      else
        return "content changed '#{send(algo, currentvalue)}' to '#{send(algo, newvalue)}'"
      end
    end
  end

  newparam(:defaults_location) do
    desc 'File path to defaults file.'
  end

  newparam(:group) do
    desc 'Group to run service under.'
  end

  newparam(:homedir) do
    desc 'Elasticsearch home directory.'
  end

  newparam(:instance) do
    desc 'Elasticsearch instance name.'
  end

  newparam(:memlock) do
    desc 'Memlock setting for service.'
  end

  newparam(:nofile) do
    desc 'Service NOFILE ulimit.'
  end

  newparam(:nproc) do
    desc 'Service NPROC ulimit.'
  end

  newparam(:package_name) do
    desc 'Name of the system Elasticsearch package.'
  end

  newparam(:pid_dir) do
    desc 'Directory to use for storing service PID.'
  end

  newparam(:user) do
    desc 'User to run service under.'
  end
end
