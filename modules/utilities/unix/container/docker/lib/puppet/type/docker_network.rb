Puppet::Type.newtype(:docker_network) do
  @doc = 'Type representing a Docker network'
  ensurable

  newparam(:name) do
    isnamevar
    desc 'The name of the network'
  end

  newproperty(:driver) do
    desc 'The network driver used by the network'
  end

  newproperty(:subnet) do
    desc 'The subnet in CIDR format that represents a network segment'
  end

  newparam(:gateway) do
    desc 'An ipv4 or ipv6 gateway for the master subnet'
  end

  newparam(:ip_range) do
    desc 'The range of IP addresses used by the network'
  end

  newproperty(:ipam_driver) do
    desc 'The IPAM (IP Address Management) driver'
  end

  newparam(:aux_address) do
    desc 'Auxiliary ipv4 or ipv6 addresses used by the Network driver'
  end

  newparam(:options) do
    desc 'Additional options for the network driver'
  end

  newparam(:additional_flags) do
    desc "Additional flags for the 'docker network create'"
  end

  newproperty(:id) do
    desc 'The ID of the network provided by Docker'
    validate do |value|
      raise(Puppet::ParseError, "#{value} is read-only and is only available via puppet resource.")
    end
  end
end
