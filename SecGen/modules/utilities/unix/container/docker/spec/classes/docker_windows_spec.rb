require 'spec_helper'

describe 'docker', :type => :class do
    osfamily = "windows"
    context "on #{osfamily}" do
      let(:facts) { {
          :architecture              => 'amd64',
          :osfamily                  => 'windows',
          :operatingsystem           => 'windows',
          :kernelrelease             => '10.0.14393',
          :operatingsystemrelease    => '2016',
          :operatingsystemmajrelease => '2016',
          :os                        => { :family => 'windows', :name => 'windows', :release => { :major => '2016', :full => '2016' } }
        } }
      service_config_file = 'C:/ProgramData/docker/config/daemon.json'
      let(:params) {{ 'docker_ee' => true }}

      it { should compile.with_all_deps }
      it { should contain_file('C:/ProgramData/docker/').with({
          'ensure' => 'directory'
      } ) }
      it { should contain_file('C:/ProgramData/docker/config/')}
      it { should contain_exec('service-restart-on-failure') }
      it { should contain_exec('install-docker-package').with_command(/Install-PackageProvider NuGet -Force/) }
      it { should contain_exec('install-docker-package').with_command(/Install-Module \$dockerProviderName -Force/) }
      it { should contain_class('docker::repos').that_comes_before('Class[docker::install]') }
      it { should contain_class('docker::install').that_comes_before('Class[docker::config]') }
      it { should contain_class('docker::config').that_comes_before('Class[docker::service]') }

      it { should contain_file(service_config_file).without_content(/icc=/) }
      
      context 'with dns' do
        let(:params) { { 
            'dns' => '8.8.8.8',
            'docker_ee' => true
        } }
        it { should contain_file(service_config_file).with_content(/"dns": \["8.8.8.8"\],/) }
      end

      context 'with multi dns' do
        let(:params) { { 
            'dns' => ['8.8.8.8', '8.8.4.4'],
            'docker_ee' => true
        } }
        it { should contain_file(service_config_file).with_content(/"dns": \["8.8.8.8","8.8.4.4"\],/) }
      end

      context 'with dns search' do
        let(:params) { { 
            'dns_search' => ['my.domain.local'],
            'docker_ee' => true
        } }
        it { should contain_file(service_config_file).with_content(/"dns-search": \["my.domain.local"\],/) }
      end

      context 'with multi dns search' do
        let(:params) { { 
            'dns_search' => ['my.domain.local', 'other-domain.de'],
            'docker_ee' => true
        } }
        it { should contain_file(service_config_file).with_content(/"dns-search": \["my.domain.local","other-domain.de"\],/) }
      end

      context 'with log_driver' do
        let(:params) { { 
            'log_driver' => 'etwlogs',
            'docker_ee'  => true
        } }
        it { should contain_file(service_config_file).with_content(/"log-driver": "etwlogs"/) }
      end

      context 'with invalid log_driver' do
        let(:params) { { 
            'log_driver' => 'invalid',
            'docker_ee'  => true
        } }
        it do
            expect {
              should contain_package('docker')
            }.to raise_error(Puppet::Error, /log_driver must be one of none, json-file, syslog, gelf, fluentd, splunk or etwlogs/)
        end
      end

      context 'with invalid journald log_driver' do
        let(:params) { { 
            'log_driver' => 'journald',
            'docker_ee'  => true
        } }
        it do
            expect {
              should contain_package('docker')
            }.to raise_error(Puppet::Error, /log_driver must be one of none, json-file, syslog, gelf, fluentd, splunk or etwlogs/)
        end
      end

      context 'with mtu' do
        let(:params) { { 
            'mtu' => '1450',
            'docker_ee'  => true
        } }
        it { should contain_file(service_config_file).with_content(/"mtu": 1450/) }
      end

      context 'with log_level' do
        let(:params) { { 
            'log_level' => 'debug',
            'docker_ee'  => true
        } }
        it { should contain_file(service_config_file).with_content(/"log-level": "debug"/) }
      end

      context 'with invalid log_level' do
        let(:params) { { 
            'log_level' => 'verbose',
            'docker_ee'  => true
        } }
        it do
            expect {
              should contain_package('docker')
            }.to raise_error(Puppet::Error, /log_level must be one of debug, info, warn, error or fatal/)
        end
      end

      context 'with storage_driver' do
        let(:params) { {
            'storage_driver' => 'windowsfilter',
            'docker_ee' => true 
        } }
        it { should compile.with_all_deps }
      end
      
      context 'with an invalid storage_driver' do
        let(:params) { {
            'storage_driver' => 'invalid',
            'docker_ee' => true 
        } }
        it do
            expect {
              should contain_package('docker')
            }.to raise_error(Puppet::Error, /Valid values for storage_driver on windows are windowsfilter/)
        end
      end

      context 'with tcp_bind' do
        let(:params) { { 
            'tcp_bind'   => "tcp://0.0.0.0:2376",
            'docker_ee'  => true
        } }
        it { should contain_file(service_config_file).with_content(/"hosts": \["tcp:\/\/0.0.0.0:2376"\]/) }
      end

      context 'with multiple tcp_bind' do
        let(:params) { { 
            'tcp_bind'   => ["tcp://0.0.0.0:2376", "npipe://"],
            'docker_ee'  => true
        } }
        it { should contain_file(service_config_file).with_content(/"hosts": \["tcp:\/\/0.0.0.0:2376","npipe:\/\/"\]/) }
      end

      context 'with tls_enable, tcp_bind and tls configuration' do
        let(:params) { { 
            'tls_enable' => true,
            'tcp_bind'   => ["tcp://0.0.0.0:2376"],
            'docker_ee'  => true
        } }
        it { should contain_file(service_config_file).with_content(
            /"hosts": \["tcp:\/\/0.0.0.0:2376"]/).with_content(
                /"tlsverify": true/).with_content(
                    /"tlscacert": "C:\/ProgramData\/docker\/certs.d\/ca.pem"/).with_content(
                        /"tlscert": "C:\/ProgramData\/docker\/certs.d\/server-cert.pem"/).with_content(
                            /"tlskey": "C:\/ProgramData\/docker\/certs.d\/server-key.pem"/)
            }
      end

      context 'with tls_enable, tcp_bind and custom tls cacert' do
        let(:params) { { 
            'tls_enable' => true,
            'tcp_bind'   => ["tcp://0.0.0.0:2376"],
            'tls_cacert' => 'C:/certs/ca.pem',
            'docker_ee'  => true
        } }
        it { should contain_file(service_config_file).with_content(
                    /"tlscacert": "C:\/certs\/ca.pem"/)
            }
      end

      context 'with tls_enable, tcp_bind and custom tls cert' do
        let(:params) { { 
            'tls_enable' => true,
            'tcp_bind'   => ["tcp://0.0.0.0:2376"],
            'tls_cert'   => 'C:/certs/server-cert.pem',
            'docker_ee'  => true
        } }
        it { should contain_file(service_config_file).with_content(
                    /"tlscert": "C:\/certs\/server-cert.pem"/)
            }
      end

      context 'with tls_enable, tcp_bind and custom tls key' do
        let(:params) { { 
            'tls_enable' => true,
            'tcp_bind'   => ["tcp://0.0.0.0:2376"],
            'tls_key'   => 'C:/certs/server-key.pem',
            'docker_ee'  => true
        } }
        it { should contain_file(service_config_file).with_content(
                    /"tlskey": "C:\/certs\/server-key.pem"/)
            }
      end

      context 'with custom socket group' do
        let(:params) { { 
            'socket_group' => "custom",
            'docker_ee'    => true
        } }
        it { should contain_file(service_config_file).with_content(/"group": "custom"/)}
      end

      context 'with custom bridge' do
        let(:params) { { 
            'bridge'    => "l2bridge",
            'docker_ee' => true
        } }
        it { should contain_file(service_config_file).with_content(/"bridge": "l2bridge"/)}
      end

      context 'with invalid bridge' do
        let(:params) { { 
            'bridge'    => "invalid",
            'docker_ee' => true
        } }
        it do
            expect {
              should contain_package('docker')
            }.to raise_error(Puppet::Error, /bridge must be one of none, nat, transparent, overlay, l2bridge or l2tunnel on Windows./)
        end
      end

      context 'with custom fixed cidr' do
        let(:params) { { 
            'fixed_cidr'=> "10.0.0.0/24",
            'docker_ee' => true
        } }
        it { should contain_file(service_config_file).with_content(/"fixed-cidr": "10.0.0.0\/24"/)}
      end

      context 'with custom registry mirror' do
        let(:params) { { 
            'registry_mirror'=> "https://mirror.gcr.io",
            'docker_ee' => true
        } }
        it { should contain_file(service_config_file).with_content(/"registry-mirrors": \["https:\/\/mirror.gcr.io"\]/)}
      end

      context 'with custom label' do
        let(:params) { { 
            'labels'=> ["mylabel"],
            'docker_ee' => true
        } }
        it { should contain_file(service_config_file).with_content(/"labels": \["mylabel"\]/)}
      end

      context 'with default package name' do
        let(:params) { { 
            'docker_ee' => true
        } }
        it { should contain_exec('install-docker-package').with_command(/ Docker /) }
      end

      context 'with custom package name' do
        let(:params) { { 
            'docker_ee_package_name'=> "mydockerpackage",
            'docker_ee' => true
        } }
        it { should contain_exec('install-docker-package').with_command(/ mydockerpackage /) }
      end

      context 'without docker_ee' do
        let(:params) {{ 'docker_ee' => false }}
        it do
            expect {
              should contain_package('docker')
            }.to raise_error(Puppet::Error, /This module only work for Docker Enterprise Edition on Windows./)
        end
      end
    end
end
