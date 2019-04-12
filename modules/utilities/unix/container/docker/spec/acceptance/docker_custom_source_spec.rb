require 'spec_helper_acceptance'

skip = false

if fact('osfamily') == 'windows'
    docker_args = 'docker_ee => true, docker_ee_source_location => "https://download.docker.com/components/engine/windows-server/17.06/docker-17.06.2-ee-14.zip"'
    default_image = 'microsoft/nanoserver'
    default_image_tag = '10.0.14393.2189'
    #The default args are set because: 
    #restart => 'always' - there is no service created to manage containers 
    #net => 'nat' - docker uses bridged by default when running a container. When installing docker on windows the default network is NAT.
    default_docker_run_arg = "restart => 'always', net => 'nat',"
    default_run_command = "ping 127.0.0.1 -t"
    docker_command = "\"/cygdrive/c/Program Files/Docker/docker\""
  skip = false
else
  skip = true
end

describe 'the Puppet Docker module' do
  context 'with download location', :skip => skip do
    let(:pp) {"
        class { 'docker': #{docker_args} }
    "}

    it 'should run successfully' do
        apply_manifest(pp, :catch_failures => true)
    end

    it 'should run idempotently' do
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'
    end

    it 'should be start a docker process' do
        if fact('osfamily') == 'windows' 
        shell('powershell Get-Process -Name dockerd') do |r|
            expect(r.stdout).to match(/ProcessName/)
        end
        else
        shell('ps aux | grep docker') do |r|
            expect(r.stdout).to match(/dockerd -H unix:\/\/\/var\/run\/docker.sock/)
        end
        end
    end

    it 'should install a working docker client' do
        shell("#{docker_command} ps", :acceptable_exit_codes => [0] )
    end

    it 'should stop a running container and remove container' do
    pp=<<-EOS
        class { 'docker': #{docker_args} }

        docker::image { '#{default_image}':
        require => Class['docker'],
        }

        docker::run { 'container_3_6':
        image   => '#{default_image}',
        command => '#{default_run_command}',
        require => Docker::Image['#{default_image}'],
        #{default_docker_run_arg}
        }
    EOS

    pp2=<<-EOS
        class { 'docker': #{docker_args} }

        docker::image { '#{default_image}':
        require => Class['docker'],
        }

        docker::run { 'container_3_6':
        ensure  => 'absent',
        image   => '#{default_image}',
        require => Docker::Image['#{default_image}'],
        }
    EOS

    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

    # A sleep to give docker time to execute properly
    sleep 15

    shell("#{docker_command} ps", :acceptable_exit_codes => [0])

    apply_manifest(pp2, :catch_failures => true)
    apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

    # A sleep to give docker time to execute properly
    sleep 15

    shell("#{docker_command} inspect container-3-6", :acceptable_exit_codes => [1])
    if fact('osfamily') == 'windows'
        shell('test -f /cygdrive/c/Windows/Temp/container-3-6.service', :acceptable_exit_codes => [1])
    else
        shell('test -f /etc/systemd/system/container-3-6.service', :acceptable_exit_codes => [1])
    end
  end
end
end