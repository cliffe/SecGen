require 'spec_helper'
describe 'ruby::rake', :type => :define do
  describe 'on RedHat based systems' do
    let (:facts) do
      {
        :osfamily => 'RedHat',
      }
    end
    let :pre_condition do
      "include ruby\ninclude ruby::dev"
    end
    context 'with minimum parameters' do
      let :title do
        'db_setup'
      end
      let :params do
        {
          :task => 'db:setup'
        }
      end
      it {
        should contain_exec('ruby_rake_db_setup').with({
          'command'     => 'rake db:setup',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'require'     => 'Package[rake]'
        })
      }
    end
    context 'with more paths' do
      let :title do
        'db_setup'
      end
      let :params do
        {
          :task     => 'db:setup',
          :path     => ['/usr/share/foo/bin','/path/to/sbin']
        }
      end
      it {
        should contain_exec('ruby_rake_db_setup').with({
          'path'        => ['/usr/share/foo/bin', '/path/to/sbin', '/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
        })
      }
    end
    context 'with more environment variables' do
      let :title do
        'db_setup'
      end
      let :params do
        {
          :task         => 'db:setup',
          :environment  => ['SHIELDS=up','PHASERS=stun']
        }
      end
      it {
        should contain_exec('ruby_rake_db_setup').with({
          'environment' => ['SHIELDS=up', 'PHASERS=stun', 'RAILS_ENV=production'],
        })
      }
    end
    context 'with a custom Rails environment' do
      let :title do
        'db_setup'
      end
      let :params do
        {
          :task       => 'db:setup',
          :rails_env  => 'test'
        }
      end
      it {
        should contain_exec('ruby_rake_db_setup').with({
          'environment' => 'RAILS_ENV=test',
        })
      }
    end
    context 'checking parameter passthrough' do
      let :title do
        'db_setup'
      end
      let :params do
        {
          :task         => 'db:setup',
          :creates      => '/path/to/file',
          :cwd          => '/path/to/dir',
          :user         => 'nobody',
          :group        => 'anybody',
          :logoutput    => true,
          :onlyif       => 'confused',
          :refresh      => true,
          :refreshonly  => true,
          :timeout      => '300',
          :tries        => '2',
          :try_sleep    => '30',
          :unless       => 'not true'
        }
      end
      it {
        should_not contain_ruby__bundle('ruby_rake_db_setup')
      }
      it {
        should contain_exec('ruby_rake_db_setup').with({
          'command'      => 'rake db:setup',
          'creates'      => '/path/to/file',
          'cwd'          => '/path/to/dir',
          'user'         => 'nobody',
          'group'        => 'anybody',
          'logoutput'    => true,
          'onlyif'       => 'confused',
          'refresh'      => true,
          'refreshonly'  => true,
          'timeout'      => '300',
          'tries'        => '2',
          'try_sleep'    => '30',
          'unless'       => 'not true'
        })
      }
    end
    context 'checking parameter passthrough when using the bundler wrapper' do
      let :title do
        'db_setup'
      end
      let :params do
        {
          :task         => 'db:setup',
          :bundle       => true,
          :rails_env    => 'test',
          :creates      => '/path/to/file',
          :cwd          => '/path/to/dir',
          :environment  => 'test',
          :user         => 'nobody',
          :group        => 'anybody',
          :logoutput    => true,
          :onlyif       => 'confused',
          :path         => ['/opt/app/bin','/usr/share/path'],
          :refresh      => true,
          :refreshonly  => true,
          :timeout      => '300',
          :tries        => '2',
          :try_sleep    => '30',
          :unless       => 'not true'
        }
      end
      it {
        should_not contain_exec('ruby_rake_db_setup')
      }
      it {
        should contain_ruby__bundle('ruby_rake_db_setup').with({
          'command'      => 'exec',
          'option'       => 'rake db:setup',
          'rails_env'    => 'test',
          'creates'      => '/path/to/file',
          'cwd'          => '/path/to/dir',
          'environment'  => 'test',
          'user'         => 'nobody',
          'group'        => 'anybody',
          'logoutput'    => true,
          'onlyif'       => 'confused',
          'path'         => ['/opt/app/bin','/usr/share/path'],
          'refresh'      => true,
          'refreshonly'  => true,
          'timeout'      => '300',
          'tries'        => '2',
          'try_sleep'    => '30',
          'unless'       => 'not true'
        })
      }
    end
  end
  describe 'on Amazon based systems' do
    let (:facts) do
      {
        :osfamily => 'Amazon',
      }
    end
    let :pre_condition do
      "include ruby\ninclude ruby::dev"
    end
    context 'with minimum parameters' do
      let :title do
        'db_setup'
      end
      let :params do
        {
          :task => 'db:setup'
        }
      end
      it {
        should contain_exec('ruby_rake_db_setup').with({
          'command'     => 'rake db:setup',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'require'     => 'Package[rake]'
        })
      }
    end
  end
  describe 'on Debian based systems' do
    let (:facts) do
      {
        :osfamily => 'Debian',
      }
    end
    let :pre_condition do
      "include ruby\ninclude ruby::dev"
    end
    context 'with no parameters' do
      let :title do
        'db_setup'
      end
      let :params do
        {
          :task => 'db:setup'
        }
      end
      it {
        should contain_exec('ruby_rake_db_setup').with({
          'command'     => 'rake db:setup',
          'environment' => 'RAILS_ENV=production',
          'path'        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin'],
          'require'     => 'Package[rake]'
        })
      }
    end
  end
  describe 'on an Unknown OS' do
    let :facts do
      {
        :osfamily   => 'Unknown',
      }
    end
    let :title do
      'test'
    end
    let :params do
      {
        :task => 'db:setup'
      }
    end
    it do
      expect {
        should contain_class('puppet::params')
      }.to raise_error(Puppet::Error, /Unsupported OS family: Unknown/)
    end
  end
end
