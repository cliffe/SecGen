require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'Stdlib::Compat::Ipv4' do
    describe 'accepts ipv4 addresses' do
      SharedData::IPV4_PATTERNS.each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end
    describe 'rejects other values' do
      SharedData::IPV4_NEGATIVE_PATTERNS.each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
