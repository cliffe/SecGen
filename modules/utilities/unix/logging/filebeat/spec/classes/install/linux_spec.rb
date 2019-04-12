require 'spec_helper'

describe 'filebeat::install::linux' do
  let :pre_condition do
    'include ::filebeat'
  end

  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      case os_facts[:kernel]
      when 'Linux'
        it { is_expected.to compile }
        it { is_expected.to contain_package('filebeat').with_ensure('present') }
      else
        it { is_expected.not_to compile }
      end
    end
  end
end
