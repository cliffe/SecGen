require 'spec_helper'

describe 'cron::install' do
  let(:pre_condition) do
    'include ::cron'
  end

  context 'default' do
    let :facts do
      {
        operatingsystem: 'Unsupported'
      }
    end

    it do
      is_expected.to contain_package('cron').with('ensure' => 'installed', 'name' => 'cron')
    end
  end

  context 'CentOS 5' do
    let :facts do
      {
        os: {
          family: 'RedHat',
          release: {
            major: '5'
          }
        }
      }
    end

    it { is_expected.to contain_class('cron::install') }
    it {
      is_expected.to contain_package('cron').with(
        'name' => 'vixie-cron'
      )
    }
  end

  context 'CentOS 6' do
    let :facts do
      {
        os: {
          family: 'RedHat',
          release: {
            major: '6'
          }
        }
      }
    end

    it { is_expected.to contain_class('cron::install') }
    it {
      is_expected.to contain_package('cron').with(
        'name' => 'cronie'
      )
    }
  end

  context 'Gentoo' do
    let :facts do
      {
        os: { family: 'Gentoo' }
      }
    end

    it { is_expected.to contain_class('cron::install') }
    it {
      is_expected.to contain_package('cron').with(
        'name' => 'virtual/cron'
      )
    }
  end

  context 'Debian' do
    let :facts do
      {
        os: { family: 'debian' }
      }
    end

    it { is_expected.to contain_class('cron::install') }
    it {
      is_expected.to contain_package('cron').with(
        'name' => 'cron'
      )
    }
  end
end
