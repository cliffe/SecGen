require 'spec_helper'

describe 'filebeat::prospector' do
  let :pre_condition do
    'class { "filebeat":
        outputs => {
          "logstash" => {
            "hosts" => [
              "localhost:5044",
            ],
          },
        },
      }'
  end

  let(:title) { 'test-logs' }
  let(:params) do
    {
      'paths' => [
        '/var/log/auth.log',
        '/var/log/syslog',
      ],
      'doc_type' => 'syslog-beat',
    }
  end

  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      if os_facts[:kernel] != 'windows'
        it { is_expected.to compile }
      end

      it {
        is_expected.to contain_file('filebeat-test-logs').with(
          notify: 'Service[filebeat]',
        )
      }
    end
  end

  context 'with no parameters' do
    it { is_expected.to raise_error(Puppet::Error) }
  end
end
