require 'spec_helper'

RSpec.describe 'chocolatey' do

  let(:facts) {
    {
      :chocolateyversion  => '0.9.9.8',
      :choco_install_path => 'C:\ProgramData\chocolatey',
    }
  }

  context 'contains install.pp' do
    it { is_expected.to contain_windows_env('chocolatey_ChocolateyInstall_env').with_ensure('present') }
    it { is_expected.to contain_windows_env('chocolatey_ChocolateyInstall_env').with_variable('ChocolateyInstall') }
    it { is_expected.to contain_windows_env('chocolatey_ChocolateyInstall_env').that_notifies('Exec[install_chocolatey_official]') }

    it { is_expected.to contain_windows_env('chocolatey_PATH_env').with_ensure('present') }
    it { is_expected.to contain_windows_env('chocolatey_PATH_env').with_variable('PATH') }
    it { is_expected.to contain_windows_env('chocolatey_PATH_env').that_notifies('Exec[install_chocolatey_official]') }

    ['c:\local_folder', "C:\\ProgramData\\chocolatey"].each do |param_value|
        context "choco_install_location => #{param_value}" do
        let(:params) {{ :choco_install_location => param_value }}

        it { is_expected.to contain_exec('install_chocolatey_official').with_creates("#{param_value}\\bin\\choco.exe") }
        it { is_expected.to contain_windows_env('chocolatey_ChocolateyInstall_env').with_value("#{param_value}") }
        it { is_expected.to contain_windows_env('chocolatey_PATH_env').with_value("#{param_value}\\bin") }
      end
    end


    [1500, 35].each do |param_value|
      context "choco_install_timeout_seconds => #{param_value}" do
        let(:params) {{ :choco_install_timeout_seconds => param_value }}

        it { is_expected.to contain_exec('install_chocolatey_official').with_timeout("#{param_value}") }
      end
    end
  end
end
