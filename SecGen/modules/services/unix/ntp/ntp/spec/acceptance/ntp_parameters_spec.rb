require 'spec_helper_acceptance'

case fact('osfamily')
when 'FreeBSD'
  packagename = 'net/ntp'
when 'Gentoo'
  packagename = 'net-misc/ntp'
when 'Linux'
  case fact('operatingsystem')
  when 'ArchLinux'
    packagename = 'ntp'
  when 'Gentoo'
    packagename = 'net-misc/ntp'
  end
when 'AIX'
  packagename = 'bos.net.tcp.client'
when 'Solaris'
  case fact('kernelrelease')
  when '5.10'
    packagename = ['SUNWntpr','SUNWntpu']
  when '5.11'
    packagename = 'service/network/ntp'
  end
else
  if fact('operatingsystem') == 'SLES' and fact('operatingsystemmajrelease') == '12'
    servicename = 'ntpd'
  else
    servicename = 'ntp'
  end
end

if (fact('osfamily') == 'RedHat')
  keysfile = '/etc/ntp/keys'
elsif (fact('osfamily') == 'Solaris')
  keysfile = '/etc/inet/ntp.keys'
else
  keysfile = '/etc/ntp.keys'
end

if (fact('osfamily') == 'Solaris')
  config = '/etc/inet/ntp.conf'
else
  config = '/etc/ntp.conf'
end

describe "ntp class:", :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'applies successfully' do
    pp = "class { 'ntp': }"

    apply_manifest(pp, :catch_failures => true) do |r|
      expect(r.stderr).not_to match(/error/i)
    end
  end

  describe 'autoconfig' do
    it 'raises a deprecation warning' do
      pp = "class { 'ntp': autoupdate => true }"

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/autoupdate parameter has been deprecated and replaced with package_ensure/)
      end
    end
  end

  describe 'config' do
    it 'sets the ntp.conf location' do
      pp = "class { 'ntp': config => '/etc/antp.conf' }"
      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/antp.conf') do
      it { should be_file }
    end
  end

  describe 'config_template' do
    it 'sets up template' do
      modulepath = default['distmoduledir']
      shell("mkdir -p #{modulepath}/test/templates")
      shell("echo 'testcontent' >> #{modulepath}/test/templates/ntp.conf")
    end

    it 'sets the ntp.conf location' do
      pp = "class { 'ntp': config_template => 'test/ntp.conf' }"
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{config}") do
      it { should be_file }
      its(:content) { should match 'testcontent' }
    end
  end

  describe 'driftfile' do
    it 'sets the driftfile location' do
      pp = "class { 'ntp': driftfile => '/tmp/driftfile' }"
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{config}") do
      it { should be_file }
      its(:content) { should match 'driftfile /tmp/driftfile' }
    end
  end

  describe 'keys' do
    it 'enables the key parameters' do
      pp = <<-EOS
      class { 'ntp':
        keys_enable     => true,
        keys_controlkey => '15',
        keys_requestkey => '1',
        keys_trusted    => [ '1', '2' ],
        keys            => [ '1 M AAAABBBB' ],
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{config}") do
      it { should be_file }
      its(:content) { should match "keys #{keysfile}" }
      its(:content) { should match 'controlkey 15' }
      its(:content) { should match 'requestkey 1' }
      its(:content) { should match 'trustedkey 1 2' }
    end

    describe file(keysfile) do
      it { should be_file }
      its(:content) { should match '1 M AAAABBBB' }
    end
  end

  describe 'package' do
    it 'installs the right package' do
      pp = <<-EOS
      class { 'ntp':
        package_ensure => present,
        package_name   => #{Array(packagename).inspect},
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    Array(packagename).each do |package|
      describe package(package) do
        it { should be_installed }
      end
    end
  end

  describe 'panic => 0' do
    it 'disables the tinker panic setting' do
      pp = <<-EOS
      class { 'ntp':
        panic => 0,
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{config}") do
      its(:content) { should match 'tinker panic 0' }
    end
  end

  describe 'panic => 1' do
    it 'enables the tinker panic setting' do
      pp = <<-EOS
      class { 'ntp':
        panic => 1,
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{config}") do
      its(:content) { should match 'tinker panic 1' }
    end
  end

  describe 'udlc' do
    it 'adds a udlc' do
      pp = "class { 'ntp': udlc => true }"
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{config}") do
      it { should be_file }
      its(:content) { should match '127.127.1.0' }
    end
  end

  describe 'udlc_stratum' do
    it 'sets the stratum value when using udlc' do
      pp = "class { 'ntp': udlc => true, udlc_stratum => 10 }"
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{config}") do
      it { should be_file }
      its(:content) { should match 'stratum 10' }
    end
  end

end
