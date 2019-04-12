require 'spec_helper'

volume = Puppet::Type.type(:docker_volume)

describe volume do
  let :params do
    [
      :name,
      :provider,
    ]
  end

  let :properties do
    [
      :driver,
      :options,
      :mountpoint,
    ]
  end

  it 'should have expected properties' do
    properties.each do |property|
      expect(volume.properties.map(&:name)).to be_include(property)
    end
  end

  it 'should have expected parameters' do
    params.each do |param|
      expect(volume.parameters).to be_include(param)
    end
  end
end