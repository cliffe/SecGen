require 'spec_helper'

describe 'docker::systemd_reload', :type => :class do

  let(:facts) { {
    :osfamily               => 'Debian',
    :operatingsystem        => 'Debian',
    :lsbdistid              => 'Debian',
    :lsbdistcodename        => 'stretch',
    :kernelrelease          => '9.3.0-amd64',
    :operatingsystemrelease => '9.3',
    :operatingsystemmajrelease => '9',
  } }

  context 'with systems that have systemd' do
    it { should contain_exec('docker-systemd-reload').with(
    'path'       => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    'command'     => 'systemctl daemon-reload',
    'refreshonly' => 'true'
    ) }
  end
end