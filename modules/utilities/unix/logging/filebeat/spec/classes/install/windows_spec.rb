require 'spec_helper'

describe 'filebeat::install::windows' do
  let :pre_condition do
    'include ::filebeat'
  end

  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      case os_facts[:kernel]
      when 'windows'
        # it { is_expected.to compile }
        it { is_expected.to contain_file('C:/Program Files').with_ensure('directory') }
        it {
          is_expected.to contain_archive('C:/Windows/Temp/filebeat-5.6.2-windows-x86_64.zip').with(
            creates: 'C:/Program Files/Filebeat/filebeat-5.6.2-windows-x86_64',
          )
        }
        it {
          is_expected.to contain_exec('install filebeat-5.6.2-windows-x86_64').with(
            command: './install-service-filebeat.ps1',
          )
        }
        it {
          is_expected.to contain_exec('unzip filebeat-5.6.2-windows-x86_64').with(
            command: '$sh=New-Object -COM Shell.Application;$sh.namespace((Convert-Path \'C:/Program Files\')).'\
                     'Copyhere($sh.namespace((Convert-Path \'C:/Windows/Temp/filebeat-5.6.2-windows-x86_64.zip\')).items(), 16)',
          )
        }
        it {
          is_expected.to contain_exec('mark filebeat-5.6.2-windows-x86_64').with(
            command: 'New-Item \'C:/Program Files/Filebeat/filebeat-5.6.2-windows-x86_64\' -ItemType file',
          )
        }
        it {
          is_expected.to contain_exec('rename filebeat-5.6.2-windows-x86_64').with(
            command: 'Remove-Item \'C:/Program Files/Filebeat\' -Recurse -Force -ErrorAction SilentlyContinue;'\
                     'Rename-Item \'C:/Program Files/filebeat-5.6.2-windows-x86_64\' \'C:/Program Files/Filebeat\'',
          )
        }
        it {
          is_expected.to contain_exec('stop service filebeat-5.6.2-windows-x86_64').with(
            command: 'Set-Service -Name filebeat -Status Stopped',
          )
        }
        it {
          is_expected.to contain_file('C:/Windows/Temp/filebeat-5.6.2-windows-x86_64.zip').with(
            ensure: 'absent',
          )
        }

      else
        it { is_expected.not_to compile }
      end
    end
  end
end
