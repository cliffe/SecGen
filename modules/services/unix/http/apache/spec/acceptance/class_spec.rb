require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache class' do
  context 'default parameters' do
    let(:pp) { "class { 'apache': }" }

    it_behaves_like "a idempotent resource"

    describe 'apache_version fact' do
      before :all do
        apply_manifest("include apache", :catch_failures => true)
        version_check_pp = <<-EOS
        notice("apache_version = >${apache_version}<")
        EOS
        @result = apply_manifest(version_check_pp, :catch_failures => true)
      end

      it {
        expect(@result.output).to match(/apache_version = >#{$apache_version}.*</)
      }
    end

    describe package($package_name) do
      it { is_expected.to be_installed }
    end

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { is_expected.to be_running }
    end

    describe port(80) do
      it { should be_listening }
    end
  end

  context 'custom site/mod dir parameters' do
    # Using puppet_apply as a helper
    let(:pp) do
      <<-EOS
        if $::osfamily == 'RedHat' and "$::selinux" == "true" {
          $semanage_package = $::operatingsystemmajrelease ? {
            '5'     => 'policycoreutils',
            default => 'policycoreutils-python',
          }

          package { $semanage_package: ensure => installed }
          exec { 'set_apache_defaults':
            command     => 'semanage fcontext -a -t httpd_sys_content_t "/apache_spec(/.*)?"',
            path        => '/bin:/usr/bin/:/sbin:/usr/sbin',
            subscribe   => Package[$semanage_package],
            refreshonly => true,
          }
          exec { 'restorecon_apache':
            command     => 'restorecon -Rv /apache_spec',
            path        => '/bin:/usr/bin/:/sbin:/usr/sbin',
            before      => Service['httpd'],
            require     => Class['apache'],
            subscribe   => Exec['set_apache_defaults'],
            refreshonly => true,
          }
        }
        file { '/apache_spec': ensure => directory, }
        file { '/apache_spec/apache_custom': ensure => directory, }
        class { 'apache':
          mod_dir   => '/apache_spec/apache_custom/mods',
          vhost_dir => '/apache_spec/apache_custom/vhosts',
        }
      EOS
    end

    # Run it twice and test for idempotency
    it_behaves_like "a idempotent resource"

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { is_expected.to be_running }
    end
  end
end
