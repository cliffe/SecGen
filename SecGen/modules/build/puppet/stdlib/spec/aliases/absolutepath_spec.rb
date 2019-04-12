require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'test::absolutepath', type: :class do
    describe 'valid handling' do
      %w{
        /usr2/username/bin:/usr/local/bin:/usr/bin:.
        C:/
        C:\\
        C:\\WINDOWS\\System32
        C:/windows/system32
        X:/foo/bar
        X:\\foo\\bar
        \\\\host\\windows
        //host/windows
        /var/tmp
        /var/opt/../lib/puppet
        /var/opt//lib/puppet
      }.each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it { is_expected.to compile }
        end
      end
    end

    describe 'invalid path handling' do
      context 'garbage inputs' do
        [
          nil,
          [ nil ],
          [ nil, nil ],
          { 'foo' => 'bar' },
          { },
          '',
          "*/Users//nope",
          "\\Users/hc/wksp/stdlib",
          "C:noslashes",
          "\\var\\tmp"
        ].each do |value|
          describe value.inspect do
            let(:params) {{ value: value }}
            it { is_expected.to compile.and_raise_error(/parameter 'value' expects a match for Variant/) }
          end
        end
      end

    end
  end
end
