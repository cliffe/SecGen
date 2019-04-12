require 'spec_helper'

describe 'filebeat::repo' do
  on_supported_os(facterversion: '2.4').each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { "class { 'filebeat': major_version => '#{major_version}' }" }

      [5, 6].each do |version|
        context "with $major_version == #{version}" do
          let(:major_version) { version }

          case os_facts[:kernel]
          when 'Linux'
            it { is_expected.to compile } unless os_facts[:os]['family'] == 'Archlinux'
            case os_facts[:osfamily]
            when 'Debian'
              it {
                is_expected.to contain_apt__source('beats').with(
                  ensure: 'present',
                  location: "https://artifacts.elastic.co/packages/#{major_version}.x/apt",
                )
              }
            when 'RedHat'
              it {
                is_expected.to contain_yumrepo('beats').with(
                  ensure: 'present',
                  baseurl: "https://artifacts.elastic.co/packages/#{major_version}.x/yum",
                )
              }
            end
          else
            it { is_expected.not_to compile }
          end
        end
      end
    end
  end
end
