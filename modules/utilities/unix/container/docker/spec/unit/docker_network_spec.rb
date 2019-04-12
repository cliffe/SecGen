require 'spec_helper'

network = Puppet::Type.type(:docker_network)

describe network do

  let :params do
    [
      :name,
      :provider,
      :gateway,
      :ip_range,
      :aux_address,
      :options,
    ]
  end

  let :properties do
    [
      :ensure,
      :driver,
      :ipam_driver,
      :id,
    ]
  end

  it 'should have expected properties' do
    properties.each do |property|
      expect(network.properties.map(&:name)).to be_include(property)
    end
  end

  it 'should have expected parameters' do
    params.each do |param|
      expect(network.parameters).to be_include(param)
    end
  end
end
