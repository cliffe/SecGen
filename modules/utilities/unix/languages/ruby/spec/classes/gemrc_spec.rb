# Only testing on RedHat because the outcome is the same on Debian.
require 'spec_helper'
describe 'ruby::gemrc', :type => :class do
  describe 'when called with no parameters' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    it {
      should contain_file('gemrc').with({
        'ensure' => 'absent',
      })
    }
  end

  describe 'when called setting verbose parameter' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :verbose => ':really' } }
    it {
      should contain_file('gemrc').with({
        'ensure'  => 'file',
        'path'    => '/etc/gemrc'
      })
    }
    it {
      should contain_file('gemrc').with_content(/^:verbose: :really$/)
    }
  end

  describe 'when called setting sources parameter' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :sources => [ 'https://rubygems.org', 'https://ourgems.org' ] } }
    it {
      should contain_file('gemrc').with({
        'ensure'  => 'file',
        'path'    => '/etc/gemrc'
      })
    }
    it {
      should contain_file('gemrc').with_content(/:sources:\n\s{2}-\shttps:\/\/rubygems.org\n\s{2}-\shttps:\/\/ourgems.org/)
    }
  end

  describe 'when called setting update_sources parameter' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :update_sources => false } }
    it {
      should contain_file('gemrc').with({
        'ensure'  => 'file',
        'path'    => '/etc/gemrc'
      })
    }
    it {
      should contain_file('gemrc').with_content(/^:update_sources: false$/)
    }
  end

  describe 'when called setting backtrace parameter' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :backtrace => true } }
    it {
      should contain_file('gemrc').with({
        'ensure'  => 'file',
        'path'    => '/etc/gemrc'
      })
    }
    it {
      should contain_file('gemrc').with_content(/^:backtrace: true$/)
    }
  end

  describe 'when called setting gempath parameter' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :gempath => [ '/usr/local/share/gems', '/var/lib/gems' ] } }
    it {
      should contain_file('gemrc').with({
        'ensure'  => 'file',
        'path'    => '/etc/gemrc'
      })
    }
    it {
      should contain_file('gemrc').with_content(%r{^:gempath: /usr/local/share/gems:/var/lib/gems$})
    }
  end

  describe 'when called setting disable_default_gem_server parameter' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :disable_default_gem_server => true } }
    it {
      should contain_file('gemrc').with({
        'ensure'  => 'file',
        'path'    => '/etc/gemrc'
      })
    }
    it {
      should contain_file('gemrc').with_content(%r{^:disable_default_gem_server: true$})
    }
  end

  describe 'when called setting gem_command parameter' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :gem_command => { 'push' => [ 'host=https://gemshost.internal', 'quiet' ]} } }
    it {
      should contain_file('gemrc').with({
        'ensure'  => 'file',
        'path'    => '/etc/gemrc'
      })
    }
    it {
      should contain_file('gemrc').with_content(%r{^push: --host=https:..gemshost.internal --quiet$})
    }
  end

end
