require 'spec_helper'

describe 'nginx::resource::vhost' do
  let :title do
    'www.rspec.example.com'
  end
  let :default_params do
    {
      :www_root    => '/',
      :ipv6_enable => true,
      :listen_unix_socket_enable => true,
    }
  end
  let :facts do
    {
      :ipaddress6      => '::',
    }
  end
  let :pre_condition do
    [
      'include ::nginx::config',
    ]
  end

  describe 'os-independent items' do

    describe 'basic assumptions' do
      let :params do default_params end
      it { is_expected.to contain_class("nginx::config") }
      it { is_expected.to contain_concat("/etc/nginx/sites-available/#{title}.conf").with({
        'owner' => 'root',
        'group' => 'root',
        'mode'  => '0644',
      })}
      it { is_expected.to contain_concat__fragment("#{title}-header").with_content(%r{access_log\s+/var/log/nginx/www\.rspec\.example\.com\.access\.log combined;}) }
      it { is_expected.to contain_concat__fragment("#{title}-header").with_content(%r{error_log\s+/var/log/nginx/www\.rspec\.example\.com\.error\.log}) }
      it { is_expected.to contain_concat__fragment("#{title}-footer") }
      it { is_expected.to contain_nginx__resource__location("#{title}-default") }
      it { is_expected.not_to contain_file("/etc/nginx/fastcgi_params") }
      it { is_expected.to contain_file("#{title}.conf symlink").with({
        'ensure' => 'link',
        'path'   => "/etc/nginx/sites-enabled/#{title}.conf",
        'target' => "/etc/nginx/sites-available/#{title}.conf"
      })}
    end

    describe "vhost_header template content" do
      [
        {
          :title    => 'should not contain www to non-www rewrite',
          :attr     => 'rewrite_www_to_non_www',
          :value    => false,
          :notmatch => %r|
            ^
            \s+server_name\s+www\.rspec\.example\.com;\n
            \s+return\s+301\s+http://rspec\.example\.com\$request_uri;
          |x,
        },
        {
          :title => 'should contain www to non-www rewrite',
          :attr  => 'rewrite_www_to_non_www',
          :value => true,
          :match => %r|
            ^
            \s+server_name\s+www\.rspec\.example\.com;\n
            \s+return\s+301\s+http://rspec\.example\.com\$request_uri;
          |x,
        },
        {
          :title => 'should set the IPv4 listen IP',
          :attr  => 'listen_ip',
          :value => '127.0.0.1',
          :match => %r'\s+listen\s+127.0.0.1:80;',
        },
        {
          :title => 'should set the IPv4 listen port',
          :attr  => 'listen_port',
          :value => 45,
          :match => %r'\s+listen\s+\*:45;',
        },
        {
          :title => 'should set the IPv4 listen options',
          :attr  => 'listen_options',
          :value => 'spdy default',
          :match => %r'\s+listen\s+\*:80 spdy default;',
        },
        {
          :title => 'should enable IPv6',
          :attr  => 'ipv6_enable',
          :value => true,
          :match => %r'\s+listen\s+\[::\]:80 default ipv6only=on;',
        },
        {
          :title    => 'should not enable IPv6',
          :attr     => 'ipv6_enable',
          :value    => false,
          :notmatch => %r'\slisten \[::\]:80 default ipv6only=on;',
        },
        {
          :title => 'should set the IPv6 listen IP',
          :attr  => 'ipv6_listen_ip',
          :value => '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
          :match => %r'\s+listen\s+\[2001:0db8:85a3:0000:0000:8a2e:0370:7334\]:80 default ipv6only=on;',
        },
        {
          :title => 'should set the IPv6 listen port',
          :attr  => 'ipv6_listen_port',
          :value => 45,
          :match => %r'\s+listen\s+\[::\]:45 default ipv6only=on;',
        },
        {
          :title => 'should set the IPv6 listen options',
          :attr  => 'ipv6_listen_options',
          :value => 'spdy',
          :match => %r'\s+listen\s+\[::\]:80 spdy;',
        },
        {
          :title => 'should enable listening on unix socket',
          :attr  => 'listen_unix_socket_enable',
          :value => true,
          :match => %r'\s+listen\s+unix:/var/run/nginx\.sock;',
        },
        {
          :title    => 'should not enable listening on unix socket',
          :attr     => 'listen_unix_socket_enable',
          :value    => false,
          :notmatch => %r'\s+listen\s+unix:/var/run/nginx\.sock;',
        },
        {
          :title => 'should set the listen unix socket',
          :attr  => 'listen_unix_socket',
          :value => '/var/run/puppet_nginx.sock',
          :match => %r'\s+listen\s+unix:/var/run/puppet_nginx\.sock;',
        },
        {
          :title => 'should set the listen unix socket options',
          :attr  => 'listen_unix_socket_options',
          :value => 'spdy',
          :match => %r'\s+listen\s+unix:/var/run/nginx\.sock spdy;',
        },
        {
          :title => 'should set servername(s)',
          :attr  => 'server_name',
          :value => ['www.foo.com','foo.com'],
          :match => %r'\s+server_name\s+www.foo.com foo.com;',
        },
        {
          :title => 'should rewrite www servername to non-www',
          :attr  => 'rewrite_www_to_non_www',
          :value => true,
          :match => %r'\s+server_name\s+rspec.example.com;',
        },
        {
          :title => 'should not rewrite www servername to non-www',
          :attr  => 'rewrite_www_to_non_www',
          :value => false,
          :match => %r'\s+server_name\s+www.rspec.example.com;',
        },
        {
          :title => 'should set auth_basic',
          :attr  => 'auth_basic',
          :value => 'value',
          :match => %r'\s+auth_basic\s+"value";',
        },
        {
          :title => 'should set auth_basic_user_file',
          :attr  => 'auth_basic_user_file',
          :value => 'value',
          :match => %r'\s+auth_basic_user_file\s+value;',
        },
        {
          :title => 'should set the client_body_timeout',
          :attr  => 'client_body_timeout',
          :value => 'value',
          :match => /^\s+client_body_timeout\s+value;/
        },
        {
          :title => 'should set the client_header_timeout',
          :attr  => 'client_header_timeout',
          :value => 'value',
          :match => /^\s+client_header_timeout\s+value;/
        },
        {
          :title => 'should set the gzip_types',
          :attr  => 'gzip_types',
          :value => 'value',
          :match => /^\s+gzip_types\s+value;/
        },
        {
          :title => 'should contain raw_prepend directives',
          :attr  => 'raw_prepend',
          :value => [
            'if (a) {',
            '  b;',
            '}'
          ],
          :match => /^\s+if \(a\) {\n\s++b;\n\s+\}/,
        },
        {
          :title => 'should contain ordered prepended directives',
          :attr  => 'vhost_cfg_prepend',
          :value => { 'test1' => ['test value 1a', 'test value 1b'], 'test2' => 'test value 2', 'allow' => 'test value 3' },
          :match => [
            '  allow test value 3;',
            '  test1 test value 1a;',
            '  test1 test value 1b;',
            '  test2 test value 2;',
          ],
        },
        {
          :title => 'should set root',
          :attr  => 'use_default_location',
          :value => false,
          :match => '  root /;',
        },
        {
          :title    => 'should not set root',
          :attr     => 'use_default_location',
          :value    => true,
          :notmatch => /  root \/;/,
        },
        {
          :title => 'should rewrite to HTTPS',
          :attr  => 'rewrite_to_https',
          :value => true,
          :match => [
            '  if ($ssl_protocol = "") {',
            '       return 301 https://$host$request_uri;',
          ],
        },
        {
          :title    => 'should not rewrite to HTTPS',
          :attr     => 'rewrite_to_https',
          :value    => false,
          :notmatch => [
            %r'if \(\$ssl_protocol = ""\) \{',
            %r'\s+return 301 https://\$host\$request_uri;',
          ],
        },
        {
          :title => 'should set access_log',
          :attr  => 'access_log',
          :value => '/path/to/access.log',
          :match => '  access_log            /path/to/access.log combined;',
        },
        {
          :title => 'should set access_log off',
          :attr  => 'access_log',
          :value => 'off',
          :match => '  access_log            off;',
        },
        {
          :title => 'should set access_log to syslog',
          :attr  => 'access_log',
          :value => 'syslog:server=localhost',
          :match => '  access_log            syslog:server=localhost combined;',
        },
        {
          :title => 'should set format_log custom_format',
          :attr  => 'format_log',
          :value => 'custom',
          :match => '  access_log            /var/log/nginx/www.rspec.example.com.access.log custom;',
        },
        {
          :title => 'should set error_log',
          :attr  => 'error_log',
          :value => '/path/to/error.log',
          :match => '  error_log             /path/to/error.log;',
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { is_expected.to contain_concat__fragment("#{title}-header") }
          it param[:title] do
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| is_expected.to contain_concat__fragment("#{title}-header").with_content(item) }
            else
              lines = catalogue.resource('concat::fragment', "#{title}-header").send(:parameters)[:content].split("\n")
              expect(lines & Array(param[:match])).to eq(Array(param[:match]))
            end
            Array(param[:notmatch]).each do |item|
              is_expected.to contain_concat__fragment("#{title}-header").without_content(item)
            end
          end
        end
      end
    end

    describe "vhost_footer template content" do
      [
        {
          :title    => 'should not contain www to non-www rewrite',
          :attr     => 'rewrite_www_to_non_www',
          :value    => false,
          :notmatch => %r|
            ^
            \s+server_name\s+www\.rspec\.example\.com;\n
            \s+return\s+301\s+https://rspec\.example\.com\$request_uri;
          |x,
        },
        {
          :title => 'should contain include directives',
          :attr  => 'include_files',
          :value => [ '/file1', '/file2' ],
          :match => [
            %r'^\s+include\s+/file1;',
            %r'^\s+include\s+/file2;',
          ],
        },
        {
          :title => 'should contain ordered appended directives',
          :attr  => 'vhost_cfg_append',
          :value => { 'test1' => 'test value 1', 'test2' => ['test value 2a', 'test value 2b'], 'allow' => 'test value 3' },
          :match => [
            '  allow test value 3;',
            '  test1 test value 1;',
            '  test2 test value 2a;',
            '  test2 test value 2b;',
          ],
        },
        {
          :title => 'should contain raw_append directives',
          :attr  => 'raw_append',
          :value => [
            'if (a) {',
            '  b;',
            '}'
          ],
          :match => /^\s+if \(a\) {\n\s++b;\n\s+\}/,
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { is_expected.to contain_concat__fragment("#{title}-footer") }
          it param[:title] do
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| is_expected.to contain_concat__fragment("#{title}-footer").with_content(item) }
            else
              lines  = catalogue.resource('concat::fragment', "#{title}-footer").send(:parameters)[:content].split("\n")
              expect(lines & Array(param[:match])).to eq(Array(param[:match]))
            end
            Array(param[:notmatch]).each do |item|
              is_expected.to contain_concat__fragment("#{title}-footer").without_content(item)
            end
          end
        end
      end
    end

    describe "vhost_ssl_header template content" do
      [
        {
          :title    => 'should not contain www to non-www rewrite',
          :attr     => 'rewrite_www_to_non_www',
          :value    => false,
          :notmatch => %r|
            ^
            \s+server_name\s+www\.rspec\.example\.com;\n
            \s+return\s+301\s+https://rspec\.example\.com\$request_uri;
          |x,
        },
        {
          :title => 'should contain www to non-www rewrite',
          :attr  => 'rewrite_www_to_non_www',
          :value => true,
          :match => %r|
            ^
            \s+server_name\s+www\.rspec\.example\.com;\n
            \s+return\s+301\s+https://rspec\.example\.com\$request_uri;
          |x,
        },
        {
          :title => 'should set the IPv4 listen IP',
          :attr  => 'listen_ip',
          :value => '127.0.0.1',
          :match => %r'\s+listen\s+127.0.0.1:443 ssl;',
        },
        {
          :title => 'should set the IPv4 SSL listen port',
          :attr  => 'ssl_port',
          :value => 45,
          :match => %r'\s+listen\s+\*:45 ssl;',
        },
        {
          :title => 'should set SPDY',
          :attr  => 'spdy',
          :value => 'on',
          :match => %r'\s+listen\s+\*:443 ssl spdy;',
        },
        {
          :title => 'should not set SPDY',
          :attr  => 'spdy',
          :value => 'off',
          :match => %r'\s+listen\s+\*:443 ssl;',
        },
        {
          :title => 'should set HTTP2',
          :attr  => 'http2',
          :value => 'on',
          :match => %r'\s+listen\s+\*:443 ssl http2;',
        },
        {
          :title => 'should not set HTTP2',
          :attr  => 'http2',
          :value => 'off',
          :match => %r'\s+listen\s+\*:443 ssl;',
        },
        {
          :title => 'should set the IPv4 listen options',
          :attr  => 'listen_options',
          :value => 'default',
          :match => %r'\s+listen\s+\*:443 ssl default;',
        },
        {
          :title => 'should enable IPv6',
          :attr  => 'ipv6_enable',
          :value => true,
          :match => %r'\s+listen\s+\[::\]:443 ssl default ipv6only=on;',
        },
        {
          :title    => 'should disable IPv6',
          :attr     => 'ipv6_enable',
          :value    => false,
          :notmatch => /  listen \[::\]:443 ssl default ipv6only=on;/,
        },
        {
          :title => 'should set the IPv6 listen IP',
          :attr  => 'ipv6_listen_ip',
          :value => '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
          :match => %r'\s+listen\s+\[2001:0db8:85a3:0000:0000:8a2e:0370:7334\]:443 ssl default ipv6only=on;',
        },
        {
          :title => 'should set the IPv6 listen port',
          :attr  => 'ssl_port',
          :value => 45,
          :match => %r'\s+listen\s+\[::\]:45 ssl default ipv6only=on;',
        },
        {
          :title => 'should set the IPv6 listen options',
          :attr  => 'ipv6_listen_options',
          :value => 'spdy default',
          :match => %r'\s+listen\s+\[::\]:443 ssl spdy default;',
        },
        {
          :title => 'should set servername(s)',
          :attr  => 'server_name',
          :value => ['www.foo.com','foo.com'],
          :match => %r'\s+server_name\s+www.foo.com foo.com;',
        },
        {
          :title => 'should rewrite www servername to non-www',
          :attr  => 'rewrite_www_to_non_www',
          :value => true,
          :match => %r'\s+server_name\s+rspec.example.com;',
        },
        {
          :title => 'should not rewrite www servername to non-www',
          :attr  => 'rewrite_www_to_non_www',
          :value => false,
          :match => %r'\s+server_name\s+www.rspec.example.com;',
        },
        {
          :title => 'should set the SSL buffer size',
          :attr  => 'ssl_buffer_size',
          :value => '4k',
          :match => '  ssl_buffer_size           4k;',
        },
        {
          :title => 'should set the SSL client certificate file',
          :attr  => 'ssl_client_cert',
          :value => '/tmp/client_certificate',
          :match => %r'\s+ssl_client_certificate\s+/tmp/client_certificate;',
        },
        {
          :title => 'should set the SSL CRL file',
          :attr  => 'ssl_crl',
          :value => '/tmp/crl',
          :match => %r'\s+ssl_crl\s+/tmp/crl;',
        },
        {
          :title => 'should set the SSL DH parameters file',
          :attr  => 'ssl_dhparam',
          :value => '/tmp/dhparam',
          :match => %r'\s+ssl_dhparam\s+/tmp/dhparam;',
        },
        {
          :title => 'should set the SSL stapling file',
          :attr  => 'ssl_stapling_file',
          :value => '/tmp/stapling_file',
          :match => %r'\s+ssl_stapling_file\s+/tmp/stapling_file;',
        },
        {
          :title => 'should set the SSL trusted certificate file',
          :attr  => 'ssl_trusted_cert',
          :value => '/tmp/trusted_certificate',
          :match => %r'\s+ssl_trusted_certificate\s+/tmp/trusted_certificate;',
        },
        {
          :title => 'should set the SSL cache',
          :attr  => 'ssl_cache',
          :value => 'shared:SSL:1m',
          :match => %r'\s+ssl_session_cache\s+shared:SSL:1m;',
        },
        {
          :title => 'should set the SSL timeout',
          :attr  => 'ssl_session_timeout',
          :value => '30m',
          :match => '  ssl_session_timeout       30m;',
        },
        {
          :title => 'should set the SSL protocols',
          :attr  => 'ssl_protocols',
          :value => 'TLSv1',
          :match => %r'\s+ssl_protocols\s+TLSv1;',
        },
        {
          :title => 'should set the SSL ciphers',
          :attr  => 'ssl_ciphers',
          :value => 'HIGH',
          :match => %r'\s+ssl_ciphers\s+HIGH;',
        },
        {
          :title => 'should set auth_basic',
          :attr  => 'auth_basic',
          :value => 'value',
          :match => %r'\s+auth_basic\s+"value";',
        },
        {
          :title => 'should set auth_basic_user_file',
          :attr  => 'auth_basic_user_file',
          :value => 'value',
          :match => %r'\s+auth_basic_user_file\s+"value";',
        },
        {
          :title => 'should set the client_body_timeout',
          :attr  => 'client_body_timeout',
          :value => 'value',
          :match => /^\s+client_body_timeout\s+value;/
        },
        {
          :title => 'should set the client_header_timeout',
          :attr  => 'client_header_timeout',
          :value => 'value',
          :match => /^\s+client_header_timeout\s+value;/
        },
        {
          :title => 'should set the gzip_types',
          :attr  => 'gzip_types',
          :value => 'value',
          :match => /^\s+gzip_types\s+value;/
        },
        {
          :title => 'should set access_log',
          :attr  => 'access_log',
          :value => '/path/to/access.log',
          :match => '  access_log            /path/to/access.log combined;',
        },
        {
          :title => 'should set access_log off',
          :attr  => 'access_log',
          :value => 'off',
          :match => '  access_log            off;',
        },
        {
          :title => 'should set access_log to syslog',
          :attr  => 'access_log',
          :value => 'syslog:server=localhost',
          :match => '  access_log            syslog:server=localhost combined;',
        },
        {
          :title => 'should set format_log custom_format',
          :attr  => 'format_log',
          :value => 'custom',
          :match => '  access_log            /var/log/nginx/ssl-www.rspec.example.com.access.log custom;',
        },
        {
          :title => 'should set error_log',
          :attr  => 'error_log',
          :value => '/path/to/error.log',
          :match => '  error_log             /path/to/error.log;',
        },
        {
          :title => 'should contain raw_prepend directives',
          :attr  => 'raw_prepend',
          :value => [
            'if (a) {',
            '  b;',
            '}'
          ],
          :match => /^\s+if \(a\) {\n\s++b;\n\s+\}/,
        },
        {
          :title => 'should contain ordered prepend directives',
          :attr  => 'vhost_cfg_prepend',
          :value => { 'test1' => 'test value 1', 'test2' => ['test value 2a', 'test value 2b'], 'allow' => 'test value 3' },
          :match => [
            '  allow test value 3;',
            '  test1 test value 1;',
            '  test2 test value 2a;',
            '  test2 test value 2b;',
          ]
        },
        {
          :title => 'should contain ordered ssl prepend directives',
          :attr  => 'vhost_cfg_ssl_prepend',
          :value => { 'test1' => 'test value 1', 'test2' => ['test value 2a', 'test value 2b'], 'allow' => 'test value 3' },
          :match => [
            '  allow test value 3;',
            '  test1 test value 1;',
            '  test2 test value 2a;',
            '  test2 test value 2b;',
          ]
        },
        {
          :title => 'should set root',
          :attr  => 'use_default_location',
          :value => false,
          :match => '  root /;',
        },
        {
          :title    => 'should not set root',
          :attr     => 'use_default_location',
          :value    => true,
          :notmatch => /  root \/;/,
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :params do default_params.merge({
            param[:attr].to_sym => param[:value],
            :ssl                => true,
            :ssl_key            => 'dummy.key',
            :ssl_cert           => 'dummy.crt',
          }) end
          it { is_expected.to contain_concat__fragment("#{title}-ssl-header") }
          it param[:title] do
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content(item) }
            else
              lines = catalogue.resource('concat::fragment', "#{title}-ssl-header").send(:parameters)[:content].split("\n")
              expect(lines & Array(param[:match])).to eq(Array(param[:match]))
            end
            Array(param[:notmatch]).each do |item|
              is_expected.to contain_concat__fragment("#{title}-ssl-header").without_content(item)
            end
          end
        end
      end
    end

    describe "vhost_ssl_footer template content" do
      [
        {
          :title    => 'should not contain www to non-www rewrite',
          :attr     => 'rewrite_www_to_non_www',
          :value    => false,
          :notmatch => %r|
            ^
            \s+server_name\s+www\.rspec\.example\.com;\n
            \s+return\s+301\s+https://rspec\.example\.com\$request_uri;
          |x,
        },
        {
          :title => 'should contain include directives',
          :attr  => 'include_files',
          :value => [ '/file1', '/file2' ],
          :match => [
            %r'^\s+include\s+/file1;',
            %r'^\s+include\s+/file2;',
          ],
        },
        {
          :title => 'should contain ordered appended directives',
          :attr  => 'vhost_cfg_append',
          :value => { 'test1' => 'test value 1', 'test2' => 'test value 2', 'allow' => 'test value 3' },
          :match => [
            '  allow test value 3;',
            '  test1 test value 1;',
            '  test2 test value 2;',
          ]
        },
        {
          :title => 'should contain raw_append directives',
          :attr  => 'raw_append',
          :value => [
            'if (a) {',
            '  b;',
            '}'
          ],
          :match => /^\s+if \(a\) {\n\s++b;\n\s+\}/,
        },
        {
          :title => 'should contain ordered ssl appended directives',
          :attr  => 'vhost_cfg_ssl_append',
          :value => { 'test1' => 'test value 1', 'test2' => ['test value 2a', 'test value 2b'], 'allow' => 'test value 3' },
          :match => [
            '  allow test value 3;',
            '  test1 test value 1;',
            '  test2 test value 2a;',
            '  test2 test value 2b;',
          ]
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :params do default_params.merge({
            param[:attr].to_sym => param[:value],
            :ssl                => true,
            :ssl_key            => 'dummy.key',
            :ssl_cert           => 'dummy.crt',
          }) end

          it { is_expected.to contain_concat__fragment("#{title}-ssl-footer") }
          it param[:title] do
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| is_expected.to contain_concat__fragment("#{title}-ssl-footer").with_content(item) }
            else
              lines = catalogue.resource('concat::fragment', "#{title}-ssl-footer").send(:parameters)[:content].split("\n")
              expect(lines & Array(param[:match])).to eq(Array(param[:match]))
            end
            Array(param[:notmatch]).each do |item|
              is_expected.to contain_concat__fragment("#{title}-ssl-footer").without_content(item)
            end
          end
        end
      end
    end

    context 'attribute resources' do
      context "with SSL enabled, www rewrite to naked domain with multiple server_names" do
        let :title do 'foo.com' end
        let(:params) do
          {
            :ssl                    => true,
            :ssl_cert               => 'cert',
            :ssl_key                => 'key',
            :server_name            => %w(www.foo.com bar.foo.com foo.com),
            :use_default_location   => false,
            :rewrite_www_to_non_www => true,
          }
        end

        it "should set the server_name of the rewrite server stanza to every server_name with 'www.' stripped" do
          is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content(/^\s+server_name\s+foo.com\s+bar.foo.com\s+foo.com;/)
        end
      end

      context "with SSL disabled, www rewrite to naked domain with multiple server_names" do
        let :title do 'foo.com' end
        let(:params) do
          {
            :server_name            => %w(www.foo.com bar.foo.com foo.com),
            :use_default_location   => false,
            :rewrite_www_to_non_www => true,
          }
        end

        it "should set the server_name of the rewrite server stanza to every server_name with 'www.' stripped" do
          is_expected.to contain_concat__fragment("#{title}-header").with_content(/^\s+server_name\s+foo.com\s+bar.foo.com\s+foo.com;/)
        end
      end

      context "SSL cert missing" do
        let(:params) {{ :ssl => true, :ssl_key => 'key' }}

        it { expect { is_expected.to contain_class('nginx::resource::vhost') }.to raise_error(Puppet::Error) }
      end

      context "SSL key missing" do
        let(:params) {{ :ssl => true, :ssl_cert => 'cert' }}

        it { expect { is_expected.to contain_class('nginx::resource::vhost') }.to raise_error(Puppet::Error) }
      end

      context 'when use_default_location => true' do
        let :params do default_params.merge({
          :use_default_location => true,
        }) end

        it { is_expected.to contain_nginx__resource__location("#{title}-default") }
      end

      context 'when use_default_location => false' do
        let :params do default_params.merge({
          :use_default_location => false,
        }) end

        it { is_expected.not_to contain_nginx__resource__location("#{title}-default") }
      end

      context 'when location_cfg_prepend => { key => value }' do
        let :params do default_params.merge({
          :location_cfg_prepend => { 'key' => 'value' },
        }) end

        it { is_expected.to contain_nginx__resource__location("#{title}-default").with_location_cfg_prepend({ 'key' => 'value' }) }
      end

      context "when location_raw_prepend => [ 'foo;' ]" do
        let :params do default_params.merge({
          :location_raw_prepend => [ 'foo;' ],
        }) end

        it { is_expected.to contain_nginx__resource__location("#{title}-default").with_raw_prepend([ 'foo;' ]) }
      end

      context "when location_raw_append => [ 'foo;' ]" do
        let :params do default_params.merge({
          :location_raw_append => [ 'foo;' ],
        }) end

        it { is_expected.to contain_nginx__resource__location("#{title}-default").with_raw_append([ 'foo;' ]) }
      end

      context 'when location_cfg_append => { key => value }' do
        let :params do default_params.merge({
          :location_cfg_append => { 'key' => 'value' },
        }) end

        it { is_expected.to contain_nginx__resource__location("#{title}-default").with_location_cfg_append({ 'key' => 'value' }) }
      end

      context 'when fastcgi => "localhost:9000"' do
        let :params do default_params.merge({
          :fastcgi => 'localhost:9000',
        }) end

        it { is_expected.to contain_file('/etc/nginx/fastcgi_params').with_mode('0770') }
      end

      context 'when uwsgi => "uwsgi_upstream"' do
        let :params do default_params.merge({
          :uwsgi => 'uwsgi_upstream',
        }) end

        it { should contain_file('/etc/nginx/uwsgi_params').with_mode('0770') }
      end


      context 'when listen_port == ssl_port' do
        let :params do default_params.merge({
          :listen_port => 80,
          :ssl_port    => 80,
        }) end

        it { is_expected.not_to contain_concat__fragment("#{title}-header") }
        it { is_expected.not_to contain_concat__fragment("#{title}-footer") }
      end

      context 'when listen_port != ssl_port' do
        let :params do default_params.merge({
          :listen_port => 80,
          :ssl_port    => 443,
        }) end

        it { is_expected.to contain_concat__fragment("#{title}-header") }
        it { is_expected.to contain_concat__fragment("#{title}-footer") }
      end

      context 'when ensure => absent' do
        let :params do default_params.merge({
          :ensure   => 'absent',
          :ssl      => true,
          :ssl_key  => 'dummy.key',
          :ssl_cert => 'dummy.cert',
        }) end

        it { is_expected.to contain_nginx__resource__location("#{title}-default").with_ensure('absent') }
        it { is_expected.to contain_file("#{title}.conf symlink").with_ensure('absent') }
      end

      context 'when ssl => true and ssl_port == listen_port' do
        let :params do default_params.merge({
          :ssl         => true,
          :listen_port => 80,
          :ssl_port    => 80,
          :ssl_key     => 'dummy.key',
          :ssl_cert    => 'dummy.cert',
        }) end

        it { is_expected.to contain_nginx__resource__location("#{title}-default").with_ssl_only(true) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content(%r{access_log\s+/var/log/nginx/ssl-www\.rspec\.example\.com\.access\.log combined;}) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content(%r{error_log\s+/var/log/nginx/ssl-www\.rspec\.example\.com\.error\.log}) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content(%r{ssl_certificate\s+dummy.cert;}) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content(%r{ssl_certificate_key\s+dummy.key;}) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-footer") }
      end

      context 'when ssl_client_cert is set' do
        let :params do default_params.merge({
          :ssl                => true,
          :listen_port        => 80,
          :ssl_port           => 80,
          :ssl_key            => 'dummy.key',
          :ssl_cert           => 'dummy.cert',
          :ssl_client_cert    => 'client.cert',
        }) end

        it { is_expected.to contain_nginx__resource__location("#{title}-default").with_ssl_only(true) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content(%r{access_log\s+/var/log/nginx/ssl-www\.rspec\.example\.com\.access\.log combined;}) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content(%r{error_log\s+/var/log/nginx/ssl-www\.rspec\.example\.com\.error\.log}) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content(%r{ssl_verify_client on;}) }
      end
      context 'when passenger_cgi_param is set' do
        let :params do default_params.merge({
          :passenger_cgi_param => { 'test1' => 'test value 1', 'test2' => 'test value 2', 'test3' => 'test value 3' }
        }) end

        it { is_expected.to contain_concat__fragment("#{title}-header").with_content( /passenger_set_cgi_param  test1 test value 1;/ ) }
        it { is_expected.to contain_concat__fragment("#{title}-header").with_content( /passenger_set_cgi_param  test2 test value 2;/ ) }
        it { is_expected.to contain_concat__fragment("#{title}-header").with_content( /passenger_set_cgi_param  test3 test value 3;/ ) }
      end

      context 'when passenger_cgi_param is set and ssl => true' do
        let :params do default_params.merge({
          :passenger_cgi_param => { 'test1' => 'test value 1', 'test2' => 'test value 2', 'test3' => 'test value 3' },
          :ssl                 => true,
          :ssl_key             => 'dummy.key',
          :ssl_cert            => 'dummy.cert',
        }) end

        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content( /passenger_set_cgi_param  test1 test value 1;/ ) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content( /passenger_set_cgi_param  test2 test value 2;/ ) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content( /passenger_set_cgi_param  test3 test value 3;/ ) }
      end

      context 'when passenger_set_header is set' do
        let :params do default_params.merge({
          :passenger_set_header => { 'test1' => 'test value 1', 'test2' => 'test value 2', 'test3' => 'test value 3' }
        }) end

        it { is_expected.to contain_concat__fragment("#{title}-header").with_content( /passenger_set_header  test1 test value 1;/ ) }
        it { is_expected.to contain_concat__fragment("#{title}-header").with_content( /passenger_set_header  test2 test value 2;/ ) }
        it { is_expected.to contain_concat__fragment("#{title}-header").with_content( /passenger_set_header  test3 test value 3;/ ) }
      end

      context 'when passenger_set_header is set and ssl => true' do
        let :params do default_params.merge({
          :passenger_set_header => { 'test1' => 'test value 1', 'test2' => 'test value 2', 'test3' => 'test value 3' },
          :ssl                  => true,
          :ssl_key              => 'dummy.key',
          :ssl_cert             => 'dummy.cert',
        }) end

        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content( /passenger_set_header  test1 test value 1;/ ) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content( /passenger_set_header  test2 test value 2;/ ) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content( /passenger_set_header  test3 test value 3;/ ) }
      end

      context 'when passenger_env_var is set' do
        let :params do default_params.merge({
          :passenger_env_var => { 'test1' => 'test value 1', 'test2' => 'test value 2', 'test3' => 'test value 3' }
        }) end

        it { is_expected.to contain_concat__fragment("#{title}-header").with_content( /passenger_env_var  test1 test value 1;/ ) }
        it { is_expected.to contain_concat__fragment("#{title}-header").with_content( /passenger_env_var  test2 test value 2;/ ) }
        it { is_expected.to contain_concat__fragment("#{title}-header").with_content( /passenger_env_var  test3 test value 3;/ ) }
      end

      context 'when passenger_env_var is set and ssl => true' do
        let :params do default_params.merge({
          :passenger_env_var   => { 'test1' => 'test value 1', 'test2' => 'test value 2', 'test3' => 'test value 3' },
          :ssl                 => true,
          :ssl_key             => 'dummy.key',
          :ssl_cert            => 'dummy.cert',
        }) end

        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content( /passenger_env_var  test1 test value 1;/ ) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content( /passenger_env_var  test2 test value 2;/ ) }
        it { is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content( /passenger_env_var  test3 test value 3;/ ) }
      end

      context 'when vhost name is sanitized' do
        let :title do 'www rspec-vhost com' end
        let :params do default_params end

        it { is_expected.to contain_concat('/etc/nginx/sites-available/www_rspec-vhost_com.conf') }
      end

      context 'when add_header is set' do
        let :params do default_params.merge({
          :add_header => { 'header3' => 'test value 3', 'header2' => 'test value 2', 'header1' => 'test value 1' }
        }) end

        it 'should have correctly ordered entries in the config' do
          is_expected.to contain_concat__fragment("#{title}-header").with_content(/
            %r|
            \s+add_header\s+header1 test value 1;\n
            \s+add_header\s+header2 test value 2;\n
            \s+add_header\s+header3 test value 3;\n
            |/)
        end
      end

      context 'when add_header is set and ssl => true' do
        let :params do default_params.merge({
          :add_header => { 'header3' => 'test value 3', 'header2' => 'test value 2', 'header1' => 'test value 1' },
          :ssl        => true,
          :ssl_key    => 'dummy.key',
          :ssl_cert   => 'dummy.cert',
        }) end

        it 'should have correctly ordered entries in the config' do
          is_expected.to contain_concat__fragment("#{title}-ssl-header").with_content(/
            %r|
            \s+add_header\s+header1 test value 1;\n
            \s+add_header\s+header2 test value 2;\n
            \s+add_header\s+header3 test value 3;\n
            |/)
        end
      end
    end
  end
end
