require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'test::ipv6', type: :class do
    describe 'accepts ipv6 addresses' do
      [
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
        'fa76:8765:34ac:0823:ab76:eee9:0987:1111',
        'fe80:0000:0000:0000:0204:61ff:fe9d:f156',
        'fe80:0:0:0:204:61ff:fe9d:f156',
        'fe80::204:61ff:fe9d:f156',
        'fe80:0:0:0:0204:61ff:254.157.241.86',
        '::1',
        'fe80::',
        '2001::',
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it { is_expected.to compile }
        end
      end
    end
    describe 'rejects other values' do
      [
        'nope',
        '77',
        '4.4.4',
        '2000:7334',
        '::ffff:2.3.4',
        '::ffff:257.1.2.3',
        '::ffff:12345678901234567890.1.26',
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it { is_expected.to compile.and_raise_error(/parameter 'value' expects a match for Stdlib::Compat::Ipv6/) }
        end
      end
    end
  end
end
