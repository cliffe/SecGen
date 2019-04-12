require 'spec_helper'

describe 'filebeat' do
  let :pre_condition do
    'include ::filebeat'
  end

  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if os_facts[:kernel] != 'windows'
        it { is_expected.to compile }
      end

      it { is_expected.to contain_class('filebeat') }
      it { is_expected.to contain_class('filebeat::params') }
      it { is_expected.to contain_anchor('filebeat::begin') }
      it { is_expected.to contain_anchor('filebeat::end') }
      it { is_expected.to contain_class('filebeat::install') }
      it { is_expected.to contain_class('filebeat::config') }
      it { is_expected.to contain_class('filebeat::service') }
    end
  end
end
