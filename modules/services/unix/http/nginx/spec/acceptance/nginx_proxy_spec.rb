require 'spec_helper_acceptance'

describe "nginx::resource::upstream define:" do
  it 'should run successfully' do

    pp = "
    class { 'nginx': }
    nginx::resource::upstream { 'puppet_rack_app':
      ensure  => present,
      members => [
        'localhost:3000',
        'localhost:3001',
        'localhost:3002',
      ],
    }
    nginx::resource::vhost { 'rack.puppetlabs.com':
      ensure => present,
      proxy  => 'http://puppet_rack_app',
    }
    "

    apply_manifest(pp, :catch_failures => true)
  end

  describe file('/etc/nginx/conf.d/puppet_rack_app-upstream.conf') do
   it { is_expected.to be_file }
   it { is_expected.to contain "server     localhost:3000" }
   it { is_expected.to contain "server     localhost:3001" }
   it { is_expected.to contain "server     localhost:3002" }
   it { is_expected.not_to contain "server     localhost:3003" }
  end

  describe file('/etc/nginx/sites-available/rack.puppetlabs.com.conf') do
    it { is_expected.to be_file }
    it { is_expected.to contain "proxy_pass            http://puppet_rack_app;" }
  end

end
