require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'Stdlib::Unixpath' do
    describe 'valid handling' do
      %w[
        /usr2/username/bin:/usr/local/bin:/usr/bin:.
        /var/tmp
        /Users/helencampbell/workspace/puppetlabs-stdlib
        /var/ůťƒ8
        /var/ネット
        /var//tmp
        /var/../tmp
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end

    describe 'invalid path handling' do
      context 'with garbage inputs' do
        [
          nil,
          [nil],
          [nil, nil],
          { 'foo' => 'bar' },
          {},
          '',
          'C:/whatever',
          '\\var\\tmp',
          '\\Users/hc/wksp/stdlib',
          '*/Users//nope',
          "var\ůťƒ8",
          "var\ネット",
        ].each do |value|
          describe value.inspect do
            it { is_expected.not_to allow_value(value) }
          end
        end
      end
    end
  end
end
