require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'test::bool', type: :class do
    describe 'accepts booleans' do
      [
        true,
        false,
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it { is_expected.to compile }
        end
      end
    end

    describe 'rejects other values' do
      [
        [1],
        [{}],
        [true],
        'true',
        'false',
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it { is_expected.to compile.and_raise_error(/parameter 'value' expects a Stdlib::Compat::Bool/) }
        end
      end
    end
  end
end
