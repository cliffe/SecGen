require 'spec_helper_acceptance'

if fact('osfamily') == 'windows'
  install_dir = '/cygdrive/c/Program Files/Docker'
  file_extension = '.exe'
  docker_args = 'docker_ee => true'
  tmp_path = 'C:/cygwin64/tmp'
  test_docker_image = 'hello-world:nanoserver'
  test_docker_command = 'cmd.exe /C "ping /t 8.8.8.8"'
else
  install_dir = '/usr/local/bin'
  file_extension = ''
  docker_args = ''
  tmp_path = '/tmp'
  test_docker_image = 'ubuntu:16.04'
  test_docker_command = '/bin/sh -c "while true; do echo hello world; sleep 1; done"'
end

skip_tests = false

begin
  swarm_manager = only_host_with_role(hosts, 'swarm-manager')
  swarm_worker = only_host_with_role(hosts, 'swarm-worker')
  manager_ip = swarm_manager.ip
rescue ArgumentError
  skip_tests = true
end

describe 'docker swarm', :skip => skip_tests do
  before(:all) do
    retry_on_error_matching(60, 5, /connection failure running/) do
      @install_code = <<-code
        class { 'docker': #{docker_args} }
      code
      apply_manifest_on(swarm_manager, @install_code, :catch_failures=>true)
    end
    retry_on_error_matching(60, 5, /connection failure running/) do
      apply_manifest_on(swarm_worker, @install_code, :catch_failures=>true)
    end
  end

  context 'Creating a swarm master' do
    before(:all) do
      @setup_manager = <<-code
      docker::swarm {'cluster_manager':
        init           => true,
        advertise_addr => '#{manager_ip}',
        listen_addr    => '#{manager_ip}',
      ensure => 'present',
      }
      code

      retry_on_error_matching(60, 5, /connection failure running/) do
        apply_manifest_on(swarm_manager, @setup_manager, :catch_failures=>true)
      end

      if fact('osfamily') == 'windows'
        on swarm_manager, 'netsh advfirewall firewall add rule name="Swarm mgmgt" dir=in action=allow protocol=TCP localport=2377', :acceptable_exit_codes => [0]
        on swarm_manager, 'netsh advfirewall firewall add rule name="Swarm comm tcp" dir=in action=allow protocol=TCP localport=7946', :acceptable_exit_codes => [0]
        on swarm_manager, 'netsh advfirewall firewall add rule name="Swarm comm udp" dir=in action=allow protocol=UDP localport=7946', :acceptable_exit_codes => [0]
        on swarm_manager, 'netsh advfirewall firewall add rule name="Swarm network" dir=in action=allow protocol=UDP localport=4789', :acceptable_exit_codes => [0]
      end
    end

    it 'should be idempotent' do
      apply_manifest_on(swarm_manager, @setup_manager, :catch_failures=>true)
    end

    it 'should display nodes' do
      on swarm_manager, 'docker node ls', :acceptable_exit_codes => [0] do |result|
        expect(result.stdout).to match(/Leader/)
      end
    end

    it 'should join a node' do
      token = shell('docker swarm join-token -q worker').stdout.strip
      @setup_slave = <<-code
      docker::swarm {'cluster_worker':
        join           => true,
        advertise_addr => '#{swarm_worker.ip}',
        listen_addr    => '#{swarm_worker.ip}',
        manager_ip     => '#{manager_ip}',
        token          => '#{token}',
        }
      code
      retry_on_error_matching(60, 5, /connection failure running/) do
        apply_manifest_on(swarm_worker, @setup_slave, :catch_failures=>true)
      end

      retry_on_error_matching(60, 5, /connection failure running/) do
        on swarm_worker, 'docker info' do |result|
          expect(result.stdout).to match(/Swarm: active/)
        end
      end

      if fact('osfamily') == 'windows'
        on swarm_worker, 'netsh advfirewall firewall add rule name="Swarm mgmgt" dir=in action=allow protocol=TCP localport=2377', :acceptable_exit_codes => [0]
        on swarm_worker, 'netsh advfirewall firewall add rule name="Swarm comm tcp" dir=in action=allow protocol=TCP localport=7946', :acceptable_exit_codes => [0]
        on swarm_worker, 'netsh advfirewall firewall add rule name="Swarm comm udp" dir=in action=allow protocol=UDP localport=7946', :acceptable_exit_codes => [0]
        on swarm_worker, 'netsh advfirewall firewall add rule name="Swarm network" dir=in action=allow protocol=UDP localport=4789', :acceptable_exit_codes => [0]
      end
    end

    it 'should start a container' do
      @start_service = <<-code
      docker::services {'helloworld':
        create         => true,
        service_name   => 'helloworld',
        image          => '#{test_docker_image}',
        extra_params   => ['--endpoint-mode dnsrr'],
        command        => '#{test_docker_command}',
        replicas       => '2',
        }
      code

      apply_manifest_on(swarm_manager, @start_service, :catch_failures=>true)
      
      #on swarm_manager, "docker service create --name=helloworld --endpoint-mode dnsrr --network=swarmnet #{test_docker_image} #{test_docker_command}", :acceptable_exit_codes => [0]
      on swarm_manager, 'docker service ps helloworld', :acceptable_exit_codes => [0] do |result|
        expect(result.stdout).to match(/Running/)
      end
    end

    after(:all) do
      remove_worker = <<-code
      docker::swarm {'cluster_worker':
        ensure => 'absent',
      }
      code
      retry_on_error_matching(60, 5, /connection failure running/) do
        apply_manifest_on(swarm_worker, remove_worker, :catch_failures=>true)
      end
      remove_mgr = <<-code
      docker::swarm {'cluster_manager':
        ensure => 'absent',
      }
      code
      retry_on_error_matching(60, 5, /connection failure running/) do
        apply_manifest_on(swarm_manager, remove_mgr, :catch_failures=>true)
      end
    end
  end
end