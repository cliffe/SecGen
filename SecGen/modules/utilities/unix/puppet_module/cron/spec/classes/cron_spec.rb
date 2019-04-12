require 'spec_helper'

describe 'cron' do
  context 'default' do
    let :facts do
      {
        operatingsystem: 'Unsupported'
      }
    end

    it { is_expected.to contain_class('cron::install') }
  end

  context 'manage_package => false' do
    let :facts do
      {
        operatingsystem: 'Unsupported'
      }
    end
    let(:params) do
      { manage_package: false,
        package_ensure: 'cron' }
    end

    it { is_expected.to contain_class('cron::install') }
    it { is_expected.not_to contain_package('cron') }
  end

  context 'manage_package => true' do
    let :facts do
      {
        operatingsystem: 'Unsupported'
      }
    end
    let(:params) do
      { manage_package: true,
        package_ensure: 'installed' }
    end

    it { is_expected.to contain_class('cron::install') }
    it { is_expected.to contain_package('cron') }
  end

  context 'package_ensure => absent' do
    let :facts do
      {
        operatingsystem: 'Unsupported'
      }
    end
    let(:params) do
      { manage_package: true,
        package_ensure: 'absent' }
    end

    it { is_expected.to contain_class('cron::install') }
    it {
      is_expected.to contain_package('cron').with(
        'name'   => 'cron',
        'ensure' => 'absent'
      )
    }
  end

  context 'package_name => sys-process/cronie' do
    let :facts do
      {
        operatingsystem: 'Gentoo'
      }
    end
    let(:params) { { package_name: 'sys-process/cronie' } }

    it { is_expected.to contain_class('cron::install') }
    it {
      is_expected.to contain_package('cron').with(
        'name'   => 'sys-process/cronie',
        'ensure' => 'installed'
      )
    }
  end

  context 'manage_service => false' do
    let :facts do
      {
        operatingsystem: 'Unsupported'
      }
    end
    let(:params) { { manage_service: false } }

    it { is_expected.to contain_class('cron::service') }
    it { is_expected.not_to contain_service('cron') }
  end

  context 'manage_service => true' do
    let :facts do
      {
        operatingsystem: 'Unsupported'
      }
    end
    let(:params) { { manage_service: true } }

    it { is_expected.to contain_class('cron::service') }
    it { is_expected.to contain_service('cron') }
  end

  context 'service_ensure => stopped' do
    let :facts do
      {
        operatingsystem: 'Unsupported'
      }
    end
    let(:params) do
      { manage_service: true,
        service_ensure: 'stopped' }
    end

    it { is_expected.to contain_class('cron::service') }
    it {
      is_expected.to contain_service('cron').with(
        'name'   => 'cron',
        'ensure' => 'stopped',
        'enable' => true
      )
    }
  end

  context 'service_ensure => stopped' do
    let :facts do
      {
        operatingsystem: 'Unsupported'
      }
    end
    let(:params) do
      { manage_service: true,
        service_ensure: 'stopped',
        service_enable: false }
    end

    it { is_expected.to contain_class('cron::service') }
    it {
      is_expected.to contain_service('cron').with(
        'name'   => 'cron',
        'ensure' => 'stopped',
        'enable' => false
      )
    }
  end
end
