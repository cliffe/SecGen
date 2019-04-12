require 'spec_helper_acceptance'

RSpec.shared_examples 'filebeat' do
  describe package('filebeat') do
    it { is_expected.to be_installed }
  end

  describe service('filebeat') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe file('/etc/filebeat/filebeat.yml') do
    it { is_expected.to be_file }
    it { is_expected.to contain('---') }
    it { is_expected.not_to contain('max_procs: !ruby') }
  end
end

describe 'filebeat class' do
  let(:pp) do
    <<-HEREDOC
    if $::osfamily == 'Debian' {
      include ::apt

      package { 'apt-transport-https':
        ensure => present,
      }
    }

    class { 'filebeat':
      major_version => '#{major_version}',
      outputs => {
        'logstash' => {
          'bulk_max_size' => 1024,
          'hosts' => [
            'localhost:5044',
          ],
        },
        'file'     => {
          'path' => '/tmp',
          'filename' => 'filebeat',
          'rotate_every_kb' => 10240,
          'number_of_files' => 2,
        },
      },
      shipper => {
        refresh_topology_freq => 10,
        topology_expire => 15,
        queue_size => 1000,
      },
      logging => {
        files => {
          rotateeverybytes => 10485760,
          keepfiles => 7,
        }
      },
      prospectors => {
        'system-logs' => {
          doc_type => 'system',
          paths    => [
            '/var/log/dmesg',
          ],
          fields   => {
            service => 'system',
            file    => 'dmesg',
          },
          tags     => [
            'tag1',
            'tag2',
            'tag3',
          ]
        }
      }
    }
    HEREDOC
  end

  context 'with $major_version = 5' do
    let(:major_version) { 5 }

    it_behaves_like 'an idempotent resource'
    include_examples 'filebeat'
  end

  context 'with $major_version = 6' do
    let(:major_version) { 6 }

    it_behaves_like 'an idempotent resource'
    include_examples 'filebeat'
  end
end
