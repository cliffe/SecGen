require 'spec_helper'
describe 'ruby::bundle', :type => :define do
  describe 'on RedHat based systems' do
    let (:facts) do
      {
        :osfamily       => 'RedHat',
        :processorcount => '4'
      }
    end
    let :pre_condition do
      "include ruby\ninclude ruby::dev"
    end
    context 'with no parameters' do
      let :title do
        'install'
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'command'     => 'bundle install',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle check',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the install command' do
      let :title do
        'install'
      end
      let :params do
        {
          :command => 'install',
        }
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'command'     => 'bundle install',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle check',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the update command' do
      let :title do
        'update'
      end
      let :params do
        {
          :command => 'update',
        }
      end
      it {
        should contain_exec('ruby_bundle_update').with({
          'command'     => 'bundle update',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle outdated',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the install command with multicore 0' do
      let :title do
        'install'
      end
      let :params do
        {
          :command   => 'install',
          :multicore => '0'
        }
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'command'     => 'bundle install --jobs 4',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle check',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the install command with multicore less than max' do
      let :title do
        'install'
      end
      let :params do
        {
          :command   => 'install',
          :multicore => '3'
        }
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'command'     => 'bundle install --jobs 3',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle check',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the install command with multicore greater than max' do
      let :title do
        'install'
      end
      let :params do
        {
          :command   => 'install',
          :multicore => '17'
        }
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'command'     => 'bundle install --jobs 4',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle check',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the update command with multicore 0' do
      let :title do
        'update'
      end
      let :params do
        {
          :command   => 'update',
          :multicore => '0'
        }
      end
      it {
        should contain_exec('ruby_bundle_update').with({
          'command'     => 'bundle update --jobs 4',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle outdated',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the update command with multicore less than max' do
      let :title do
        'update'
      end
      let :params do
        {
          :command   => 'update',
          :multicore => '3'
        }
      end
      it {
        should contain_exec('ruby_bundle_update').with({
          'command'     => 'bundle update --jobs 3',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle outdated',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the update command with multicore greater than max' do
      let :title do
        'update'
      end
      let :params do
        {
          :command   => 'update',
          :multicore => '17'
        }
      end
      it {
        should contain_exec('ruby_bundle_update').with({
          'command'     => 'bundle update --jobs 4',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle outdated',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the install command with multicore 0' do
      let :title do
        'install'
      end
      let :params do
        {
          :command   => 'install',
          :multicore => '0'
        }
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'command'     => 'bundle install --jobs 4',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle check',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the install command with multicore less than max' do
      let :title do
        'install'
      end
      let :params do
        {
          :command   => 'install',
          :multicore => '3'
        }
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'command'     => 'bundle install --jobs 3',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle check',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the install command with multicore greater than max' do
      let :title do
        'install'
      end
      let :params do
        {
          :command   => 'install',
          :multicore => '17'
        }
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'command'     => 'bundle install --jobs 4',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle check',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the update command with multicore 0' do
      let :title do
        'update'
      end
      let :params do
        {
          :command   => 'update',
          :multicore => '0'
        }
      end
      it {
        should contain_exec('ruby_bundle_update').with({
          'command'     => 'bundle update --jobs 4',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle outdated',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the update command with multicore less than max' do
      let :title do
        'update'
      end
      let :params do
        {
          :command   => 'update',
          :multicore => '3'
        }
      end
      it {
        should contain_exec('ruby_bundle_update').with({
          'command'     => 'bundle update --jobs 3',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle outdated',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'with the update command with multicore greater than max' do
      let :title do
        'update'
      end
      let :params do
        {
          :command   => 'update',
          :multicore => '17'
        }
      end
      it {
        should contain_exec('ruby_bundle_update').with({
          'command'     => 'bundle update --jobs 4',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle outdated',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'when using the install command with options' do
      let :title do
        'install_with_options'
      end
      let :params do
        {
          :command => 'install',
          :option  => '--clean --deployment --gemfile=magical --path=/path/to/wherever --no-prune --without test development foo baa'
        }
      end
      it {
        should contain_exec('ruby_bundle_install_with_options').with({
          'command'     => 'bundle install --clean --deployment --gemfile=magical --path=/path/to/wherever --no-prune --without test development foo baa',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle check',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'when using the update command with options' do
      let :title do
        'update_with_options'
      end
      let :params do
        {
          :command => 'update',
          :option  => '--local --source=http://some.gem.repo.org'
        }
      end
      it {
        should contain_exec('ruby_bundle_update_with_options').with({
          'command'     => 'bundle update --local --source=http://some.gem.repo.org',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle outdated --local --source=http://some.gem.repo.org',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'when using the exec command with options' do
      let :title do
        'exec_with_options'
      end
      let :params do
        {
          :command => 'exec',
          :option  => 'echo foo >> test',
          :unless  => 'grep foo test'
        }
      end
      it {
        should contain_exec('ruby_bundle_exec_with_options').with({
          'command'     => 'bundle exec echo foo >> test',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'grep foo test',
          'require'     => 'Package[bundler]'
        })
      }
    end
    context 'when using the exec command without options' do
      let :title do
        'exec_without_options'
      end
      let :params do
        {
          :command => 'exec',
        }
      end
      it do
        expect {
          should contain_exec('ruby_bundle_exec_without_options')
        }.to raise_error(Puppet::Error, /When given the exec command the ruby::bundle resource requires the command to be executed to be passed to the option parameter/)
      end
    end
    context 'with more paths' do
      let :title do
        'install'
      end
      let :params do
        {
          :command  => 'install',
          :path     => ['/usr/share/foo/bin','/path/to/sbin']
        }
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'path'        => ['/usr/share/foo/bin', '/path/to/sbin', '/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
        })
      }
    end
    context 'with more environment variables' do
      let :title do
        'install'
      end
      let :params do
        {
          :command      => 'install',
          :environment  => ['SHIELDS=up','PHASERS=stun']
        }
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'environment' => ['SHIELDS=up', 'PHASERS=stun', 'RAILS_ENV=production'],
        })
      }
    end
    context 'with a custom Rails environment' do
      let :title do
        'install'
      end
      let :params do
        {
          :command      => 'install',
          :rails_env    => 'test'
        }
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'environment' => 'RAILS_ENV=test',
        })
      }
    end
    context 'that all parameters pass through' do
      let :title do
        'install'
      end
      let :params do
        {
          :command      => 'install',
          :creates      => '/path/to/file',
          :cwd          => '/path/to/dir',
          :user         => 'nobody',
          :group        => 'anyone',
          :logoutput    => true,
          :onlyif       => 'confused',
          :refresh      => true,
          :refreshonly  => true,
          :timeout      => '300',
          :tries        => '2',
          :try_sleep    => '30'
        }
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'command'      => 'bundle install',
          'creates'      => '/path/to/file',
          'cwd'          => '/path/to/dir',
          'user'         => 'nobody',
          'group'        => 'anyone',
          'logoutput'    => true,
          'onlyif'       => 'confused',
          'refresh'      => true,
          'refreshonly'  => true,
          'timeout'      => '300',
          'tries'        => '2',
          'try_sleep'    => '30'
        })
      }
    end
  end
  describe 'on Amazon based systems' do
    let (:facts) do
      {
        :osfamily => 'Amazon'
      }
    end
    let :pre_condition do
      "include ruby\ninclude ruby::dev"
    end
    context 'with no parameters' do
      let :title do
        'install'
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'command'     => 'bundle install',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle check',
          'require'     => 'Package[bundler]'
        })
      }
    end
  end
  describe 'on Debian based systems' do
    let (:facts) do
      {
        :osfamily => 'Debian'
      }
    end
    let :pre_condition do
      "include ruby\ninclude ruby::dev"
    end
    context 'with no parameters' do
      let :title do
        'install'
      end
      it {
        should contain_exec('ruby_bundle_install').with({
          'command'     => 'bundle install',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'unless'      => 'bundle check',
          'require'     => 'Package[bundler]'
        })
      }
    end
  end
  describe 'on an Unknown OS' do
    let :facts do
      {
        :osfamily   => 'Unknown'
      }
    end
    let :title do
      'test'
    end
    it do
      expect {
        should contain_class('puppet::params')
      }.to raise_error(Puppet::Error, /Unsupported OS family: Unknown/)
    end
  end
end