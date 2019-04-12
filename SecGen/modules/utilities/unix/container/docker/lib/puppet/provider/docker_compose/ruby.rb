Puppet::Type.type(:docker_compose).provide(:ruby) do
  desc 'Support for Puppet running Docker Compose'

  mk_resource_methods
  commands dockercompose: 'docker-compose'
  commands docker: 'docker'

  def exists?
    Puppet.info("Checking for compose project #{name}")
    compose_services = {}
    resource[:compose_files].each do |file|
      compose_file = YAML.safe_load(File.read(file))
      containers = docker([
                            'ps',
                            '--format',
                            "{{.Label \"com.docker.compose.service\"}}-{{.Image}}",
                            '--filter',
                            "label=com.docker.compose.project=#{name}",
                          ]).split("\n")
      case compose_file['version']
      when %r{^2(\.[0-3])?$}, %r{^3(\.[0-6])?$}
        compose_services = compose_services.merge(compose_file['services'])
      # in compose v1 "version" parameter is not specified
      when nil
        compose_services = compose_services.merge(compose_file)
      else
        raise(Puppet::Error, "Unsupported docker compose file syntax version \"#{compose_file['version']}\"!")
      end

      if compose_services.count != containers.count
        return false
      end

      counts = Hash[*compose_services.each.map { |key, array|
                      image = (array['image']) ? array['image'] : get_image(key, compose_services)
                      Puppet.info("Checking for compose service #{key} #{image}")
                      ["#{key}-#{image}", containers.count("#{key}-#{image}")]
                    }.flatten]

      # No containers found for the project
      if counts.empty? ||
         # Containers described in the compose file are not running
         counts.any? { |_k, v| v.zero? } ||
         # The scaling factors in the resource do not match the number of running containers
         resource[:scale] && counts.merge(resource[:scale]) != counts
        false
      else
        true
      end
    end
  end

  def get_image(service_name, compose_services)
    image = compose_services[service_name]['image']
    unless image
      if compose_services[service_name]['extends']
        image = get_image(compose_services[service_name]['extends'], compose_services)
      elsif compose_services[service_name]['build']
        image = "#{project}_#{service_name}"
      end
    end
    image
  end

  def create
    Puppet.info("Running compose project #{name}")
    args = [compose_files, '-p', name, 'up', '-d', '--remove-orphans'].insert(2, resource[:options]).insert(5, resource[:up_args]).compact
    dockercompose(args)
    return unless resource[:scale]
    instructions = resource[:scale].map { |k, v| "#{k}=#{v}" }
    Puppet.info("Scaling compose project #{project}: #{instructions.join(' ')}")
    args = [compose_files, '-p', name, 'scale'].insert(2, resource[:options]).compact + instructions
    dockercompose(args)
  end

  def destroy
    Puppet.info("Removing all containers for compose project #{name}")
    kill_args = [compose_files, '-p', name, 'kill'].insert(2, resource[:options]).compact
    dockercompose(kill_args)
    rm_args = [compose_files, '-p', name, 'rm', '--force', '-v'].insert(2, resource[:options]).compact
    dockercompose(rm_args)
  end

  def restart
    return unless exists?
    Puppet.info("Rebuilding and Restarting all containers for compose project #{name}")
    kill_args = [compose_files, '-p', name, 'kill'].insert(2, resource[:options]).compact
    dockercompose(kill_args)
    build_args = [compose_files, '-p', name, 'build'].insert(2, resource[:options]).compact
    dockercompose(build_args)
    create
  end

  def compose_files
    resource[:compose_files].map { |x| ['-f', x] }.flatten
  end

  private
end
