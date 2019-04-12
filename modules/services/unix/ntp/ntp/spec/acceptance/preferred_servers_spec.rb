require 'spec_helper_acceptance'

if (fact('osfamily') == 'Solaris')
  config = '/etc/inet/ntp.conf'
else
  config = '/etc/ntp.conf'
end

describe 'preferred servers', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  pp = <<-EOS
      class { '::ntp':
        servers           => ['a', 'b', 'c', 'd'],
        preferred_servers => ['c', 'd'],
      }
  EOS

  it 'applies cleanly' do
    apply_manifest(pp, :catch_failures => true) do |r|
      expect(r.stderr).not_to match(/error/i)
    end
  end

  describe file("#{config}") do
    it { should be_file }
    its(:content) { should match 'server a' }
    its(:content) { should match 'server b' }
    its(:content) { should match /server c (iburst\s|)prefer/ }
    its(:content) { should match /server d (iburst\s|)prefer/ }
  end
end
