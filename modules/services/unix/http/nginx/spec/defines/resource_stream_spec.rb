require 'spec_helper'

describe 'nginx::resource::streamhost' do
  let :title do
    'www.rspec.example.com'
  end
  let :default_params do
    {
      :ipv6_enable => true,
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
      it { is_expected.to contain_concat("/etc/nginx/streams-available/#{title}.conf").with({
        'owner' => 'root',
        'group' => 'root',
        'mode'  => '0644',
      })}
      it { is_expected.to contain_file("#{title}.conf symlink").with({
        'ensure' => 'link',
        'path'   => "/etc/nginx/streams-enabled/#{title}.conf",
        'target' => "/etc/nginx/streams-available/#{title}.conf"
      })}
    end

    describe "vhost_header template content" do
      [
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
          :title => 'should set servername(s)',
          :attr  => 'server_name',
          :value => ['www.foo.com','foo.com'],
          :match => %r'\s+server_name\s+www.foo.com foo.com;',
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
  end
end
