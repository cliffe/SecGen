require 'spec_helper_acceptance'

if (fact('osfamily') == 'Solaris')
  config = '/etc/inet/ntp.conf'
else
  config = '/etc/ntp.conf'
end

describe "ntp class with disable_monitor:", :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'should run successfully' do
    pp = "class { 'ntp': disable_monitor => true }"

    it 'runs twice' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{config}") do
      its(:content) { should match('disable monitor') }
    end
  end

  context 'should run successfully' do
    pp = "class { 'ntp': disable_monitor => false }"

    it 'runs twice' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{config}") do
      its(:content) { should_not match('disable monitor') }
    end
  end

end
