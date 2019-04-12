require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'test::string', type: :class do
    describe 'accepts strings' do
      [
        '',
        'one',
        nil,
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it { is_expected.to compile }
        end
      end
    end

    describe 'rejects other values' do
      [
        [],
        {},
        1,
        true,
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it { is_expected.to compile.and_raise_error(/parameter 'value' expects a (?:value of type Undef or )?String/) }
        end
      end
    end
  end
end
