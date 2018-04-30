require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache::vhost define' do
  context 'no default vhosts' do
    it 'should create no default vhosts' do
      pp = <<-EOS
        class { 'apache':
          default_vhost => false,
          default_ssl_vhost => false,
          service_ensure => stopped,
        }
        if ($::osfamily == 'Suse') {
          exec { '/usr/bin/gensslcert':
            require => Class['apache'],
          }
         }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/15-default.conf") do
      it { is_expected.not_to be_file }
    end

    describe file("#{$vhost_dir}/15-default-ssl.conf") do
      it { is_expected.not_to be_file }
    end
  end

  context "default vhost without ssl" do
    it 'should create a default vhost config' do
      pp = <<-EOS
        class { 'apache': }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/15-default.conf") do
      it { is_expected.to contain '<VirtualHost \*:80>' }
    end

    describe file("#{$vhost_dir}/15-default-ssl.conf") do
      it { is_expected.not_to be_file }
    end
  end

  context 'default vhost with ssl' do
    it 'should create default vhost configs' do
      pp = <<-EOS
        file { '#{$run_dir}':
          ensure  => 'directory',
          recurse => true,
        }

        class { 'apache':
          default_ssl_vhost => true,
          require => File['#{$run_dir}'],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/15-default.conf") do
      it { is_expected.to contain '<VirtualHost \*:80>' }
    end

    describe file("#{$vhost_dir}/15-default-ssl.conf") do
      it { is_expected.to contain '<VirtualHost \*:443>' }
      it { is_expected.to contain "SSLEngine on" }
    end
  end

  context 'new vhost on port 80' do
    it 'should configure an apache vhost' do
      pp = <<-EOS
        class { 'apache': }
        file { '/var/www':
          ensure  => 'directory',
          recurse => true,
        }

        apache::vhost { 'first.example.com':
          port    => '80',
          docroot => '/var/www/first',
          require => File['/var/www'],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-first.example.com.conf") do
      it { is_expected.to contain '<VirtualHost \*:80>' }
      it { is_expected.to contain "ServerName first.example.com" }
    end
  end

  context 'new proxy vhost on port 80' do
    it 'should configure an apache proxy vhost' do
      pp = <<-EOS
        class { 'apache': }
        apache::vhost { 'proxy.example.com':
          port    => '80',
          docroot => '/var/www/proxy',
          proxy_pass => [
            { 'path' => '/foo', 'url' => 'http://backend-foo/'},
          ],
        proxy_preserve_host   => true,
        proxy_error_override  => true,
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-proxy.example.com.conf") do
      it { is_expected.to contain '<VirtualHost \*:80>' }
      it { is_expected.to contain "ServerName proxy.example.com" }
      it { is_expected.to contain "ProxyPass" }
      it { is_expected.to contain "ProxyPreserveHost On" }
      it { is_expected.to contain "ProxyErrorOverride On" }
      it { is_expected.not_to contain "ProxyAddHeaders" }
      it { is_expected.not_to contain "<Proxy \*>" }
    end
  end

  unless (fact('operatingsystem') == 'SLES' and fact('operatingsystemmajorrelease') <= '10')
    context 'new proxy vhost on port 80' do
      it 'should configure an apache proxy vhost' do
        pp = <<-EOS
          class { 'apache': }
          apache::vhost { 'proxy.example.com':
            port    => '80',
            docroot => '#{$docroot}/proxy',
            proxy_pass_match => [
              { 'path' => '/foo', 'url' => 'http://backend-foo/'},
            ],
          proxy_preserve_host   => true,
          proxy_error_override  => true,
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      describe file("#{$vhost_dir}/25-proxy.example.com.conf") do
        it { is_expected.to contain '<VirtualHost \*:80>' }
        it { is_expected.to contain "ServerName proxy.example.com" }
        it { is_expected.to contain "ProxyPassMatch /foo http://backend-foo/" }
        it { is_expected.to contain "ProxyPreserveHost On" }
        it { is_expected.to contain "ProxyErrorOverride On" }
        it { is_expected.not_to contain "ProxyAddHeaders" }
        it { is_expected.not_to contain "<Proxy \*>" }
      end
    end
  end

  context 'new vhost on port 80' do
    it 'should configure two apache vhosts' do
      pp = <<-EOS
        class { 'apache': }
        apache::vhost { 'first.example.com':
          port    => '80',
          docroot => '/var/www/first',
        }
        host { 'first.example.com': ip => '127.0.0.1', }
        file { '/var/www/first/index.html':
          ensure  => file,
          content => "Hello from first\\n",
        }
        apache::vhost { 'second.example.com':
          port    => '80',
          docroot => '/var/www/second',
        }
        host { 'second.example.com': ip => '127.0.0.1', }
        file { '/var/www/second/index.html':
          ensure  => file,
          content => "Hello from second\\n",
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { is_expected.to be_running }
    end

    it 'should answer to first.example.com' do
      shell("/usr/bin/curl first.example.com:80", {:acceptable_exit_codes => 0}) do |r|
        expect(r.stdout).to eq("Hello from first\n")
      end
    end

    it 'should answer to second.example.com' do
      shell("/usr/bin/curl second.example.com:80", {:acceptable_exit_codes => 0}) do |r|
        expect(r.stdout).to eq("Hello from second\n")
      end
    end
  end

  context 'new vhost with multiple IP addresses on port 80' do
    it 'should configure one apache vhost with 2 ip addresses' do
      pp = <<-EOS
        class { 'apache':
          default_vhost => false,
        }
        apache::vhost { 'example.com':
          port     => '80',
          ip       => ['127.0.0.1','127.0.0.2'],
          ip_based => true,
          docroot  => '/var/www/html',
        }
        host { 'host1.example.com': ip => '127.0.0.1', }
        host { 'host2.example.com': ip => '127.0.0.2', }
        file { '/var/www/html/index.html':
          ensure  => file,
          content => "Hello from vhost\\n",
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { is_expected.to be_running }
    end

    describe file("#{$vhost_dir}/25-example.com.conf") do
      it { is_expected.to contain '<VirtualHost 127.0.0.1:80 127.0.0.2:80>' }
      it { is_expected.to contain "ServerName example.com" }
    end

    describe file($ports_file) do
      it { is_expected.to be_file }
      it { is_expected.to contain 'Listen 127.0.0.1:80' }
      it { is_expected.to contain 'Listen 127.0.0.2:80' }
      it { is_expected.not_to contain 'NameVirtualHost 127.0.0.1:80' }
      it { is_expected.not_to contain 'NameVirtualHost 127.0.0.2:80' }
    end

    it 'should answer to host1.example.com' do
      shell("/usr/bin/curl host1.example.com:80", {:acceptable_exit_codes => 0}) do |r|
        expect(r.stdout).to eq("Hello from vhost\n")
      end
    end

    it 'should answer to host2.example.com' do
      shell("/usr/bin/curl host2.example.com:80", {:acceptable_exit_codes => 0}) do |r|
        expect(r.stdout).to eq("Hello from vhost\n")
      end
    end
  end

  context 'new vhost with IPv6 address on port 80', :ipv6 do
    it 'should configure one apache vhost with an ipv6 address' do
      pp = <<-EOS
        class { 'apache':
          default_vhost  => false,
        }
        apache::vhost { 'example.com':
          port           => '80',
          ip             => '::1',
          ip_based       => true,
          docroot        => '/var/www/html',
        }
        host { 'ipv6.example.com': ip => '::1', }
        file { '/var/www/html/index.html':
          ensure  => file,
          content => "Hello from vhost\\n",
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { is_expected.to be_running }
    end

    describe file("#{$vhost_dir}/25-example.com.conf") do
      it { is_expected.to contain '<VirtualHost [::1]:80>' }
      it { is_expected.to contain "ServerName example.com" }
    end

    describe file($ports_file) do
      it { is_expected.to be_file }
      it { is_expected.to contain 'Listen [::1]:80' }
      it { is_expected.not_to contain 'NameVirtualHost [::1]:80' }
    end

    it 'should answer to ipv6.example.com' do
      shell("/usr/bin/curl ipv6.example.com:80", {:acceptable_exit_codes => 0}) do |r|
        expect(r.stdout).to eq("Hello from vhost\n")
      end
    end
  end

  context 'apache_directories' do
    describe 'readme example, adapted' do
      it 'should configure a vhost with Files' do
        pp = <<-EOS
          class { 'apache': }

          if versioncmp($apache_version, '2.4') >= 0 {
            $_files_match_directory = { 'path' => '(\.swp|\.bak|~)$', 'provider' => 'filesmatch', 'require' => 'all denied', }
          } else {
            $_files_match_directory = { 'path' => '(\.swp|\.bak|~)$', 'provider' => 'filesmatch', 'deny' => 'from all', }
          }

          $_directories = [
            { 'path' => '/var/www/files', },
            $_files_match_directory,
          ]

          apache::vhost { 'files.example.net':
            docroot     => '/var/www/files',
            directories => $_directories,
          }
          file { '/var/www/files/index.html':
            ensure  => file,
            content => "Hello World\\n",
          }
          file { '/var/www/files/index.html.bak':
            ensure  => file,
            content => "Hello World\\n",
          }
          host { 'files.example.net': ip => '127.0.0.1', }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      describe service($service_name) do
        if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
          pending 'Should be enabled - Bug 760616 on Debian 8'
        else
          it { should be_enabled }
        end
        it { is_expected.to be_running }
      end

      it 'should answer to files.example.net' do
        expect(shell("/usr/bin/curl -sSf files.example.net:80/index.html").stdout).to eq("Hello World\n")
        expect(shell("/usr/bin/curl -sSf files.example.net:80/index.html.bak", {:acceptable_exit_codes => 22}).stderr).to match(/curl: \(22\) The requested URL returned error: 403/)
      end
    end

    describe 'other Directory options' do
      it 'should configure a vhost with multiple Directory sections' do
        pp = <<-EOS
          class { 'apache': }

          if versioncmp($apache_version, '2.4') >= 0 {
            $_files_match_directory = { 'path' => 'private.html$', 'provider' => 'filesmatch', 'require' => 'all denied' }
          } else {
            $_files_match_directory = [
              { 'path' => 'private.html$', 'provider' => 'filesmatch', 'deny' => 'from all' },
              { 'path' => '/bar/bar.html', 'provider' => 'location', allow => [ 'from 127.0.0.1', ] },
            ]
          }

          $_directories = [
            { 'path' => '/var/www/files', },
            { 'path' => '/foo/', 'provider' => 'location', 'directoryindex' => 'notindex.html', },
            $_files_match_directory,
          ]

          apache::vhost { 'files.example.net':
            docroot     => '/var/www/files',
            directories => $_directories,
          }
          file { '/var/www/files/foo':
            ensure => directory,
          }
          file { '/var/www/files/foo/notindex.html':
            ensure  => file,
            content => "Hello Foo\\n",
          }
          file { '/var/www/files/private.html':
            ensure  => file,
            content => "Hello World\\n",
          }
          file { '/var/www/files/bar':
            ensure => directory,
          }
          file { '/var/www/files/bar/bar.html':
            ensure  => file,
            content => "Hello Bar\\n",
          }
          host { 'files.example.net': ip => '127.0.0.1', }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      describe service($service_name) do
        if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
          pending 'Should be enabled - Bug 760616 on Debian 8'
        else
          it { should be_enabled }
        end
        it { is_expected.to be_running }
      end

      it 'should answer to files.example.net' do
        expect(shell("/usr/bin/curl -sSf files.example.net:80/").stdout).to eq("Hello World\n")
        expect(shell("/usr/bin/curl -sSf files.example.net:80/foo/").stdout).to eq("Hello Foo\n")
        expect(shell("/usr/bin/curl -sSf files.example.net:80/private.html", {:acceptable_exit_codes => 22}).stderr).to match(/curl: \(22\) The requested URL returned error: 403/)
        expect(shell("/usr/bin/curl -sSf files.example.net:80/bar/bar.html").stdout).to eq("Hello Bar\n")
      end
    end

    describe 'SetHandler directive' do
      it 'should configure a vhost with a SetHandler directive' do
        pp = <<-EOS
          class { 'apache': }
          apache::mod { 'status': }
          host { 'files.example.net': ip => '127.0.0.1', }
          apache::vhost { 'files.example.net':
            docroot     => '/var/www/files',
            directories => [
              { path => '/var/www/files', },
              { path => '/server-status', provider => 'location', sethandler => 'server-status', },
            ],
          }
          file { '/var/www/files/index.html':
            ensure  => file,
            content => "Hello World\\n",
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      describe service($service_name) do
        if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
          pending 'Should be enabled - Bug 760616 on Debian 8'
        else
          it { should be_enabled }
        end
        it { is_expected.to be_running }
      end

      it 'should answer to files.example.net' do
        expect(shell("/usr/bin/curl -sSf files.example.net:80/index.html").stdout).to eq("Hello World\n")
        expect(shell("/usr/bin/curl -sSf files.example.net:80/server-status?auto").stdout).to match(/Scoreboard: /)
      end
    end

    describe 'Satisfy and Auth directive', :unless => $apache_version == '2.4' do
      it 'should configure a vhost with Satisfy and Auth directive' do
        pp = <<-EOS
          class { 'apache': }
          host { 'files.example.net': ip => '127.0.0.1', }
          apache::vhost { 'files.example.net':
            docroot     => '/var/www/files',
            directories => [
              {
                path => '/var/www/files/foo',
                auth_type => 'Basic',
                auth_name => 'Basic Auth',
                auth_user_file => '/var/www/htpasswd',
                auth_require => "valid-user",
              },
              {
                path => '/var/www/files/bar',
                auth_type => 'Basic',
                auth_name => 'Basic Auth',
                auth_user_file => '/var/www/htpasswd',
                auth_require => 'valid-user',
                satisfy => 'Any',
              },
              {
                path => '/var/www/files/baz',
                allow => 'from 10.10.10.10',
                auth_type => 'Basic',
                auth_name => 'Basic Auth',
                auth_user_file => '/var/www/htpasswd',
                auth_require => 'valid-user',
                satisfy => 'Any',
              },
            ],
          }
          file { '/var/www/files/foo':
            ensure => directory,
          }
          file { '/var/www/files/bar':
            ensure => directory,
          }
          file { '/var/www/files/baz':
            ensure => directory,
          }
          file { '/var/www/files/foo/index.html':
            ensure  => file,
            content => "Hello World\\n",
          }
          file { '/var/www/files/bar/index.html':
            ensure  => file,
            content => "Hello World\\n",
          }
          file { '/var/www/files/baz/index.html':
            ensure  => file,
            content => "Hello World\\n",
          }
          file { '/var/www/htpasswd':
            ensure  => file,
            content => "login:IZ7jMcLSx0oQk", # "password" as password
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      describe service($service_name) do
        if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
          pending 'Should be enabled - Bug 760616 on Debian 8'
        else
          it { should be_enabled }
        end
        it { should be_running }
      end

      it 'should answer to files.example.net' do
        shell("/usr/bin/curl -sSf files.example.net:80/foo/index.html", {:acceptable_exit_codes => 22}).stderr.should match(/curl: \(22\) The requested URL returned error: 401/)
        shell("/usr/bin/curl -sSf -u login:password files.example.net:80/foo/index.html").stdout.should eq("Hello World\n")
        shell("/usr/bin/curl -sSf files.example.net:80/bar/index.html").stdout.should eq("Hello World\n")
        shell("/usr/bin/curl -sSf -u login:password files.example.net:80/bar/index.html").stdout.should eq("Hello World\n")
        shell("/usr/bin/curl -sSf files.example.net:80/baz/index.html", {:acceptable_exit_codes => 22}).stderr.should match(/curl: \(22\) The requested URL returned error: 401/)
        shell("/usr/bin/curl -sSf -u login:password files.example.net:80/baz/index.html").stdout.should eq("Hello World\n")
      end
    end
  end

  case fact('lsbdistcodename')
  when 'precise', 'wheezy'
    context 'vhost FallbackResource example' do
      it 'should configure a vhost with FallbackResource' do
        pp = <<-EOS
        class { 'apache': }
        apache::vhost { 'fallback.example.net':
          docroot         => '/var/www/fallback',
          fallbackresource => '/index.html'
        }
        file { '/var/www/fallback/index.html':
          ensure  => file,
          content => "Hello World\\n",
        }
        host { 'fallback.example.net': ip => '127.0.0.1', }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      describe service($service_name) do
        if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
          pending 'Should be enabled - Bug 760616 on Debian 8'
        else
          it { should be_enabled }
        end
        it { is_expected.to be_running }
      end

      it 'should answer to fallback.example.net' do
        shell("/usr/bin/curl fallback.example.net:80/Does/Not/Exist") do |r|
          expect(r.stdout).to eq("Hello World\n")
        end
      end

    end
  else
    # The current stable RHEL release (6.4) comes with Apache httpd 2.2.15
    # That was released March 6, 2010.
    # FallbackResource was backported to 2.2.16, and released July 25, 2010.
    # Ubuntu Lucid (10.04) comes with apache2 2.2.14, released October 3, 2009.
    # https://svn.apache.org/repos/asf/httpd/httpd/branches/2.2.x/STATUS
  end

  context 'virtual_docroot hosting separate sites' do
    it 'should configure a vhost with VirtualDocumentRoot' do
      pp = <<-EOS
        class { 'apache': }
        apache::vhost { 'virt.example.com':
          vhost_name      => '*',
          serveraliases   => '*virt.example.com',
          port            => '80',
          docroot         => '/var/www/virt',
          virtual_docroot => '/var/www/virt/%1',
        }
        host { 'virt.example.com': ip => '127.0.0.1', }
        host { 'a.virt.example.com': ip => '127.0.0.1', }
        host { 'b.virt.example.com': ip => '127.0.0.1', }
        file { [ '/var/www/virt/a', '/var/www/virt/b', ]: ensure => directory, }
        file { '/var/www/virt/a/index.html': ensure  => file, content => "Hello from a.virt\\n", }
        file { '/var/www/virt/b/index.html': ensure  => file, content => "Hello from b.virt\\n", }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { is_expected.to be_running }
    end

    it 'should answer to a.virt.example.com' do
      shell("/usr/bin/curl a.virt.example.com:80", {:acceptable_exit_codes => 0}) do |r|
        expect(r.stdout).to eq("Hello from a.virt\n")
      end
    end

    it 'should answer to b.virt.example.com' do
      shell("/usr/bin/curl b.virt.example.com:80", {:acceptable_exit_codes => 0}) do |r|
        expect(r.stdout).to eq("Hello from b.virt\n")
      end
    end
  end

  context 'proxy_pass for alternative vhost' do
    it 'should configure a local vhost and a proxy vhost' do
      apply_manifest(%{
        class { 'apache': default_vhost => false, }
        apache::vhost { 'localhost':
          docroot => '/var/www/local',
          ip      => '127.0.0.1',
          port    => '8888',
        }
        apache::listen { '*:80': }
        apache::vhost { 'proxy.example.com':
          docroot    => '/var/www',
          port       => '80',
          add_listen => false,
          proxy_pass => {
            'path' => '/',
            'url'  => 'http://localhost:8888/subdir/',
          },
        }
        host { 'proxy.example.com': ip => '127.0.0.1', }
        file { ['/var/www/local', '/var/www/local/subdir']: ensure => directory, }
        file { '/var/www/local/subdir/index.html':
          ensure  => file,
          content => "Hello from localhost\\n",
        }
                     }, :catch_failures => true)
    end

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { is_expected.to be_running }
    end

    it 'should get a response from the back end' do
      shell("/usr/bin/curl --max-redirs 0 proxy.example.com:80") do |r|
        expect(r.stdout).to eq("Hello from localhost\n")
        expect(r.exit_code).to eq(0)
      end
    end
  end

  unless (fact('operatingsystem') == 'SLES' and fact('operatingsystemmajorrelease') <= '10')
    context 'proxy_pass_match for alternative vhost' do
      it 'should configure a local vhost and a proxy vhost' do
        apply_manifest(%{
          class { 'apache': default_vhost => false, }
          apache::vhost { 'localhost':
            docroot => '/var/www/local',
            ip      => '127.0.0.1',
            port    => '8888',
          }
          apache::listen { '*:80': }
          apache::vhost { 'proxy.example.com':
            docroot    => '/var/www',
            port       => '80',
            add_listen => false,
            proxy_pass_match => {
              'path' => '/',
              'url'  => 'http://localhost:8888/subdir/',
            },
          }
          host { 'proxy.example.com': ip => '127.0.0.1', }
          file { ['/var/www/local', '/var/www/local/subdir']: ensure => directory, }
          file { '/var/www/local/subdir/index.html':
            ensure  => file,
            content => "Hello from localhost\\n",
          }
                      }, :catch_failures => true)
      end

      describe service($service_name) do
        if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
          pending 'Should be enabled - Bug 760616 on Debian 8'
        else
          it { should be_enabled }
        end
        it { is_expected.to be_running }
      end

      it 'should get a response from the back end' do
        shell("/usr/bin/curl --max-redirs 0 proxy.example.com:80") do |r|
          expect(r.stdout).to eq("Hello from localhost\n")
          expect(r.exit_code).to eq(0)
        end
      end
    end
  end

  describe 'ip_based' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot    => '/tmp',
          ip_based   => true,
          servername => 'test.server',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file($ports_file) do
      it { is_expected.to be_file }
      it { is_expected.not_to contain 'NameVirtualHost test.server' }
    end
    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain "ServerName test.server" }
    end
  end

  describe 'ip_based and no servername' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot    => '/tmp',
          ip_based   => true,
          servername => '',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file($ports_file) do
      it { is_expected.to be_file }
      it { is_expected.not_to contain 'NameVirtualHost test.server' }
    end
    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.not_to contain "ServerName" }
    end
  end

  describe 'add_listen' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': default_vhost => false }
        host { 'testlisten.server': ip => '127.0.0.1' }
        apache::listen { '81': }
        apache::vhost { 'testlisten.server':
          docroot    => '/tmp',
          port       => '80',
          add_listen => false,
          servername => 'testlisten.server',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file($ports_file) do
      it { is_expected.to be_file }
      it { is_expected.not_to contain 'Listen 80' }
      it { is_expected.to contain 'Listen 81' }
    end
  end

  describe 'docroot' do
    it 'applies cleanly' do
      pp = <<-EOS
        user { 'test_owner': ensure => present, }
        group { 'test_group': ensure => present, }
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot       => '/tmp/test',
          docroot_owner => 'test_owner',
          docroot_group => 'test_group',
          docroot_mode  => '0750',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/tmp/test') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'test_owner' }
      it { is_expected.to be_grouped_into 'test_group' }
      it { is_expected.to be_mode 750 }
    end
  end

  describe 'default_vhost' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot    => '/tmp',
          default_vhost => true,
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file($ports_file) do
      it { is_expected.to be_file }
      if fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') == '7'
        it { is_expected.not_to contain 'NameVirtualHost test.server' }
      elsif fact('operatingsystem') == 'Ubuntu' and fact('operatingsystemrelease') =~ /(14\.04|13\.10|16\.04)/
        it { is_expected.not_to contain 'NameVirtualHost test.server' }
      elsif fact('operatingsystem') == 'Debian' and fact('operatingsystemmajrelease') == '8'
        it { is_expected.not_to contain 'NameVirtualHost test.server' }
      elsif fact('operatingsystem') == 'SLES' and fact('operatingsystemrelease') >= '12'
        it { is_expected.not_to contain 'NameVirtualHost test.server' }
      else
        it { is_expected.to contain 'NameVirtualHost test.server' }
      end
    end

    describe file("#{$vhost_dir}/10-test.server.conf") do
      it { is_expected.to be_file }
    end
  end

  describe 'options' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot    => '/tmp',
          options    => ['Indexes','FollowSymLinks', 'ExecCGI'],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'Options Indexes FollowSymLinks ExecCGI' }
    end
  end

  describe 'override' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot    => '/tmp',
          override   => ['All'],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'AllowOverride All' }
    end
  end

  describe 'logroot' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot    => '/tmp',
          logroot    => '/tmp',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain '  CustomLog "/tmp' }
    end
  end

  ['access', 'error'].each do |logtype|
    case logtype
    when 'access'
      logname = 'CustomLog'
    when 'error'
      logname = 'ErrorLog'
    end

    describe "#{logtype}_log" do
      it 'applies cleanly' do
        pp = <<-EOS
          class { 'apache': }
          host { 'test.server': ip => '127.0.0.1' }
          apache::vhost { 'test.server':
            docroot    => '/tmp',
            logroot    => '/tmp',
        #{logtype}_log => false,
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      describe file("#{$vhost_dir}/25-test.server.conf") do
        it { is_expected.to be_file }
        it { is_expected.not_to contain "  #{logname} \"/tmp" }
      end
    end

    describe "#{logtype}_log_pipe" do
      it 'applies cleanly' do
        pp = <<-EOS
          class { 'apache': }
          host { 'test.server': ip => '127.0.0.1' }
          apache::vhost { 'test.server':
            docroot    => '/tmp',
            logroot    => '/tmp',
        #{logtype}_log_pipe => '|/bin/sh',
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      describe file("#{$vhost_dir}/25-test.server.conf") do
        it { is_expected.to be_file }
        it { is_expected.to contain "  #{logname} \"|/bin/sh" }
      end
    end

    describe "#{logtype}_log_syslog" do
      it 'applies cleanly' do
        pp = <<-EOS
          class { 'apache': }
          host { 'test.server': ip => '127.0.0.1' }
          apache::vhost { 'test.server':
            docroot    => '/tmp',
            logroot    => '/tmp',
        #{logtype}_log_syslog => 'syslog',
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      describe file("#{$vhost_dir}/25-test.server.conf") do
        it { is_expected.to be_file }
        it { is_expected.to contain "  #{logname} \"syslog\"" }
      end
    end
  end

  describe 'access_log_format' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot    => '/tmp',
          logroot    => '/tmp',
          access_log_syslog => 'syslog',
          access_log_format => '%h %l',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'CustomLog "syslog" "%h %l"' }
    end
  end

  describe 'access_log_env_var' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot            => '/tmp',
          logroot            => '/tmp',
          access_log_syslog  => 'syslog',
          access_log_env_var => 'admin',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'CustomLog "syslog" combined env=admin' }
    end
  end

  describe 'multiple access_logs' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot            => '/tmp',
          logroot            => '/tmp',
          access_logs => [
            {'file' => 'log1'},
            {'file' => 'log2', 'env' => 'admin' },
            {'file' => '/var/tmp/log3', 'format' => '%h %l'},
            {'syslog' => 'syslog' }
          ]
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'CustomLog "/tmp/log1" combined' }
      it { is_expected.to contain 'CustomLog "/tmp/log2" combined env=admin' }
      it { is_expected.to contain 'CustomLog "/var/tmp/log3" "%h %l"' }
      it { is_expected.to contain 'CustomLog "syslog" combined' }
    end
  end

  describe 'aliases' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot    => '/tmp',
          aliases => [
            { alias       => '/image'    , path => '/ftp/pub/image' }   ,
            { scriptalias => '/myscript' , path => '/usr/share/myscript' }
          ],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'Alias /image "/ftp/pub/image"' }
      it { is_expected.to contain 'ScriptAlias /myscript "/usr/share/myscript"' }
    end
  end

  describe 'scriptaliases' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot    => '/tmp',
          scriptaliases => [{ alias => '/myscript', path  => '/usr/share/myscript', }],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'ScriptAlias /myscript "/usr/share/myscript"' }
    end
  end

  describe 'proxy' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': service_ensure => stopped, }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot    => '/tmp',
          proxy_dest => 'test2',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'ProxyPass        / test2/' }
    end
  end

  describe 'actions' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot => '/tmp',
          action  => 'php-fastcgi',
        }
      EOS
      pp = pp + "\nclass { 'apache::mod::actions': }" if fact('osfamily') == 'Debian' || fact('osfamily') == 'Suse'
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'Action php-fastcgi /cgi-bin virtual' }
    end
  end

  describe 'suphp' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': service_ensure => stopped, }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot          => '/tmp',
          suphp_addhandler => '#{$suphp_handler}',
          suphp_engine     => 'on',
          suphp_configpath => '#{$suphp_configpath}',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain "suPHP_AddHandler #{$suphp_handler}" }
      it { is_expected.to contain 'suPHP_Engine on' }
      it { is_expected.to contain "suPHP_ConfigPath \"#{$suphp_configpath}\"" }
    end
  end

  describe 'rack_base_uris' do
    unless fact('osfamily') == 'RedHat' or fact('operatingsystem') == 'SLES'
      it 'applies cleanly' do
        test = lambda do
          pp = <<-EOS
            class { 'apache': }
            host { 'test.server': ip => '127.0.0.1' }
            apache::vhost { 'test.server':
              docroot          => '/tmp',
              rack_base_uris  => ['/test'],
            }
          EOS
          apply_manifest(pp, :catch_failures => true)
        end
        test.call
      end
    end
  end

  describe 'no_proxy_uris' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': service_ensure => stopped, }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot          => '/tmp',
          proxy_dest       => 'http://test2',
          no_proxy_uris    => [ 'http://test2/test' ],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'ProxyPass        http://test2/test !' }
      it { is_expected.to contain 'ProxyPass        / http://test2/' }
    end
  end

  describe 'redirect' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot          => '/tmp',
          redirect_source  => ['/images'],
          redirect_dest    => ['http://test.server/'],
          redirect_status  => ['permanent'],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'Redirect permanent /images http://test.server/' }
    end
  end

  describe 'request_headers' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot          => '/tmp',
          request_headers  => ['append MirrorID "mirror 12"'],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'append MirrorID "mirror 12"' }
    end
  end

  describe 'rewrite rules' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot          => '/tmp',
          rewrites => [
            { comment => 'test',
              rewrite_cond => '%{HTTP_USER_AGENT} ^Lynx/ [OR]',
              rewrite_rule => ['^index\.html$ welcome.html'],
              rewrite_map  => ['lc int:tolower'],
            }
          ],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain '#test' }
      it { is_expected.to contain 'RewriteCond %{HTTP_USER_AGENT} ^Lynx/ [OR]' }
      it { is_expected.to contain 'RewriteRule ^index.html$ welcome.html' }
      it { is_expected.to contain 'RewriteMap lc int:tolower' }
    end
  end

  describe 'directory rewrite rules' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        if ! defined(Class['apache::mod::rewrite']) {
          include ::apache::mod::rewrite
        }
        apache::vhost { 'test.server':
          docroot      => '/tmp',
          directories  => [
            {
            path => '/tmp',
            rewrites => [
              {
              comment => 'Permalink Rewrites',
              rewrite_base => '/',
              },
              { rewrite_rule => [ '^index\\.php$ - [L]' ] },
              { rewrite_cond => [
                '%{REQUEST_FILENAME} !-f',
                '%{REQUEST_FILENAME} !-d',                                                                                             ],                                                                                                                     rewrite_rule => [ '. /index.php [L]' ],                                                                              }
              ],
            },
            ],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { should be_file }
      it { should contain '#Permalink Rewrites' }
      it { should contain 'RewriteEngine On' }
      it { should contain 'RewriteBase /' }
      it { should contain 'RewriteRule ^index\.php$ - [L]' }
      it { should contain 'RewriteCond %{REQUEST_FILENAME} !-f' }
      it { should contain 'RewriteCond %{REQUEST_FILENAME} !-d' }
      it { should contain 'RewriteRule . /index.php [L]' }
    end
  end

  describe 'setenv/setenvif' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot  => '/tmp',
          setenv   => ['TEST /test'],
          setenvif => ['Request_URI "\.gif$" object_is_image=gif']
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'SetEnv TEST /test' }
      it { is_expected.to contain 'SetEnvIf Request_URI "\.gif$" object_is_image=gif' }
    end
  end

  describe 'block' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot  => '/tmp',
          block    => 'scm',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain '<DirectoryMatch .*\.(svn|git|bzr|hg|ht)/.*>' }
    end
  end

  describe 'wsgi' do
    context 'on lucid', :if => fact('lsbdistcodename') == 'lucid' do
      it 'import_script applies cleanly' do
        pp = <<-EOS
          class { 'apache': }
          class { 'apache::mod::wsgi': }
          host { 'test.server': ip => '127.0.0.1' }
          apache::vhost { 'test.server':
            docroot                     => '/tmp',
            wsgi_application_group      => '%{GLOBAL}',
            wsgi_daemon_process         => 'wsgi',
            wsgi_daemon_process_options => {processes => '2'},
            wsgi_process_group          => 'nobody',
            wsgi_script_aliases         => { '/test' => '/test1' },
            wsgi_script_aliases_match   => { '/test/([^/*])' => '/test1' },
            wsgi_pass_authorization     => 'On',
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end
    end

    context 'on everything but lucid', :unless => (fact('lsbdistcodename') == 'lucid' or fact('operatingsystem') == 'SLES') do
      it 'import_script applies cleanly' do
        pp = <<-EOS
          class { 'apache': }
          class { 'apache::mod::wsgi': }
          host { 'test.server': ip => '127.0.0.1' }
          apache::vhost { 'test.server':
            docroot                     => '/tmp',
            wsgi_application_group      => '%{GLOBAL}',
            wsgi_daemon_process         => 'wsgi',
            wsgi_daemon_process_options => {processes => '2'},
            wsgi_import_script          => '/test1',
            wsgi_import_script_options  => { application-group => '%{GLOBAL}', process-group => 'wsgi' },
            wsgi_process_group          => 'nobody',
            wsgi_script_aliases         => { '/test' => '/test1' },
            wsgi_script_aliases_match   => { '/test/([^/*])' => '/test1' },
            wsgi_pass_authorization     => 'On',
            wsgi_chunked_request        => 'On',
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      describe file("#{$vhost_dir}/25-test.server.conf") do
        it { is_expected.to be_file }
        it { is_expected.to contain 'WSGIApplicationGroup %{GLOBAL}' }
        it { is_expected.to contain 'WSGIDaemonProcess wsgi processes=2' }
        it { is_expected.to contain 'WSGIImportScript /test1 application-group=%{GLOBAL} process-group=wsgi' }
        it { is_expected.to contain 'WSGIProcessGroup nobody' }
        it { is_expected.to contain 'WSGIScriptAlias /test "/test1"' }
        it { is_expected.to contain 'WSGIPassAuthorization On' }
        it { is_expected.to contain 'WSGIChunkedRequest On' }
      end
    end
  end

  describe 'custom_fragment' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot  => '/tmp',
          custom_fragment => inline_template('#weird test string'),
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain '#weird test string' }
    end
  end

  describe 'itk' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        apache::vhost { 'test.server':
          docroot  => '/tmp',
          itk      => { user => 'nobody', group => 'nobody' }
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'AssignUserId nobody nobody' }
    end
  end

  # Limit testing to Debian, since Centos does not have fastcgi package.
  case fact('osfamily')
  when 'Debian'
    describe 'fastcgi' do
      it 'applies cleanly' do
        pp = <<-EOS
          $_os = $::operatingsystem

          if $_os == 'Ubuntu' {
            $_location = "http://archive.ubuntu.com/ubuntu/"
            $_security_location = "http://archive.ubuntu.com/ubuntu/"
            $_release = $::lsbdistcodename
            $_release_security = "${_release}-security"
            $_repos = "main universe multiverse"
          } else {
            $_location = "http://httpredir.debian.org/debian/"
            $_security_location = "http://security.debian.org/"
            $_release = $::lsbdistcodename
            $_release_security = "${_release}/updates"
            $_repos = "main contrib non-free"
          }

          include ::apt
          apt::source { "${_os}_${_release}":
            location    => $_location,
            release     => $_release,
            repos       => $_repos,
            include_src => false,
          }

          apt::source { "${_os}_${_release}-updates":
            location    => $_location,
            release     => "${_release}-updates",
            repos       => $_repos,
            include_src => false,
          }

          apt::source { "${_os}_${_release}-security":
            location    => $_security_location,
            release     => $_release_security,
            repos       => $_repos,
            include_src => false,
          }
        EOS

        #apt-get update may not run clean here. Should be OK.
        apply_manifest(pp, :catch_failures => false)

        pp2 = <<-EOS
          class { 'apache': }
          class { 'apache::mod::fastcgi': }
          host { 'test.server': ip => '127.0.0.1' }
          apache::vhost { 'test.server':
            docroot        => '/tmp',
            fastcgi_server => 'localhost',
            fastcgi_socket => '/tmp/fast/1234',
            fastcgi_dir    => '/tmp/fast',
          }
        EOS
        apply_manifest(pp2, :catch_failures => true, :acceptable_exit_codes => [0, 2])
      end

      describe file("#{$vhost_dir}/25-test.server.conf") do
        it { is_expected.to be_file }
        it { is_expected.to contain 'FastCgiExternalServer localhost -socket /tmp/fast/1234' }
        it { is_expected.to contain '<Directory "/tmp/fast">' }
      end
    end
  end

  describe 'additional_includes' do
    it 'applies cleanly' do
      pp = <<-EOS
        if $::osfamily == 'RedHat' and "$::selinux" == "true" {
          $semanage_package = $::operatingsystemmajrelease ? {
            '5'     => 'policycoreutils',
            default => 'policycoreutils-python',
          }
          exec { 'set_apache_defaults':
            command => 'semanage fcontext -a -t httpd_sys_content_t "/apache_spec(/.*)?"',
            path    => '/bin:/usr/bin/:/sbin:/usr/sbin',
            require => Package[$semanage_package],
          }
          package { $semanage_package: ensure => installed }
          exec { 'restorecon_apache':
            command => 'restorecon -Rv /apache_spec',
            path    => '/bin:/usr/bin/:/sbin:/usr/sbin',
            before  => Service['httpd'],
            require => Class['apache'],
          }
        }
        class { 'apache': }
        host { 'test.server': ip => '127.0.0.1' }
        file { '/apache_spec': ensure => directory, }
        file { '/apache_spec/include': ensure => present, content => '#additional_includes' }
        apache::vhost { 'test.server':
          docroot             => '/apache_spec',
          additional_includes => '/apache_spec/include',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'Include "/apache_spec/include"' }
    end
  end

  describe 'virtualhost without priority prefix' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        apache::vhost { 'test.server':
          priority => false,
          docroot => '/tmp'
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/test.server.conf") do
      it { is_expected.to be_file }
    end
  end

  describe 'SSLProtocol directive' do
    it 'applies cleanly' do
      pp = <<-EOS
        class { 'apache': }
        apache::vhost { 'test.server':
          docroot      => '/tmp',
          ssl          => true,
          ssl_protocol => ['All', '-SSLv2'],
        }
        apache::vhost { 'test2.server':
          docroot      => '/tmp',
          ssl          => true,
          ssl_protocol => 'All -SSLv2',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    describe file("#{$vhost_dir}/25-test.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'SSLProtocol  *All -SSLv2' }
    end

    describe file("#{$vhost_dir}/25-test2.server.conf") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'SSLProtocol  *All -SSLv2' }
    end
  end
end
