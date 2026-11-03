require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache::mod::security class', :unless => (fact('osfamily') == 'Debian' and (fact('lsbdistcodename') == 'squeeze' or fact('lsbdistcodename') == 'lucid' or fact('lsbdistcodename') == 'precise' or fact('lsbdistcodename') == 'wheezy')) || (fact('operatingsystem') == 'SLES' and fact('operatingsystemrelease') < '11') do
  context "default mod_security config" do
    if fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') =~ /(5|6)/
      it 'adds epel' do
        pp = "class { 'epel': }"
        apply_manifest(pp, :catch_failures => true)
      end
    elsif fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') == '7'
      it 'changes obsoletes, per PUP-4497' do
        pp = <<-EOS
          ini_setting { 'obsoletes':
            path    => '/etc/yum.conf',
            section => 'main',
            setting => 'obsoletes',
            value   => '0',
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end
    end

    it 'succeeds in puppeting mod_security' do
      pp= <<-EOS
        host { 'modsec.example.com': ip => '127.0.0.1', }
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port    => '80',
          docroot => '#{$doc_root}/html',
        }
        file { '#{$doc_root}/html/index.html':
          ensure  => file,
          content => 'Index page',
        }
      EOS
      apply_manifest(pp, :catch_failures => true)

      #Need to add a short sleep here because on RHEL6 the service takes a bit longer to init
      if fact('osfamily') == 'RedHat' and fact('operatingsystemmajrelease') =~ /(5|6)/
        sleep 5
      end
    end

    describe service($service_name) do
      if (fact('operatingsystem') == 'Debian' && fact('operatingsystemmajrelease') == '8')
        pending 'Should be enabled - Bug 760616 on Debian 8'
      else
        it { should be_enabled }
      end
      it { is_expected.to be_running }
    end

    describe package($package_name) do
      it { is_expected.to be_installed }
    end

    describe file("#{$mod_dir}/security.conf") do
      it { is_expected.to contain "mod_security2.c" }
    end

    describe 'should be listening on port 80' do
      it 'should return index page' do
        shell('/usr/bin/curl -A beaker modsec.example.com:80') do |r|
          expect(r.stdout).to match(/Index page/)
          expect(r.exit_code).to eq(0)
        end
      end

      unless fact('operatingsystem') == 'SLES'
        it 'should block query with SQL' do
          shell '/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users', :acceptable_exit_codes => [22]
        end
      end
    end

  end #default mod_security config

  context "mod_security should allow disabling by vhost" do
    it 'succeeds in puppeting mod_security' do
      pp= <<-EOS
        host { 'modsec.example.com': ip => '127.0.0.1', }
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port    => '80',
          docroot => '#{$doc_root}/html',
        }
        file { '#{$doc_root}/html/index.html':
          ensure  => file,
          content => 'Index page',
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

    describe file("#{$mod_dir}/security.conf") do
      it { is_expected.to contain "mod_security2.c" }
    end

    unless fact('operatingsystem') == 'SLES'
      it 'should block query with SQL' do
        shell '/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users', :acceptable_exit_codes => [22]
      end
    end

    it 'should disable mod_security per vhost' do
      pp= <<-EOS
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port                 => '80',
          docroot              => '#{$doc_root}/html',
          modsec_disable_vhost => true,
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    it 'should return index page' do
      shell('/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users') do |r|
        expect(r.stdout).to match(/Index page/)
        expect(r.exit_code).to eq(0)
      end
    end
  end #mod_security should allow disabling by vhost

  context "mod_security should allow disabling by ip" do
    it 'succeeds in puppeting mod_security' do
      pp= <<-EOS
        host { 'modsec.example.com': ip => '127.0.0.1', }
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port    => '80',
          docroot => '#{$doc_root}/html',
        }
        file { '#{$doc_root}/html/index.html':
          ensure  => file,
          content => 'Index page',
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

    describe file("#{$mod_dir}/security.conf") do
      it { is_expected.to contain "mod_security2.c" }
    end

    unless fact('operatingsystem') == 'SLES'
      it 'should block query with SQL' do
        shell '/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users', :acceptable_exit_codes => [22]
      end
    end

    it 'should disable mod_security per vhost' do
      pp= <<-EOS
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port               => '80',
          docroot            => '#{$doc_root}/html',
          modsec_disable_ips => [ '127.0.0.1' ],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    it 'should return index page' do
      shell('/usr/bin/curl -A beaker modsec.example.com:80') do |r|
        expect(r.stdout).to match(/Index page/)
        expect(r.exit_code).to eq(0)
      end
    end
  end #mod_security should allow disabling by ip

  context "mod_security should allow disabling by id" do
    it 'succeeds in puppeting mod_security' do
      pp= <<-EOS
        host { 'modsec.example.com': ip => '127.0.0.1', }
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port    => '80',
          docroot => '#{$doc_root}/html',
        }
        file { '#{$doc_root}/html/index.html':
          ensure  => file,
          content => 'Index page',
        }
        file { '#{$doc_root}/html/index2.html':
          ensure  => file,
          content => 'Page 2',
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

    describe file("#{$mod_dir}/security.conf") do
      it { is_expected.to contain "mod_security2.c" }
    end

    unless fact('operatingsystem') == 'SLES'
      it 'should block query with SQL' do
        shell '/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users', :acceptable_exit_codes => [22]
      end
    end

    it 'should disable mod_security per vhost' do
      pp= <<-EOS
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port               => '80',
          docroot            => '#{$doc_root}/html',
          modsec_disable_ids => [ '950007' ],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    it 'should return index page' do
      shell('/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users') do |r|
        expect(r.stdout).to match(/Index page/)
        expect(r.exit_code).to eq(0)
      end
    end

  end #mod_security should allow disabling by id

  context "mod_security should allow disabling by msg" do
    it 'succeeds in puppeting mod_security' do
      pp= <<-EOS
        host { 'modsec.example.com': ip => '127.0.0.1', }
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port    => '80',
          docroot => '#{$doc_root}/html',
        }
        file { '#{$doc_root}/html/index.html':
          ensure  => file,
          content => 'Index page',
        }
        file { '#{$doc_root}/html/index2.html':
          ensure  => file,
          content => 'Page 2',
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

    describe file("#{$mod_dir}/security.conf") do
      it { is_expected.to contain "mod_security2.c" }
    end

    unless fact('operatingsystem') == 'SLES'
      it 'should block query with SQL' do
        shell '/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users', :acceptable_exit_codes => [22]
      end
    end

    it 'should disable mod_security per vhost' do
      pp= <<-EOS
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port               => '80',
          docroot            => '#{$doc_root}/html',
          modsec_disable_msgs => [ 'Blind SQL Injection Attack' ],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    it 'should return index page' do
      shell('/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users') do |r|
        expect(r.stdout).to match(/Index page/)
        expect(r.exit_code).to eq(0)
      end
    end

  end #mod_security should allow disabling by msg

  context "mod_security should allow disabling by tag" do
    it 'succeeds in puppeting mod_security' do
      pp= <<-EOS
        host { 'modsec.example.com': ip => '127.0.0.1', }
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port    => '80',
          docroot => '#{$doc_root}/html',
        }
        file { '#{$doc_root}/html/index.html':
          ensure  => file,
          content => 'Index page',
        }
        file { '#{$doc_root}/html/index2.html':
          ensure  => file,
          content => 'Page 2',
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

    describe file("#{$mod_dir}/security.conf") do
      it { is_expected.to contain "mod_security2.c" }
    end

    unless fact('operatingsystem') == 'SLES'
      it 'should block query with SQL' do
        shell '/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users', :acceptable_exit_codes => [22]
      end
    end

    it 'should disable mod_security per vhost' do
      pp= <<-EOS
        class { 'apache': }
        class { 'apache::mod::security': }
        apache::vhost { 'modsec.example.com':
          port                => '80',
          docroot             => '#{$doc_root}/html',
          modsec_disable_tags => [ 'WEB_ATTACK/SQL_INJECTION' ],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end

    it 'should return index page' do
      shell('/usr/bin/curl -A beaker -f modsec.example.com:80?SELECT%20*FROM%20mysql.users') do |r|
        expect(r.stdout).to match(/Index page/)
        expect(r.exit_code).to eq(0)
      end
    end

  end #mod_security should allow disabling by tag

end #apache::mod::security class
