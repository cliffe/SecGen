require 'spec_helper'

describe 'filebeat::install' do
  let :pre_condition do
    'include ::filebeat'
  end

  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if os_facts[:kernel] != 'windows'
        it { is_expected.to compile }
      end

      it { is_expected.to contain_anchor('filebeat::install::begin') }
      it { is_expected.to contain_anchor('filebeat::install::end') }

      case os_facts[:kernel]
      when 'Linux'
        it { is_expected.to contain_class('filebeat::install::linux') }
        it { is_expected.to contain_class('filebeat::repo') } unless os_facts[:os]['family'] == 'Archlinux'
        it { is_expected.not_to contain_class('filebeat::install::windows') }

      when 'Windows'
        it { is_expected.to contain_class('filebeat::install::windows') }
        it { is_expected.not_to contain_class('filebeat::install::linux') }
      end
    end
  end
end
