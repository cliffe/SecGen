require 'spec_helper_acceptance'
require_relative './version.rb'

# Don't run this test on Debian < 8 or Ubuntu < 12, because Debian doesn't like
# updating packages and Pagespeed doesn't like old packages.
describe 'apache::mod::pagespeed class', :unless =>
  ((fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') < '8') or
   (fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemmajrelease') < '12') or
   (fact('operatingsystem') == 'SLES' )) do
  context "default pagespeed config" do
    it 'succeeds in puppeting pagespeed' do
      pp= <<-EOS
        if $::osfamily == 'Debian' {
          class { 'apt': }

          apt::source { 'mod-pagespeed':
            key         => '7FAC5991',
            key_server  => 'pgp.mit.edu',
            location    => 'http://dl.google.com/linux/mod-pagespeed/deb/',
            release     => 'stable',
            repos       => 'main',
            include_src => false,
            before      => Class['apache'],
          }
        } elsif $::osfamily == 'RedHat' {
         yumrepo { 'mod-pagespeed':
          baseurl  => "http://dl.google.com/linux/mod-pagespeed/rpm/stable/$::architecture",
            enabled  => 1,
            gpgcheck => 1,
            gpgkey   => 'https://dl-ssl.google.com/linux/linux_signing_key.pub',
            before   => Class['apache'],
          }
        }

        class { 'apache':
          mpm_module => 'prefork',
        }
        class { 'apache::mod::pagespeed':
          enable_filters  => ['remove_comments'],
          disable_filters => ['extend_cache'],
          forbid_filters  => ['rewrite_javascript'],
        }
        apache::vhost { 'pagespeed.example.com':
          port    => '80',
          docroot => '#{$doc_root}/pagespeed',
        }
        host { 'pagespeed.example.com': ip => '127.0.0.1', }
        file { '#{$doc_root}/pagespeed/index.html':
          ensure  => file,
          content => "<html>\n<!-- comment -->\n<body>\n<p>Hello World!</p>\n</body>\n</html>",
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

    describe file("#{$mod_dir}/pagespeed.conf") do
      it { is_expected.to contain "AddOutputFilterByType MOD_PAGESPEED_OUTPUT_FILTER text/html" }
      it { is_expected.to contain "ModPagespeedEnableFilters remove_comments" }
      it { is_expected.to contain "ModPagespeedDisableFilters extend_cache" }
      it { is_expected.to contain "ModPagespeedForbidFilters rewrite_javascript" }
    end

    it 'should answer to pagespeed.example.com and include <head/> and be stripped of comments by mod_pagespeed' do
      shell("/usr/bin/curl pagespeed.example.com:80") do |r|
        expect(r.stdout).to match(/<head\/>/)
        expect(r.stdout).not_to match(/<!-- comment -->/)
        expect(r.exit_code).to eq(0)
      end
    end
  end
end
