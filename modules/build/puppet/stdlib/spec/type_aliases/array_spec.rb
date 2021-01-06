require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'Stdlib::Compat::Array' do
    describe 'accepts arrays' do
      [
        [],
        ['one'],
        [1],
        [{}],
        [[]],
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end

    describe 'rejects other values' do
      [
        '',
        'one',
        '1',
        {},
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
