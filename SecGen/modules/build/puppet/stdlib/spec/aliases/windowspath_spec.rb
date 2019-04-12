require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'test::windowspath', type: :class do
    describe 'valid handling' do
      %w{
        C:\\
        C:\\WINDOWS\\System32
        C:/windows/system32
        X:/foo/bar
        X:\\foo\\bar
        \\\\host\\windows
        X:/var/ůťƒ8
        X:/var/ネット
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
          "httds://notquiteright.org",
          "/usr2/username/bin:/usr/local/bin:/usr/bin:.",
          "C;//notright/here",
          "C:noslashes",
          "C:ネット",
          "C:ůťƒ8"
        ].each do |value|
          describe value.inspect do
            let(:params) {{ value: value }}
            it { is_expected.to compile.and_raise_error(/parameter 'value' expects a match for Stdlib::Windowspath/) }
          end
        end
      end
    end
  end
end
