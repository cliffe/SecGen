require 'spec_helper'

describe '::accounts::user' do
  let(:title) { "dan" }
  let(:params) { {} }
  let(:facts) { {} }

  describe 'expected defaults' do
    let(:facts) { { :osfamily => "Debian" } }
    it { is_expected.to contain_user('dan').with({'shell'      => '/bin/bash'}) }
    it { is_expected.to contain_user('dan').with({'home'       => "/home/#{title}"}) }
    it { is_expected.to contain_user('dan').with({'ensure'     => 'present'}) }
    it { is_expected.to contain_user('dan').with({'comment'    => title}) }
    it { is_expected.to contain_user('dan').with({'groups'     => []}) }
    it { is_expected.to contain_user('dan').with({'managehome' => true }) }
    it { is_expected.to contain_group('dan').with({'ensure'    => 'present'}) }
    it { is_expected.to contain_group('dan').with({'gid'       => nil}) }
  end

  describe 'expected home defaults' do
    context 'normal user on linux' do
      let(:title) { "dan" }
      let(:facts) { { :osfamily => "Debian" } }
      it { is_expected.to contain_user('dan').with_home('/home/dan') }
    end
    context 'root user on linux' do
      let(:title) { "root" }
      let(:facts) { { :osfamily => "Debian" } }
      it { is_expected.to contain_user('root').with_home('/root') }
    end
    context 'normal user on Solaris' do
      let(:title) { "dan" }
      let(:facts) { { :osfamily => "Solaris" } }
      it { is_expected.to contain_user('dan').with_home('/export/home/dan') }
    end
    context 'root user on Solaris' do
      let(:title) { "root" }
      let(:facts) { { :osfamily => "Solaris" } }
      it { is_expected.to contain_user('root').with_home('/') }
    end
  end

  describe 'when setting user parameters' do
    before do
      params['ensure']     = 'present'
      params['shell']      = '/bin/csh'
      params['comment']    = 'comment'
      params['home']       = '/var/home/dan'
      params['home_mode']  = '0755'
      params['uid']        = '123'
      params['gid']        = '456'
      params['groups']     = ['admin']
      params['membership'] = 'inclusive'
      params['password']   = 'foo'
      params['sshkeys']    = ['1 2 3', '2 3 4']
    end

    it { is_expected.to contain_user('dan').with({'ensure' => 'present'}) }
    it { is_expected.to contain_user('dan').with({'shell' => '/bin/csh'}) }
    it { is_expected.to contain_user('dan').with({'comment' => 'comment'}) }
    it { is_expected.to contain_user('dan').with({'home' => '/var/home/dan'}) }
    it { is_expected.to contain_user('dan').with({'uid' => '123'}) }
    it { is_expected.to contain_user('dan').with({'gid' => '456'}) }
    it { is_expected.to contain_user('dan').with({'groups' => ['admin']}) }
    it { is_expected.to contain_user('dan').with({'membership' => 'inclusive'}) }
    it { is_expected.to contain_user('dan').with({'password' => 'foo'}) }
    it { is_expected.to contain_group('dan').with({'ensure' => 'present'}) }
    it { is_expected.to contain_group('dan').with({'gid' => '456'}) }
    it { is_expected.to contain_group('dan').that_comes_before('User[dan]') }
    it { is_expected.to contain_accounts__home_dir('/var/home/dan').with({'user' => title}) }
    it { is_expected.to contain_accounts__home_dir('/var/home/dan').with({'mode' => '0755'}) }
    it { is_expected.to contain_accounts__home_dir('/var/home/dan').with({'sshkeys' => ['1 2 3', '2 3 4']}) }
    it { is_expected.to contain_file('/var/home/dan/.ssh') }

    describe 'when setting the user to absent' do

      # when deleting users the home dir is a File resource instead of a accounts::home_dir
      let(:contain_home_dir) { contain_file('/var/home/dan') }

      before do
        params['ensure'] = 'absent'
      end

      it { is_expected.to contain_user('dan').with({'ensure' => 'absent'}) }
      it { is_expected.to contain_user('dan').that_comes_before('Group[dan]') }
      it { is_expected.to contain_group('dan').with({'ensure' => 'absent'}) }
      it do
        is_expected.to_not contain_accounts__home_dir('/var/home/dan').with({
          'ensure' => 'absent',
          'recurse' => true,
          'force' => true
        })
      end

      describe 'with managehome off' do

        before do
          params['managehome'] = false
        end

        it { is_expected.not_to contain_home_dir }
        it { is_expected.not_to contain_file('/var/home/dan/.ssh') }
      end
    end
  end

  describe 'invalid parameter values' do
    it 'should only accept absent and present for ensure' do
      params['ensure'] = 'invalid'
      expect { subject.call }.to raise_error Puppet::Error
    end
    it 'should fail if locked is not a boolean' do
      params['locked'] = 'true'
      expect { subject.call }.to raise_error Puppet::Error
    end
    ['home', 'shell'].each do |param|
      it "should fail is #{param} does not start with '/'" do
        params[param] = 'no_leading_slash'
        expect { subject.call }.to raise_error Puppet::Error
      end
    end
    it 'should fail if gid is not composed of digits' do
      params['gid'] = 'name'
      expect { subject.call }.to raise_error Puppet::Error
    end
    it 'should not accept non-boolean values for locked' do
      params['locked'] = 'false'
      expect { subject.call }.to raise_error Puppet::Error
    end
    it 'should not accept non-boolean values for managehome' do
      params['managehome'] = 'false'
      expect { subject.call }.to raise_error Puppet::Error
    end
  end

  describe 'when locking users' do

    let(:params) { { 'locked' => true } }

    describe 'on debian' do
      before { facts['operatingsystem'] = 'debian' }
      before { facts['osfamily'] = 'Debian' }
      it { is_expected.to contain_user('dan').with({'shell' => '/usr/sbin/nologin'}) }
    end

    describe 'on ubuntu' do
      before { facts['operatingsystem'] = 'ubuntu' }
      before { facts['osfamily'] = 'Ubuntu' }
      it { is_expected.to contain_user('dan').with({'shell' => '/usr/sbin/nologin'}) }
    end

    describe 'on solaris' do
      before { facts['operatingsystem'] = 'solaris' }
      before { facts['osfamily'] = 'Solaris' }
      it { is_expected.to contain_user('dan').with({'shell' => '/usr/bin/false'}) }
    end

    describe 'on all other platforms' do
      before { facts['operatingsystem'] = 'anything_else' }
      before { facts['osfamily'] = 'anything_else' }
      it { is_expected.to contain_user('dan').with({'shell' => '/sbin/nologin'}) }
    end
  end

  describe 'when supplying resource defaults' do
    before do
      facts['osfamily'] = 'Debian'
      facts['operatingsystem'] = 'debian'
    end

    let(:pre_condition) { "Accounts::User{ shell => '/bin/zsh' }" }

    it { is_expected.to contain_user('dan').with({'shell' => '/bin/zsh'}) }

    describe 'override defaults' do
      let(:params) { { 'shell' => '/bin/csh' } }
      it { is_expected.to contain_user('dan').with({'shell' => '/bin/csh'}) }
    end

    describe 'locked overrides should override defaults and user params' do
      let(:params) { { 'shell' => '/bin/csh', 'locked' => true} }
      it { is_expected.to contain_user('dan').with({'shell' => '/usr/sbin/nologin'}) }
    end
  end
end
