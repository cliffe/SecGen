require 'spec_helper'

describe 'apache::vhost', :type => :define do
  let :pre_condition do
    'class { "apache": default_vhost => false, default_mods => false, vhost_enable_dir => "/etc/apache2/sites-enabled"}'
  end
  let :title do
    'rspec.example.com'
  end
  let :default_params do
    {
      :docroot => '/rspec/docroot',
      :port    => '84',
    }
  end
  describe 'os-dependent items' do
    context "on RedHat based systems" do
      let :default_facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'RedHat',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end
      let :params do default_params end
      let :facts do default_facts end
      it { is_expected.to contain_class("apache") }
      it { is_expected.to contain_class("apache::params") }
    end
    context "on Debian based systems" do
      let :default_facts do
        {
          :osfamily               => 'Debian',
          :operatingsystemrelease => '6',
          :concat_basedir         => '/dne',
          :lsbdistcodename        => 'squeeze',
          :operatingsystem        => 'Debian',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end
      let :params do default_params end
      let :facts do default_facts end
      it { is_expected.to contain_class("apache") }
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_concat("25-rspec.example.com.conf").with(
        :ensure => 'present',
        :path   => '/etc/apache2/sites-available/25-rspec.example.com.conf'
      ) }
      it { is_expected.to contain_file("25-rspec.example.com.conf symlink").with(
        :ensure => 'link',
        :path   => '/etc/apache2/sites-enabled/25-rspec.example.com.conf',
        :target => '/etc/apache2/sites-available/25-rspec.example.com.conf'
      ) }
    end
    context "on FreeBSD systems" do
      let :default_facts do
        {
          :osfamily               => 'FreeBSD',
          :operatingsystemrelease => '9',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'FreeBSD',
          :id                     => 'root',
          :kernel                 => 'FreeBSD',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :is_pe                  => false,
        }
      end
      let :params do default_params end
      let :facts do default_facts end
      it { is_expected.to contain_class("apache") }
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_concat("25-rspec.example.com.conf").with(
        :ensure => 'present',
        :path   => '/usr/local/etc/apache24/Vhosts/25-rspec.example.com.conf'
      ) }
    end
    context "on Gentoo systems" do
      let :default_facts do
        {
          :osfamily               => 'Gentoo',
          :operatingsystem        => 'Gentoo',
          :operatingsystemrelease => '3.16.1-gentoo',
          :concat_basedir         => '/dne',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin',
          :is_pe                  => false,
        }
      end
      let :params do default_params end
      let :facts do default_facts end
      it { is_expected.to contain_class("apache") }
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_concat("25-rspec.example.com.conf").with(
        :ensure => 'present',
        :path   => '/etc/apache2/vhosts.d/25-rspec.example.com.conf'
      ) }
    end
  end
  describe 'os-independent items' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :lsbdistcodename        => 'squeeze',
        :operatingsystem        => 'Debian',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    describe 'basic assumptions' do
      let :params do default_params end
      it { is_expected.to contain_class("apache") }
      it { is_expected.to contain_class("apache::params") }
      it { is_expected.to contain_apache__listen(params[:port]) }
      it { is_expected.to contain_apache__namevirtualhost("*:#{params[:port]}") }
    end
    context 'set everything!' do
      let :params do
        {
          'docroot'                     => '/var/www/foo',
          'manage_docroot'              => false,
          'virtual_docroot'             => true,
          'port'                        => '8080',
          'ip'                          => '127.0.0.1',
          'ip_based'                    => true,
          'add_listen'                  => false,
          'docroot_owner'               => 'user',
          'docroot_group'               => 'wheel',
          'docroot_mode'                => '0664',
          'serveradmin'                 => 'foo@localhost',
          'ssl'                         => true,
          'ssl_cert'                    => '/ssl/cert',
          'ssl_key'                     => '/ssl/key',
          'ssl_chain'                   => '/ssl/chain',
          'ssl_crl_path'                => '/ssl/crl',
          'ssl_crl'                     => 'foo.crl',
          'ssl_certs_dir'               => '/ssl/certs',
          'ssl_protocol'                => 'SSLv2',
          'ssl_cipher'                  => 'HIGH',
          'ssl_honorcipherorder'        => 'Off',
          'ssl_verify_client'           => 'optional',
          'ssl_verify_depth'            => '3',
          'ssl_options'                 => '+ExportCertData',
          'ssl_openssl_conf_cmd'        => 'DHParameters "foo.pem"',
          'ssl_proxy_verify'            => 'require',
          'ssl_proxy_check_peer_cn'     => 'on',
          'ssl_proxy_check_peer_name'   => 'on',
          'ssl_proxy_check_peer_expire' => 'on',
          'ssl_proxyengine'             => true,
          'ssl_proxy_protocol'          => 'TLSv1.2',

          'priority'                    => '30',
          'default_vhost'               => true,
          'servername'                  => 'example.com',
          'serveraliases'               => ['test-example.com'],
          'options'                     => ['MultiView'],
          'override'                    => ['All'],
          'directoryindex'              => 'index.html',
          'vhost_name'                  => 'test',
          'logroot'                     => '/var/www/logs',
          'logroot_ensure'              => 'directory',
          'logroot_mode'                => '0600',
          'logroot_owner'               => 'root',
          'logroot_group'               => 'root',
          'log_level'                   => 'crit',
          'access_log'                  => false,
          'access_log_file'             => 'httpd_access_log',
          'access_log_syslog'           => true,
          'access_log_format'           => '%h %l %u %t \"%r\" %>s %b',
          'access_log_env_var'          => '',
          'aliases'                     => '/image',
          'directories'                 => [
            {
              'path'     => '/var/www/files',
              'provider' => 'files',
              'require'  => [ 'valid-user', 'all denied', ],
            },
            {
                'path'     => '/var/www/files',
                'provider' => 'files',
                'additional_includes'  => [ '/custom/path/includes', '/custom/path/another_includes', ],
            },
            {
              'path'     => '/var/www/files',
              'provider' => 'files',
              'require'  => 'all granted',
            },
            {
              'path'     => '/var/www/files',
              'provider' => 'files',
              'require'  =>
              {
                'enforce'  => 'all',
                'requires' => ['all-valid1', 'all-valid2'],
              },
            },
            {
              'path'     => '/var/www/files',
              'provider' => 'files',
              'require'  =>
              {
                'enforce'  => 'none',
                'requires' => ['none-valid1', 'none-valid2'],
              },
            },
            {
              'path'     => '/var/www/files',
              'provider' => 'files',
              'require'  =>
              {
                'enforce'  => 'any',
                'requires' => ['any-valid1', 'any-valid2'],
              },
            },
            {
              'path'     => '*',
              'provider' => 'proxy',
            },
            { 'path'              => '/var/www/files/indexed_directory',
              'directoryindex'    => 'disabled',
              'options'           => ['Indexes','FollowSymLinks','MultiViews'],
              'index_options'     => ['FancyIndexing'],
              'index_style_sheet' => '/styles/style.css',
            },
            { 'path'              => '/var/www/files/output_filtered',
              'set_output_filter' => 'output_filter',
            },
            { 'path'     => '/var/www/files',
              'provider' => 'location',
              'limit'    => [
                { 'methods' => 'GET HEAD',
                  'require' => ['valid-user']
                },
              ],
            },
            { 'path'               => '/var/www/dav',
              'dav'                => 'filesystem',
              'dav_depth_infinity' => true,
              'dav_min_timeout'    => '600',
            },
          ],
          'error_log'                   => false,
          'error_log_file'              => 'httpd_error_log',
          'error_log_syslog'            => true,
          'error_documents'             => 'true',
          'fallbackresource'            => '/index.php',
          'scriptalias'                 => '/usr/lib/cgi-bin',
          'scriptaliases'               => [
            {
              'alias' => '/myscript',
              'path'  => '/usr/share/myscript',
            },
            {
              'aliasmatch' => '^/foo(.*)',
              'path'       => '/usr/share/fooscripts$1',
            },
          ],
          'proxy_dest'                  => '/',
          'proxy_pass'                  => [
            {
              'path'            => '/a',
              'url'             => 'http://backend-a/',
              'keywords'        => ['noquery', 'interpolate'],
              'no_proxy_uris'       => ['/a/foo', '/a/bar'],
              'no_proxy_uris_match' => ['/a/foomatch'],
              'reverse_cookies' => [
								{
                  'path'          => '/a',
                  'url'           => 'http://backend-a/',
                },
                {
                  'domain' => 'foo',
                  'url'    => 'http://foo',
                }
              ],
              'params'          => {
                      'retry'   => '0',
                      'timeout' => '5'
              },
              'setenv'   => ['proxy-nokeepalive 1','force-proxy-request-1.0 1'],
            }
          ],
          'proxy_pass_match'            => [
            {
              'path'     => '/a',
              'url'      => 'http://backend-a/',
              'keywords' => ['noquery', 'interpolate'],
              'no_proxy_uris'       => ['/a/foo', '/a/bar'],
              'no_proxy_uris_match' => ['/a/foomatch'],
              'params'   => {
                      'retry'   => '0',
                      'timeout' => '5'
              },
              'setenv'   => ['proxy-nokeepalive 1','force-proxy-request-1.0 1'],
            }
          ],
          'suphp_addhandler'            => 'foo',
          'suphp_engine'                => 'on',
          'suphp_configpath'            => '/var/www/html',
          'php_admin_flags'             => ['foo', 'bar'],
          'php_admin_values'            => ['true', 'false'],
          'no_proxy_uris'               => '/foo',
          'no_proxy_uris_match'         => '/foomatch',
          'proxy_preserve_host'         => true,
          'proxy_add_headers'           => true,
          'proxy_error_override'        => true,
          'redirect_source'             => '/bar',
          'redirect_dest'               => '/',
          'redirect_status'             => 'temp',
          'redirectmatch_status'        => ['404'],
          'redirectmatch_regexp'        => ['\.git$'],
          'redirectmatch_dest'          => ['http://www.example.com'],
          'rack_base_uris'              => ['/rackapp1'],
          'passenger_base_uris'         => ['/passengerapp1'],
          'headers'                     => 'Set X-Robots-Tag "noindex, noarchive, nosnippet"',
          'request_headers'             => ['append MirrorID "mirror 12"'],
          'rewrites'                    => [
            {
              'rewrite_rule' => ['^index\.html$ welcome.html']
            }
          ],
          'filters'                     => [
            'FilterDeclare COMPRESS',
            'FilterProvider COMPRESS  DEFLATE resp=Content-Type $text/html',
            'FilterProvider COMPRESS  DEFLATE resp=Content-Type $text/css',
            'FilterProvider COMPRESS  DEFLATE resp=Content-Type $text/plain',
            'FilterProvider COMPRESS  DEFLATE resp=Content-Type $text/xml',
            'FilterChain COMPRESS',
            'FilterProtocol COMPRESS  DEFLATE change=yes;byteranges=no',
          ],
          'rewrite_base'                => '/',
          'rewrite_rule'                => '^index\.html$ welcome.html',
          'rewrite_cond'                => '%{HTTP_USER_AGENT} ^MSIE',
          'rewrite_inherit'             => true,
          'setenv'                      => ['FOO=/bin/true'],
          'setenvif'                    => 'Request_URI "\.gif$" object_is_image=gif',
          'setenvifnocase'              => 'REMOTE_ADDR ^127.0.0.1 localhost=true',
          'block'                       => 'scm',
          'wsgi_application_group'      => '%{GLOBAL}',
          'wsgi_daemon_process'         => 'wsgi',
          'wsgi_daemon_process_options' => {
            'processes'    => '2',
            'threads'      => '15',
            'display-name' => '%{GROUP}',
          },
          'wsgi_import_script'          => '/var/www/demo.wsgi',
          'wsgi_import_script_options'  => {
            'process-group'     => 'wsgi',
            'application-group' => '%{GLOBAL}'
          },
          'wsgi_process_group'          => 'wsgi',
          'wsgi_script_aliases'         => {
            '/' => '/var/www/demo.wsgi'
          },
          'wsgi_script_aliases_match'   => {
            '^/test/(^[/*)' => '/var/www/demo.wsgi'
          },
          'wsgi_pass_authorization'     => 'On',
          'custom_fragment'             => '#custom string',
          'itk'                         => {
            'user'  => 'someuser',
            'group' => 'somegroup'
          },
          'wsgi_chunked_request'        => 'On',
          'action'                      => 'foo',
          'fastcgi_server'              => 'localhost',
          'fastcgi_socket'              => '/tmp/fastcgi.socket',
          'fastcgi_dir'                 => '/tmp',
          'fastcgi_idle_timeout'        => '120',
          'additional_includes'         => '/custom/path/includes',
          'apache_version'              => '2.4',
          'use_optional_includes'       => true,
          'suexec_user_group'           => 'root root',
          'allow_encoded_slashes'       => 'nodecode',
          'passenger_app_root'          => '/usr/share/myapp',
          'passenger_app_env'           => 'test',
          'passenger_ruby'              => '/usr/bin/ruby1.9.1',
          'passenger_min_instances'     => '1',
          'passenger_start_timeout'     => '600',
          'passenger_pre_start'         => 'http://localhost/myapp',
          'passenger_high_performance'  => true,
          'passenger_user'              => 'sandbox',
          'passenger_nodejs'            => '/usr/bin/node',
          'passenger_sticky_sessions'   => true,
          'passenger_startup_file'      => 'bin/www',
          'add_default_charset'         => 'UTF-8',
          'jk_mounts'                   => [
            { 'mount'   => '/*',     'worker' => 'tcnode1', },
            { 'unmount' => '/*.jpg', 'worker' => 'tcnode1', },
          ],
          'auth_kerb'                   => true,
          'krb_method_negotiate'        => 'off',
          'krb_method_k5passwd'         => 'off',
          'krb_authoritative'           => 'off',
          'krb_auth_realms'             => ['EXAMPLE.ORG','EXAMPLE.NET'],
          'krb_5keytab'                 => '/tmp/keytab5',
          'krb_local_user_mapping'      => 'off',
          'keepalive'                   => 'on',
          'keepalive_timeout'           => '100',
          'max_keepalive_requests'      => '1000',
        }
      end
      let :facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '7',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'RedHat',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :kernelversion          => '3.6.2',
          :is_pe                  => false,
        }
      end

      it { is_expected.to compile }
      it { is_expected.to_not contain_file('/var/www/foo') }
      it { is_expected.to contain_class('apache::mod::ssl') }
      it { is_expected.to contain_file('ssl.conf').with(
        :content => /^\s+SSLHonorCipherOrder On$/ ) }
      it { is_expected.to contain_file('ssl.conf').with(
        :content => /^\s+SSLPassPhraseDialog builtin$/ ) }
      it { is_expected.to contain_file('ssl.conf').with(
        :content => /^\s+SSLSessionCacheTimeout 300$/ ) }
      it { is_expected.to contain_class('apache::mod::mime') }
      it { is_expected.to contain_class('apache::mod::vhost_alias') }
      it { is_expected.to contain_class('apache::mod::wsgi') }
      it { is_expected.to contain_class('apache::mod::suexec') }
      it { is_expected.to contain_class('apache::mod::passenger') }
      it { is_expected.to contain_file('/var/www/logs').with({
        'ensure' => 'directory',
        'mode'   => '0600',
      })
      }
      it { is_expected.to contain_class('apache::mod::rewrite') }
      it { is_expected.to contain_class('apache::mod::alias') }
      it { is_expected.to contain_class('apache::mod::proxy') }
      it { is_expected.to contain_class('apache::mod::proxy_http') }
      it { is_expected.to contain_class('apache::mod::passenger') }
      it { is_expected.to contain_class('apache::mod::passenger') }
      it { is_expected.to contain_class('apache::mod::fastcgi') }
      it { is_expected.to contain_class('apache::mod::headers') }
      it { is_expected.to contain_class('apache::mod::filter') }
      it { is_expected.to contain_class('apache::mod::env') }
      it { is_expected.to contain_class('apache::mod::setenvif') }
      it { is_expected.to contain_concat('30-rspec.example.com.conf').with({
        'owner'   => 'root',
        'mode'    => '0644',
        'require' => 'Package[httpd]',
        'notify'  => 'Class[Apache::Service]',
      })
      }
      it { is_expected.to contain_file('30-rspec.example.com.conf symlink').with({
        'ensure' => 'link',
        'path'   => '/etc/apache2/sites-enabled/30-rspec.example.com.conf',
      })
      }
      it { is_expected.to contain_concat__fragment('rspec.example.com-apache-header') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-docroot') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-aliases') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-itk') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-fallbackresource') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+<Proxy "\*">$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Include\s'\/custom\/path\/includes'$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
          :content => /^\s+Include\s'\/custom\/path\/another_includes'$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require valid-user$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require all denied$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require all granted$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+<RequireAll>$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+<\/RequireAll>$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require all-valid1$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require all-valid2$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+<RequireNone>$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+<\/RequireNone>$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require none-valid1$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require none-valid2$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+<RequireAny>$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+<\/RequireAny>$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require any-valid1$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require any-valid2$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Options\sIndexes\sFollowSymLinks\sMultiViews$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+IndexOptions\sFancyIndexing$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+IndexStyleSheet\s'\/styles\/style\.css'$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+DirectoryIndex\sdisabled$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+SetOutputFilter\soutput_filter$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+<Limit GET HEAD>$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /\s+<Limit GET HEAD>\s*Require valid-user\s*<\/Limit>/m ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Dav\sfilesystem$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+DavDepthInfinity\sOn$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+DavMinTimeout\s600$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-additional_includes') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-logging') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-serversignature') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-access_log') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-action') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-block') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-error_document') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /retry=0/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /timeout=5/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /SetEnv force-proxy-request-1.0 1/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /SetEnv proxy-nokeepalive 1/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /noquery interpolate/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /ProxyPreserveHost On/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /ProxyAddHeaders On/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /ProxyPassReverseCookiePath\s+\/a\s+http:\/\//) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /ProxyPassReverseCookieDomain\s+foo\s+http:\/\/foo/) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-rack') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-redirect') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-rewrite') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-rewrite').with(
        :content => /^\s+RewriteOptions Inherit$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-scriptalias') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-serveralias') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-setenv').with_content(
              %r{SetEnv FOO=/bin/true}) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-setenv').with_content(
              %r{SetEnvIf Request_URI "\\.gif\$" object_is_image=gif}) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-setenv').with_content(
              %r{SetEnvIfNoCase REMOTE_ADDR \^127.0.0.1 localhost=true}) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-ssl') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-ssl').with(
        :content => /^\s+SSLOpenSSLConfCmd\s+DHParameters "foo.pem"$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-sslproxy') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-sslproxy').with(
        :content => /^\s+SSLProxyEngine On$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-sslproxy').with(
        :content => /^\s+SSLProxyCheckPeerCN\s+on$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-sslproxy').with(
        :content => /^\s+SSLProxyCheckPeerName\s+on$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-sslproxy').with(
        :content => /^\s+SSLProxyCheckPeerExpire\s+on$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-sslproxy').with(
        :content => /^\s+SSLProxyProtocol\s+TLSv1.2$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-suphp') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-php_admin') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-header') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-filters').with(
        :content => /^\s+FilterDeclare COMPRESS$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-requestheader') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-wsgi') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-custom_fragment') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-fastcgi') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-suexec') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-allow_encoded_slashes') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-passenger') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-charsets') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-security') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-file_footer') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-jk_mounts').with(
        :content => /^\s+JkMount\s+\/\*\s+tcnode1$/)}
      it { is_expected.to contain_concat__fragment('rspec.example.com-jk_mounts').with(
        :content => /^\s+JkUnMount\s+\/\*\.jpg\s+tcnode1$/)}
      it { is_expected.to contain_concat__fragment('rspec.example.com-auth_kerb').with(
        :content => /^\s+KrbMethodNegotiate\soff$/)}
      it { is_expected.to contain_concat__fragment('rspec.example.com-auth_kerb').with(
        :content => /^\s+KrbAuthoritative\soff$/)}
      it { is_expected.to contain_concat__fragment('rspec.example.com-auth_kerb').with(
        :content => /^\s+KrbAuthRealms\sEXAMPLE.ORG\sEXAMPLE.NET$/)}
      it { is_expected.to contain_concat__fragment('rspec.example.com-auth_kerb').with(
        :content => /^\s+Krb5Keytab\s\/tmp\/keytab5$/)}
      it { is_expected.to contain_concat__fragment('rspec.example.com-auth_kerb').with(
        :content => /^\s+KrbLocalUserMapping\soff$/)}
      it { is_expected.to contain_concat__fragment('rspec.example.com-auth_kerb').with(
        :content => /^\s+KrbServiceName\sHTTP$/)}
      it { is_expected.to contain_concat__fragment('rspec.example.com-auth_kerb').with(
        :content => /^\s+KrbSaveCredentials\soff$/)}
      it { is_expected.to contain_concat__fragment('rspec.example.com-auth_kerb').with(
        :content => /^\s+KrbVerifyKDC\son$/)}
      it { is_expected.to contain_concat__fragment('rspec.example.com-keepalive_options').with(
        :content => /^\s+KeepAlive\son$/)}
      it { is_expected.to contain_concat__fragment('rspec.example.com-keepalive_options').with(
        :content => /^\s+KeepAliveTimeout\s100$/)}
      it { is_expected.to contain_concat__fragment('rspec.example.com-keepalive_options').with(
        :content => /^\s+MaxKeepAliveRequests\s1000$/)}
    end
    context 'vhost with multiple ip addresses' do
      let :params do
        {
          'port'                        => '80',
          'ip'                          => ['127.0.0.1','::1'],
          'ip_based'                    => true,
          'servername'                  => 'example.com',
          'docroot'                     => '/var/www/html',
          'add_listen'                  => true,
          'ensure'                      => 'present'
        }
      end
      let :facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '7',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'RedHat',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :kernelversion          => '3.6.2',
          :is_pe                  => false,
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('rspec.example.com-apache-header').with(
        :content => /[.\/m]*<VirtualHost 127.0.0.1:80 \[::1\]:80>[.\/m]*$/ ) }
      it { is_expected.to contain_concat__fragment('Listen 127.0.0.1:80') }
      it { is_expected.to contain_concat__fragment('Listen [::1]:80') }
      it { is_expected.to_not contain_concat__fragment('NameVirtualHost 127.0.0.1:80') }
      it { is_expected.to_not contain_concat__fragment('NameVirtualHost [::1]:80') }
    end

    context 'vhost with ipv6 address' do
      let :params do
        {
          'port'                        => '80',
          'ip'                          => '::1',
          'ip_based'                    => true,
          'servername'                  => 'example.com',
          'docroot'                     => '/var/www/html',
          'add_listen'                  => true,
          'ensure'                      => 'present'
        }
      end
      let :facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '7',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'RedHat',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :kernelversion          => '3.6.2',
          :is_pe                  => false,
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('rspec.example.com-apache-header').with(
        :content => /[.\/m]*<VirtualHost \[::1\]:80>[.\/m]*$/ ) }
      it { is_expected.to contain_concat__fragment('Listen [::1]:80') }
      it { is_expected.to_not contain_concat__fragment('NameVirtualHost [::1]:80') }
    end

    context 'vhost with wildcard ip address' do
      let :params do
        {
          'port'                        => '80',
          'ip'                          => '*',
          'ip_based'                    => true,
          'servername'                  => 'example.com',
          'docroot'                     => '/var/www/html',
          'add_listen'                  => true,
          'ensure'                      => 'present'
        }
      end
      let :facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '7',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'RedHat',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :kernelversion          => '3.6.2',
          :is_pe                  => false,
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('rspec.example.com-apache-header').with(
        :content => /[.\/m]*<VirtualHost \*:80>[.\/m]*$/ ) }
      it { is_expected.to contain_concat__fragment('Listen *:80') }
      it { is_expected.to_not contain_concat__fragment('NameVirtualHost *:80') }
    end

    context 'modsec_audit_log' do
      let :params do
        {
          'docroot'          => '/rspec/docroot',
          'modsec_audit_log' => true,
        }
      end
      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('rspec.example.com-security').with(
        :content => /^\s*SecAuditLog "\/var\/log\/apache2\/rspec\.example\.com_security\.log"$/ ) }
    end
    context 'modsec_audit_log_file' do
      let :params do
        {
          'docroot'               => '/rspec/docroot',
          'modsec_audit_log_file' => 'foo.log',
        }
      end
      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('rspec.example.com-security').with(
        :content => /\s*SecAuditLog "\/var\/log\/apache2\/foo.log"$/ ) }
    end
    context 'set only aliases' do
      let :params do
        {
          'docroot' => '/rspec/docroot',
          'aliases' => [
            {
              'alias' => '/alias',
              'path'  => '/rspec/docroot',
            },
          ]
        }
      end
      it { is_expected.to contain_class('apache::mod::alias')}
    end
    context 'proxy_pass_match' do
      let :params do
        {
          'docroot'          => '/rspec/docroot',
          'proxy_pass_match'            => [
            {
              'path'     => '.*',
              'url'      => 'http://backend-a/',
              'params'   => { 'timeout' => 300 },
            }
          ],
        }
      end
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(
              /ProxyPassMatch .* http:\/\/backend-a\/ timeout=300/).with_content(/## Proxy rules/) }
    end
    context 'proxy_dest_match' do
      let :params do
        {
          'docroot'          => '/rspec/docroot',
          'proxy_dest_match' => '/'
        }
      end
      it { is_expected.to contain_concat__fragment('rspec.example.com-proxy').with_content(/## Proxy rules/) }
    end
    context 'not everything can be set together...' do
      let :params do
        {
          'access_log_pipe' => '/dev/null',
          'error_log_pipe'  => '/dev/null',
          'docroot'         => '/var/www/foo',
          'ensure'          => 'absent',
          'manage_docroot'  => true,
          'logroot'         => '/tmp/logroot',
          'logroot_ensure'  => 'absent',
          'directories'     => [
            {
              'path'     => '/var/www/files',
              'provider' => 'files',
              'allow'    => [ 'from 127.0.0.1', 'from 127.0.0.2', ],
              'deny'     => [ 'from 127.0.0.3', 'from 127.0.0.4', ],
              'satisfy'  => 'any',
            },
            {
              'path'     => '/var/www/foo',
              'provider' => 'files',
              'allow'    => 'from 127.0.0.5',
              'deny'     => 'from all',
              'order'    => 'deny,allow',
            },
          ],

        }
      end
      let :facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '6',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'RedHat',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :kernelversion          => '3.6.2',
          :is_pe                  => false,
        }
      end

      it { is_expected.to compile }
      it { is_expected.to_not contain_class('apache::mod::ssl') }
      it { is_expected.to_not contain_class('apache::mod::mime') }
      it { is_expected.to_not contain_class('apache::mod::vhost_alias') }
      it { is_expected.to_not contain_class('apache::mod::wsgi') }
      it { is_expected.to_not contain_class('apache::mod::passenger') }
      it { is_expected.to_not contain_class('apache::mod::suexec') }
      it { is_expected.to_not contain_class('apache::mod::rewrite') }
      it { is_expected.to_not contain_class('apache::mod::alias') }
      it { is_expected.to_not contain_class('apache::mod::proxy') }
      it { is_expected.to_not contain_class('apache::mod::proxy_http') }
      it { is_expected.to_not contain_class('apache::mod::passenger') }
      it { is_expected.to_not contain_class('apache::mod::headers') }
      it { is_expected.to contain_file('/var/www/foo') }
      it { is_expected.to contain_file('/tmp/logroot').with({
        'ensure' => 'absent',
      })
      }
      it { is_expected.to contain_concat('25-rspec.example.com.conf').with({
        'ensure' => 'absent',
      })
      }
      it { is_expected.to contain_concat__fragment('rspec.example.com-apache-header') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-docroot') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-aliases') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-itk') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-fallbackresource') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Allow from 127\.0\.0\.1$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Allow from 127\.0\.0\.2$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Allow from 127\.0\.0\.5$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Deny from 127\.0\.0\.3$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Deny from 127\.0\.0\.4$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Deny from all$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Satisfy any$/ ) }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Order deny,allow$/ ) }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-additional_includes') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-logging') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-serversignature') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-access_log') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-action') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-block') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-error_document') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-proxy') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-rack') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-redirect') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-rewrite') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-scriptalias') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-serveralias') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-setenv') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-ssl') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-sslproxy') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-suphp') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-php_admin') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-header') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-requestheader') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-wsgi') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-custom_fragment') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-fastcgi') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-suexec') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-charsets') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-limits') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-file_footer') }
    end
    context 'when not setting nor managing the docroot' do
      let :params do
        {
          'docroot'                     => false,
          'manage_docroot'              => false,
        }
      end
      it { is_expected.to compile }
      it { is_expected.not_to contain_concat__fragment('rspec.example.com-docroot') }
    end
    context 'ssl_proxyengine without ssl' do
      let :params do
        {
          'docroot'         => '/rspec/docroot',
          'ssl'             => false,
          'ssl_proxyengine' => true,
        }
      end
      it { is_expected.to compile }
      it { is_expected.not_to contain_concat__fragment('rspec.example.com-ssl') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-sslproxy') }
    end
    context 'ssl_proxy_protocol without ssl_proxyengine' do
      let :params do
        {
          'docroot'            => '/rspec/docroot',
          'ssl'                => true,
          'ssl_proxyengine'    => false,
          'ssl_proxy_protocol' => 'TLSv1.2',
        }
      end
      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('rspec.example.com-ssl') }
      it { is_expected.not_to contain_concat__fragment('rspec.example.com-sslproxy') }
    end
  end
  describe 'access logs' do
    let :facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'RedHat',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    context 'single log file' do
      let(:params) do
        {
          'docroot'         => '/rspec/docroot',
          'access_log_file' => 'my_log_file',
        }
      end
      it { is_expected.to contain_concat__fragment('rspec.example.com-access_log').with(
        :content => /^\s+CustomLog.*my_log_file" combined\s*$/
      )}
    end
    context 'single log file with environment' do
      let(:params) do
        {
          'docroot'            => '/rspec/docroot',
          'access_log_file'    => 'my_log_file',
          'access_log_env_var' => 'prod'
        }
      end
      it { is_expected.to contain_concat__fragment('rspec.example.com-access_log').with(
        :content => /^\s+CustomLog.*my_log_file" combined\s+env=prod$/
      )}
    end
    context 'multiple log files' do
      let(:params) do
        {
          'docroot'     => '/rspec/docroot',
          'access_logs' => [
            { 'file' => '/tmp/log1', 'env' => 'dev' },
            { 'file' => 'log2' },
            { 'syslog' => 'syslog', 'format' => '%h %l' }
          ],
        }
      end
      it { is_expected.to contain_concat__fragment('rspec.example.com-access_log').with(
        :content => /^\s+CustomLog "\/tmp\/log1"\s+combined\s+env=dev$/
      )}
      it { is_expected.to contain_concat__fragment('rspec.example.com-access_log').with(
        :content => /^\s+CustomLog "\/var\/log\/httpd\/log2"\s+combined\s*$/
      )}
      it { is_expected.to contain_concat__fragment('rspec.example.com-access_log').with(
        :content => /^\s+CustomLog "syslog" "%h %l"\s*$/
      )}
    end
  end # access logs
  describe 'validation' do
    let :default_facts do
      {
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :operatingsystem        => 'RedHat',
        :id                     => 'root',
        :kernel                 => 'Linux',
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :is_pe                  => false,
      }
    end
    context 'bad ensure' do
      let :params do
        {
          'docroot' => '/rspec/docroot',
          'ensure'  => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad suphp_engine' do
      let :params do
        {
          'docroot'      => '/rspec/docroot',
          'suphp_engine' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad ip_based' do
      let :params do
        {
          'docroot'  => '/rspec/docroot',
          'ip_based' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad access_log' do
      let :params do
        {
          'docroot'    => '/rspec/docroot',
          'access_log' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad error_log' do
      let :params do
        {
          'docroot'   => '/rspec/docroot',
          'error_log' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad_ssl' do
      let :params do
        {
          'docroot' => '/rspec/docroot',
          'ssl'     => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad default_vhost' do
      let :params do
        {
          'docroot'       => '/rspec/docroot',
          'default_vhost' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad ssl_proxyengine' do
      let :params do
        {
          'docroot'         => '/rspec/docroot',
          'ssl_proxyengine' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad rewrites' do
      let :params do
        {
          'docroot'  => '/rspec/docroot',
          'rewrites' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad rewrites 2' do
      let :params do
        {
          'docroot'  => '/rspec/docroot',
          'rewrites' => ['bogus'],
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'empty rewrites' do
      let :params do
        {
          'docroot'  => '/rspec/docroot',
          'rewrites' => [],
        }
      end
      let :facts do default_facts end
      it { is_expected.to compile }
    end
    context 'bad suexec_user_group' do
      let :params do
        {
          'docroot'           => '/rspec/docroot',
          'suexec_user_group' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad wsgi_script_alias' do
      let :params do
        {
          'docroot'           => '/rspec/docroot',
          'wsgi_script_alias' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad wsgi_daemon_process_options' do
      let :params do
        {
          'docroot'                     => '/rspec/docroot',
          'wsgi_daemon_process_options' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad wsgi_import_script_alias' do
      let :params do
        {
          'docroot'                  => '/rspec/docroot',
          'wsgi_import_script_alias' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad itk' do
      let :params do
        {
          'docroot' => '/rspec/docroot',
          'itk'     => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad logroot_ensure' do
      let :params do
        {
          'docroot'   => '/rspec/docroot',
          'log_level' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad log_level' do
      let :params do
        {
          'docroot'   => '/rspec/docroot',
          'log_level' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'access_log_file and access_log_pipe' do
      let :params do
        {
          'docroot'         => '/rspec/docroot',
          'access_log_file' => 'bogus',
          'access_log_pipe' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'error_log_file and error_log_pipe' do
      let :params do
        {
          'docroot'        => '/rspec/docroot',
          'error_log_file' => 'bogus',
          'error_log_pipe' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad fallbackresource' do
      let :params do
        {
          'docroot'          => '/rspec/docroot',
          'fallbackresource' => 'bogus',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad custom_fragment' do
      let :params do
        {
          'docroot'         => '/rspec/docroot',
          'custom_fragment' => true,
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'bad access_logs' do
      let :params do
        {
          'docroot'     => '/rspec/docroot',
          'access_logs' => '/var/log/somewhere',
        }
      end
      let :facts do default_facts end
      it { expect { is_expected.to compile }.to raise_error }
    end
    context 'default of require all granted' do
      let :params do
        {
          'docroot'         => '/var/www/foo',
          'directories'     => [
            {
              'path'     => '/var/www/foo/files',
              'provider' => 'files',
            },
          ],

        }
      end
      let :facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '7',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'RedHat',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :kernelversion          => '3.19.2',
          :is_pe                  => false,
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat('25-rspec.example.com.conf') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require all granted$/ ) }
    end
    context 'require unmanaged' do
      let :params do
        {
          'docroot'         => '/var/www/foo',
          'directories'     => [
            {
              'path'     => '/var/www/foo',
              'require'  => 'unmanaged',
            },
          ],

        }
      end
      let :facts do
        {
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '7',
          :concat_basedir         => '/dne',
          :operatingsystem        => 'RedHat',
          :id                     => 'root',
          :kernel                 => 'Linux',
          :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :kernelversion          => '3.19.2',
          :is_pe                  => false,
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat('25-rspec.example.com.conf') }
      it { is_expected.to contain_concat__fragment('rspec.example.com-directories') }
      it { is_expected.to_not contain_concat__fragment('rspec.example.com-directories').with(
        :content => /^\s+Require all granted$/ )
      }
    end
  end
end
