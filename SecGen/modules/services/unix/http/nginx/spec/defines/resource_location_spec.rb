require 'spec_helper'
require 'digest/md5'

describe 'nginx::resource::location' do
  let :title do
    'rspec-test'
  end
  let :pre_condition do
    [
      'include ::nginx::config',
    ]
  end

  describe 'os-independent items' do

    describe 'basic assumptions' do
      let :params do {
        :www_root => "/var/www/rspec",
        :vhost    => 'vhost1',
      } end

      it { is_expected.to contain_class("nginx::config") }
      it { is_expected.to contain_concat__fragment("vhost1-500-33c6aa94600c830ad2d316bb4db36724").with_content(/location rspec-test/) }
      it { is_expected.not_to contain_file('/etc/nginx/fastcgi_params') }
      it { is_expected.not_to contain_concat__fragment("vhost1-800-rspec-test-ssl") }
      it { is_expected.not_to contain_file("/etc/nginx/rspec-test_htpasswd") }
    end

    describe "vhost/location_header template content" do
      [
        {
          :title => 'should set the location',
          :attr  => 'location',
          :value => 'my_location',
          :match => '  location my_location {',
        },
        {
          :title    => 'should not set internal',
          :attr     => 'internal',
          :value    => false,
          :notmatch => /internal;/
        },
        {
          :title => 'should set internal',
          :attr  => 'internal',
          :value => true,
          :match => '    internal;'
        },
        {
          :title    => 'should not set mp4',
          :attr     => 'mp4',
          :value    => false,
          :notmatch => /mp4;/
        },
        {
          :title => 'should set mp4',
          :attr  => 'mp4',
          :value => true,
          :match => '    mp4;'
        },
        {
          :title    => 'should not set flv',
          :attr     => 'flv',
          :value    => false,
          :notmatch => /flv;/
        },
        {
          :title => 'should set flv',
          :attr  => 'flv',
          :value => true,
          :match => '    flv;'
        },
        {
          :title => 'should set location_allow',
          :attr  => 'location_allow',
          :value => %w( 127.0.0.1 10.0.0.1 ),
          :match => [
            '    allow 127.0.0.1;',
            '    allow 10.0.0.1;',
          ],
        },
        {
          :title => 'should set location_deny',
          :attr  => 'location_deny',
          :value => %w( 127.0.0.1 10.0.0.1 ),
          :match => [
            '    deny 127.0.0.1;',
            '    deny 10.0.0.1;',
          ],
        },
        {
          :title => 'should contain ordered prepended directives',
          :attr  => 'location_cfg_prepend',
          :value => { 'test1' => 'test value 1', 'test2' => ['test value 2a', 'test value 2b'],
                      'test3' => { 'subtest1' => ['"sub test value1a"', '"sub test value1b"'],
                                  'subtest2' => '"sub test value2"' } },
          :match => [
            '    test1 test value 1;',
            '    test2 test value 2a;',
            '    test2 test value 2b;',
            '    test3 subtest1 "sub test value1a";',
            '    test3 subtest1 "sub test value1b";',
            '    test3 subtest2 "sub test value2";',
          ],
        },
        {
          :title => 'should contain custom prepended directives',
          :attr  => 'location_custom_cfg_prepend',
          :value => { 'test1' => 'bar', 'test2' => ['foobar', 'barbaz'],
                      'test3' => { 'subtest1' => ['"sub test value1a"', '"sub test value1b"'],
                                  'subtest2' => '"sub test value2"' } },
          :match => [
            /^[ ]+test1\s+bar/,
            /^[ ]+test2\s+foobar/,
            /^[ ]+test2\s+barbaz/,
            /^[ ]+test3\s+subtest1 "sub test value1a"/,
            /^[ ]+test3\s+subtest1 "sub test value1b"/,
            /^[ ]+test3\s+subtest2 "sub test value2"/,
          ],
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
          :title => 'should contain rewrite rules',
          :attr  => 'rewrite_rules',
          :value => [
            '^(/download/.*)/media/(.*)\..*$ $1/mp3/$2.mp3 last',
            '^(/download/.*)/media/(.*)\..*$ $1/mp3/$2.ra  last',
            '^/users/(.*)$ /show?user=$1? last',
          ],
          :match => [
            /rewrite \^\(\/download\/\.\*\)\/media\/\(\.\*\)\\\.\.\*\$ \$1\/mp3\/\$2\.mp3 last/,
            /rewrite \^\(\/download\/\.\*\)\/media\/\(\.\*\)\\\.\.\*\$ \$1\/mp3\/\$2\.ra  last/,
            /rewrite \^\/users\/\(\.\*\)\$ \/show\?user=\$1\? last/,
          ],
        },
        {
          :title    => 'should not set rewrite_rules',
          :attr     => 'rewrite_rules',
          :value    => [],
          :notmatch => /rewrite/
        },
        {
          :title => 'should set auth_basic',
          :attr  => 'auth_basic',
          :value => 'value',
          :match => '    auth_basic           "value";',
        },
        {
          :title => 'should set auth_basic_user_file',
          :attr  => 'auth_basic_user_file',
          :value => 'value',
          :match => '    auth_basic_user_file value;',
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :default_params do { :location => 'location', :proxy => 'proxy_value', :vhost => 'vhost1' } end
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")) }

          it param[:title] do
            fragment = "vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| is_expected.to contain_concat__fragment(fragment).with_content(item) }
            else
              lines = catalogue.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              expect(lines & matches).to eq(matches)
            end

            Array(param[:notmatch]).each do |item|
              is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).without_content(item)
            end
          end
        end
      end
    end

    describe "vhost/location_footer template content" do
      [
        {
          :title => 'should contain ordered appended directives',
          :attr  => 'location_cfg_append',
          :value => { 'test1' => 'test value 1', 'test2' => ['test value 2a', 'test value 2b'],
                      'test3' => { 'subtest1' => ['"sub test value1a"', '"sub test value1b"'],
                                  'subtest2' => '"sub test value2"' } },
          :match => [
            '    test1 test value 1;',
            '    test2 test value 2a;',
            '    test2 test value 2b;',
            '    test3 subtest1 "sub test value1a";',
            '    test3 subtest1 "sub test value1b";',
            '    test3 subtest2 "sub test value2";',
          ],
        },
        {
          :title => 'should contain include directives',
          :attr  => 'include',
          :value => [ '/file1', '/file2' ],
          :match => [
            %r'^\s+include\s+/file1;',
            %r'^\s+include\s+/file2;',
          ],
        },
        {
          :title => 'should contain custom appended directives',
          :attr  => 'location_custom_cfg_append',
          :value => { 'test1' => 'bar', 'test2' => ['foobar', 'barbaz'],
                      'test3' => { 'subtest1' => ['"sub test value1a"', '"sub test value1b"'],
                                  'subtest2' => '"sub test value2"' } },
          :match => [
            /^[ ]+test1\s+bar/,
            /^[ ]+test2\s+foobar/,
            /^[ ]+test2\s+barbaz/,
            /^[ ]+test3\s+subtest1 "sub test value1a"/,
            /^[ ]+test3\s+subtest1 "sub test value1b"/,
            /^[ ]+test3\s+subtest2 "sub test value2"/,
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
          let :default_params do { :location => 'location', :proxy => 'proxy_value', :vhost => 'vhost1' } end
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")) }

          it param[:title] do
            fragment = "vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| is_expected.to contain_concat__fragment(fragment).with_content(item) }
            else
              lines = catalogue.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              expect(lines & matches).to eq(matches)
            end

            Array(param[:notmatch]).each do |item|
              is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).without_content(item)
            end
          end

          it "should end with a closing brace" do
            fragment = "vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")
            content = catalogue.resource('concat::fragment', fragment).send(:parameters)[:content]
            expect((content.split("\n").reject {|l| l =~ /^(\s*#|$)/ }.last).strip).to eq('}')
          end
        end
      end
    end

    describe "vhost_location_alias template content" do
      let :default_params do
        { :location => 'location', :vhost => 'vhost1', :location_alias => 'value' }
      end

      context "when location_alias is 'value'" do
        let :params do default_params end
        it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("location")) }
        it "should set alias" do
          is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("location")).
                  with_content(/^[ ]+alias\s+value;/)
        end
      end

      context "when autoindex is 'on'" do
        let :params do default_params.merge({ :autoindex => 'on' }) end
        it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("location")) }
        it "should set autoindex" do
          is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("location")).
                  with_content(/^[ ]+autoindex\s+on;/)
        end
      end

      context "when autoindex is not set" do
        let :params do default_params end
        it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("location")) }
        it "should not set autoindex" do
          is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("location")).
                  without_content(/^[ ]+autoindex[^;]+;/)
        end
      end
    end

    describe "vhost_location_directory template content" do
      let :default_params do
        {
          :location => 'location',
          :www_root => '/var/www/root',
          :vhost    => 'vhost1',
        }
      end

      [
        {
          :title => 'should set www_root',
          :attr  => 'www_root',
          :value => '/',
          :match => '    root      /;'
        },
        {
          :title => 'should set try_file(s)',
          :attr  => 'try_files',
          :value => ['name1','name2'],
          :match => '    try_files name1 name2;',
        },
        {
          :title => 'should set index_file(s)',
          :attr  => 'index_files',
          :value => ['name1','name2'],
          :match => '    index     name1 name2;',
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")) }
          it param[:title] do
            fragment = "vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| is_expected.to contain_concat__fragment(fragment).with_content(item) }
            else
              lines = catalogue.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              expect(lines & matches).to eq(matches)
            end

            Array(param[:notmatch]).each do |item|
              is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).without_content(item)
            end
          end
        end
      end

      context "when autoindex is 'on'" do
        let :params do default_params.merge({ :autoindex => 'on' }) end
        it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("location")) }
        it "should set autoindex" do
          is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("location")).
                  with_content(/^[ ]+autoindex\s+on;/)
        end
      end

      context "when autoindex is not set" do
        let :params do default_params end
        it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("location")) }
        it "should not set autoindex" do
          is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("location")).
                  without_content(/^[ ]+autoindex[^;]+;/)
        end
      end
    end

    describe "vhost_location_empty template content" do
      [
        {
          :title => 'should contain ordered config directives',
          :attr  => 'location_custom_cfg',
          :value => { 'test1' => ['test value 1a', 'test value 1b'], 'test2' => 'test value 2', 'allow' => 'test value 3',
                      'test4' => { 'subtest1' => ['"sub test value1a"', '"sub test value1b"'],
                                  'subtest2' => '"sub test value2"' } },
          :match => [
            '    allow test value 3;',
            '    test1 test value 1a;',
            '    test1 test value 1b;',
            '    test2 test value 2;',
            '    test4 subtest1 "sub test value1a";',
            '    test4 subtest1 "sub test value1b";',
            '    test4 subtest2 "sub test value2";',
          ],
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :default_params do { :location => 'location', :location_custom_cfg => {'test1'=>'value1'}, :vhost => 'vhost1' } end
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")) }
          it param[:title] do
            fragment = "vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| is_expected.to contain_concat__fragment(fragment).with_content(item) }
            else
              lines = catalogue.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              expect(lines & matches).to eq(matches)
            end

            Array(param[:notmatch]).each do |item|
              is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).without_content(item)
            end
          end
        end
      end
    end

    describe "vhost_location_fastcgi template content" do
      let :default_params do
        {
          :location => 'location',
          :fastcgi  => 'localhost:9000',
          :vhost    => 'vhost1'
        }
      end

      [
        {
          :title => 'should set www_root',
          :attr  => 'www_root',
          :value => '/',
          :match => %r'\s+root\s+/;'
        },
        {
          :title => 'should set fastcgi_split_path',
          :attr  => 'fastcgi_split_path',
          :value => 'value',
          :match => %r'\s+fastcgi_split_path_info\s+value;'
        },
        {
          :title => 'should set try_file(s)',
          :attr  => 'try_files',
          :value => ['name1','name2'],
          :match => %r'\s+try_files\s+name1 name2;',
        },
        {
          :title => 'should set fastcgi_params',
          :attr  => 'fastcgi_params',
          :value => 'value',
          :match => %r'\s+include\s+value;'
        },
        {
          :title => 'should set fastcgi_pass',
          :attr  => 'fastcgi',
          :value => 'value',
          :match => %r'\s+fastcgi_pass\s+value;'
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")) }
          it param[:title] do
            fragment = "vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| is_expected.to contain_concat__fragment(fragment).with_content(item) }
            else
              lines = catalogue.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              expect(lines & matches).to eq(matches)
            end

            Array(param[:notmatch]).each do |item|
              is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).without_content(item)
            end
          end
        end
      end

      context "when fastcgi_script is 'value'" do
        let :params do default_params.merge({ :fastcgi_script => 'value' }) end
        it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")) }
        it "should set fastcgi_script" do
          is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).
                  with_content(%r|^[ ]+fastcgi_param\s+SCRIPT_FILENAME\s+value;|)
        end
      end

      context "when fastcgi_script is not set" do
        let :params do default_params end
        it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")) }
        it "should not set fastcgi_script" do
          is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).
                  without_content(/^[ ]+fastcgi_param\s+SCRIPT_FILENAME\s+.+?;/)
        end
      end

      context "when fastcgi_param is {'CUSTOM_PARAM' => 'value'}" do
        let :params do default_params.merge({ :fastcgi_param => {'CUSTOM_PARAM' => 'value', 'CUSTOM_PARAM2' => 'value2'} }) end
        it "should set fastcgi_param" do
        should contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).
                  with_content(%r|fastcgi_param\s+CUSTOM_PARAM\s+value;|).
                  with_content(%r|fastcgi_param\s+CUSTOM_PARAM2\s+value2;|)
        end
      end

      context "when fastcgi_param is not set" do
        let :params do default_params end
        it "should not set fastcgi_param" do
        should contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).
                  without_content(/fastcgi_param\s+CUSTOM_PARAM\s+.+?;/).
                  without_content(/fastcgi_param\s+CUSTOM_PARAM2\s+.+?;/)
        end
        it "should not add comment # Enable custom fastcgi_params" do
        should contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).
                  without_content(/# Enable custom fastcgi_params\s+/)
        end
      end
    end

    describe "vhost_location_uwsgi template content" do
      let :default_params do
        {
          :location => 'location',
          :uwsgi  => 'unix:/home/project/uwsgi.socket',
          :vhost    => 'vhost1'
        }
      end

      [
        {
          :title => 'should set www_root',
          :attr  => 'www_root',
          :value => '/',
          :match => %r'\s+root\s+/;'
        },
        {
          :title => 'should set try_file(s)',
          :attr  => 'try_files',
          :value => ['name1','name2'],
          :match => %r'\s+try_files\s+name1 name2;',
        },
        {
          :title => 'should set uwsgi_params',
          :attr  => 'uwsgi_params',
          :value => 'value',
          :match => %r'\s+include\s+value;'
        },
        {
          :title => 'should set uwsgi_pass',
          :attr  => 'uwsgi',
          :value => 'value',
          :match => %r'\s+uwsgi_pass\s+value;'
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")) }
          it param[:title] do
            fragment = "vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| is_expected.to contain_concat__fragment(fragment).with_content(item) }
            else
              lines = catalogue.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              expect(lines & matches).to eq(matches)
            end

            Array(param[:notmatch]).each do |item|
              is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).without_content(item)
            end
          end
        end
      end
    end


    describe "vhost_location_proxy template content" do
      [
        {
          :title => 'should set proxy_cache',
          :attr  => 'proxy_cache',
          :value => 'value',
          :match => /^\s+proxy_cache\s+value;/,
        },
        {
          :title    => 'should not set proxy_cache_valid',
          :attr     => 'proxy_cache_valid',
          :value    => false,
          :notmatch => /proxy_cache_valid\b/
        },
        {
          :title => 'should set proxy_cache_valid',
          :attr  => 'proxy_cache_valid',
          :value => 'value',
          :match => /^\s+proxy_cache_valid\s+value;/,
        },
        {
          :title    => 'should not set proxy_cache',
          :attr     => 'proxy_cache',
          :value    => false,
          :notmatch => /proxy_cache\b/
        },
        {
          :title => 'should set proxy_cache_key',
          :attr  => 'proxy_cache_key',
          :value => 'value',
          :match => /^\s+proxy_cache_key\s+value;/,
        },
        {
          :title => 'should set proxy_cache_use_stale',
          :attr  => 'proxy_cache_use_stale',
          :value => 'value',
          :match => /^\s+proxy_cache_use_stale\s+value;/
        },
        {
          :title => 'should set proxy_pass',
          :attr  => 'proxy',
          :value => 'value',
          :match => /^\s+proxy_pass\s+value;/,
        },
        {
          :title => 'should set proxy_read_timeout',
          :attr  => 'proxy_read_timeout',
          :value => 'value',
          :match => %r'\s+proxy_read_timeout\s+value;',
        },
        {
          :title => 'should set proxy_connect_timeout',
          :attr  => 'proxy_connect_timeout',
          :value => 'value',
          :match => %r'\s+proxy_connect_timeout\s+value;',
        },
        {
          :title => 'should set proxy_read_timeout',
          :attr  => 'proxy_read_timeout',
          :value => 'value',
          :match => %r'\s+proxy_read_timeout\s+value;',
        },
        {
          :title => 'should set proxy headers',
          :attr  => 'proxy_set_header',
          :value => [ 'X-TestHeader1 value1', 'X-TestHeader2 value2' ],
          :match => [
            /^\s+proxy_set_header\s+X-TestHeader1 value1;/,
            /^\s+proxy_set_header\s+X-TestHeader2 value2;/,
          ]
        },
        {
          :title => 'should set proxy_method',
          :attr  => 'proxy_method',
          :value => 'value',
          :match => %r'\s+proxy_method\s+value;',
        },
        {
          :title => 'should set proxy_set_body',
          :attr  => 'proxy_set_body',
          :value => 'value',
          :match => %r'\s+proxy_set_body\s+value;',
        },
      ].each do |param|
        context "when #{param[:attr]} is #{param[:value]}" do
          let :default_params do { :location => 'location', :proxy => 'proxy_value', :vhost => 'vhost1' } end
          let :params do default_params.merge({ param[:attr].to_sym => param[:value] }) end

          it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")) }
          it param[:title] do
            fragment = "vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")
            matches  = Array(param[:match])

            if matches.all? { |m| m.is_a? Regexp }
              matches.each { |item| is_expected.to contain_concat__fragment(fragment).with_content(item) }
            else
              lines = catalogue.resource('concat::fragment', fragment).send(:parameters)[:content].split("\n")
              expect(lines & matches).to eq(matches)
            end

            Array(param[:notmatch]).each do |item|
              is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).without_content(item)
            end
          end
        end
      end

      context "when proxy_cache_valid is 10m" do
        let :params do {
          :location => 'location',
          :proxy => 'proxy_value',
          :vhost => 'vhost1',
          :proxy_cache => 'true',
          :proxy_cache_valid => '10m',
        } end

        it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("location")).with_content(/proxy_cache_valid\s+10m;/) }
      end
    end

    describe "vhost_location_stub_status template content" do
      let :params do { :location => 'location', :stub_status => true, :vhost => 'vhost1' }  end
      it do
        is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("#{params[:location]}")).
                 with_content(/stub_status\s+on/)
      end
    end

    context 'attribute resources' do
      context 'when fastcgi => "localhost:9000"' do
        let :params do { :fastcgi => 'localhost:9000', :vhost => 'vhost1' } end

        it { is_expected.to contain_file('/etc/nginx/fastcgi_params').with_mode('0770') }
      end

      context 'when uwsgi => "unix:/home/project/uwsgi.socket"' do
        let :params do { :uwsgi => 'uwsgi_upstream', :vhost => 'vhost1' } end

        it { should contain_file('/etc/nginx/uwsgi_params') }
      end


      context 'when ssl_only => true' do
        let :params do { :ssl_only => true, :vhost => 'vhost1', :www_root => '/', } end
        it { is_expected.not_to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("rspec-test")) }
      end

      context 'when ssl_only => false' do
        let :params do { :ssl_only => false, :vhost => 'vhost1', :www_root => '/', } end

        it { is_expected.to contain_concat__fragment("vhost1-500-" + Digest::MD5.hexdigest("rspec-test")) }
      end

      context 'when ssl => true' do
        let :params do { :ssl => true, :vhost => 'vhost1', :www_root => '/', } end

        it { is_expected.to contain_concat__fragment("vhost1-800-" + Digest::MD5.hexdigest("rspec-test") + "-ssl") }
      end

      context 'when ssl => false' do
        let :params do { :ssl => false, :vhost => 'vhost1', :www_root => '/', } end

        it { is_expected.not_to contain_concat__fragment("vhost1-800-" + Digest::MD5.hexdigest("rspec-test") + "-ssl") }
      end

      context "vhost missing" do
        let :params do {
          :www_root => '/',
        } end

        it { expect { is_expected.to contain_class('nginx::resource::location') }.to raise_error(Puppet::Error, /Cannot create a location reference without attaching to a virtual host/) }
      end

      context "location type missing" do
        let :params do {
          :vhost => 'vhost1',
        } end

        it { expect { is_expected.to contain_class('nginx::resource::location') }.to raise_error(Puppet::Error, /Cannot create a location reference without a www_root, proxy, location_alias, fastcgi, uwsgi, stub_status, internal, or location_custom_cfg defined/) }
      end

      context "www_root and proxy are set" do
        let :params do {
          :vhost    => 'vhost1',
          :www_root => '/',
          :proxy    => 'http://localhost:8000/uri/',
        } end

        it { expect { is_expected.to contain_class('nginx::resource::location') }.to raise_error(Puppet::Error, /Cannot define both directory and proxy in a virtual host/) }
      end

      context 'when vhost name is sanitized' do
        let :title do 'www.rspec-location.com' end
        let :params do {
          :vhost => 'www rspec-vhost com',
          :www_root => '/',
          :ssl => true,
        } end

        it { is_expected.to contain_concat__fragment("www_rspec-vhost_com-500-" + Digest::MD5.hexdigest("www.rspec-location.com")).with_target('/etc/nginx/sites-available/www_rspec-vhost_com.conf') }
        it { is_expected.to contain_concat__fragment("www_rspec-vhost_com-800-" + Digest::MD5.hexdigest("www.rspec-location.com") + "-ssl").with_target('/etc/nginx/sites-available/www_rspec-vhost_com.conf') }
      end
    end
  end
end
