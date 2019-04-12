require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'test::httpsurl', type: :class do
    describe 'valid handling' do
      %w{
        https://hello.com
        https://notcreative.org
        https://notexciting.co.uk
        https://graphemica.com/❤
        https://graphemica.com/緩
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
          "hptts:/nah",
          "https;//notrightbutclose.org",
          "http://graphemica.com/❤",
           "http://graphemica.com/緩"
        ].each do |value|
          describe value.inspect do
            let(:params) {{ value: value }}
            it { is_expected.to compile.and_raise_error(/parameter 'value' expects a match for Stdlib::HTTPSUrl/) }
          end
        end
      end

    end
  end
end
