require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'Stdlib::HTTPUrl' do
    describe 'valid handling' do
      %w[
        https://hello.com
        https://notcreative.org
        https://canstillaccepthttps.co.uk
        http://anhttp.com
        http://runningoutofideas.gov
        http://
        http://graphemica.com/❤
        http://graphemica.com/緩
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
          'httds://notquiteright.org',
          'hptts:/nah',
          'https;//notrightbutclose.org',
          'hts://graphemica.com/❤',
          'https:graphemica.com/緩',
        ].each do |value|
          describe value.inspect do
            it { is_expected.not_to allow_value(value) }
          end
        end
      end
    end
  end
end
