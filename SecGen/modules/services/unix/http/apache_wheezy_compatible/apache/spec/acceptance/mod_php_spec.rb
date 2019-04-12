require 'spec_helper_acceptance'
require_relative './version.rb'

unless (fact('operatingsystem') == 'SLES' && fact('operatingsystemrelease') == '12.0')
  describe 'apache::mod::php class' do
    context "default php config" do
      it 'succeeds in puppeting php' do
        pp= <<-EOS
          class { 'apache':
            mpm_module => 'prefork',
          }
          class { 'apache::mod::php': }
          apache::vhost { 'php.example.com':
            port    => '80',
            docroot => '#{$doc_root}/php',
          }
          host { 'php.example.com': ip => '127.0.0.1', }
          file { '#{$doc_root}/php/index.php':
            ensure  => file,
            content => "<?php phpinfo(); ?>\\n",
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

      if (fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemmajrelease') == '16.04')
        describe file("#{$mod_dir}/php7.0.conf") do
          it { is_expected.to contain "DirectoryIndex index.php" }
        end
      else
        describe file("#{$mod_dir}/php5.conf") do
          it { is_expected.to contain "DirectoryIndex index.php" }
        end
      end

      it 'should answer to php.example.com' do
        shell("/usr/bin/curl php.example.com:80") do |r|
          expect(r.stdout).to match(/PHP Version/)
          expect(r.exit_code).to eq(0)
        end
      end
    end

    context "custom extensions, php_flag, php_value, php_admin_flag, and php_admin_value" do
      it 'succeeds in puppeting php' do
        pp= <<-EOS
          class { 'apache':
            mpm_module => 'prefork',
          }
          class { 'apache::mod::php':
            extensions => ['.php','.php5'],
          }
          apache::vhost { 'php.example.com':
            port             => '80',
            docroot          => '#{$doc_root}/php',
            php_values       => { 'include_path' => '.:/usr/share/pear:/usr/bin/php', },
            php_flags        => { 'display_errors' => 'on', },
            php_admin_values => { 'open_basedir' => '/var/www/php/:/usr/share/pear/', },
            php_admin_flags  => { 'engine' => 'on', },
          }
          host { 'php.example.com': ip => '127.0.0.1', }
          file { '#{$doc_root}/php/index.php5':
            ensure  => file,
            content => "<?php phpinfo(); ?>\\n",
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

      describe file("#{$vhost_dir}/25-php.example.com.conf") do
        it { is_expected.to contain "  php_flag display_errors on" }
        it { is_expected.to contain "  php_value include_path \".:/usr/share/pear:/usr/bin/php\"" }
        it { is_expected.to contain "  php_admin_flag engine on" }
        it { is_expected.to contain "  php_admin_value open_basedir /var/www/php/:/usr/share/pear/" }
      end

      it 'should answer to php.example.com' do
        shell("/usr/bin/curl php.example.com:80") do |r|
          expect(r.stdout).to match(/\/usr\/share\/pear\//)
          expect(r.exit_code).to eq(0)
        end
      end
    end

    context "provide custom config file" do
      it 'succeeds in puppeting php' do
        pp= <<-EOS
          class {'apache':
            mpm_module => 'prefork',
          }
          class {'apache::mod::php':
            content => '# somecontent',
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end
      if (fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemmajrelease') == '16.04')
        describe file("#{$mod_dir}/php7.0.conf") do
          it { should contain "# somecontent" }
        end
      else
        describe file("#{$mod_dir}/php5.conf") do
          it { should contain "# somecontent" }
        end
      end
    end

    context "provide content and template config file" do
      it 'succeeds in puppeting php' do
        pp= <<-EOS
          class {'apache':
            mpm_module => 'prefork',
          }
          class {'apache::mod::php':
            content  => '# somecontent',
            template => 'apache/mod/php5.conf.erb',
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      if (fact('operatingsystem') == 'Ubuntu' && fact('operatingsystemmajrelease') == '16.04')
        describe file("#{$mod_dir}/php7.0.conf") do
          it { should contain "# somecontent" }
        end
      else
        describe file("#{$mod_dir}/php5.conf") do
          it { should contain "# somecontent" }
        end
      end
    end

  end
end
