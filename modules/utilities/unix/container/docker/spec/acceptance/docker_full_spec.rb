require 'spec_helper_acceptance'

if fact('osfamily') == 'windows'
  docker_args = 'docker_ee => true'
  default_image = 'microsoft/nanoserver'
  default_image_tag = '10.0.14393.2189'
  second_image = 'hello-world'
  default_digest = 'sha256:204c41542c0927ac0296802e44c56b886b47e99cf8220fb49d46951bd5fc1742'
  default_dockerfile = 'c:/windows/temp/Dockerfile'
  #The default args are set because: 
  #restart => 'always' - there is no service created to manage containers 
  #net => 'nat' - docker uses bridged by default when running a container. When installing docker on windows the default network is NAT.
  default_docker_run_arg = "restart => 'always', net => 'nat',"
  default_run_command = "ping 127.0.0.1 -t"
  docker_command = "\"/cygdrive/c/Program Files/Docker/docker\""
  default_docker_exec_lr_command = 'cmd /c "ping 127.0.0.1 -t > c:\windows\temp\test_file.txt"'
  default_docker_exec_command = 'cmd /c "echo test > c:\windows\temp\test_file.txt"'
  docker_mount_path = "c:/windows/temp"
  storage_driver = "windowsfilter"
elsif fact('osfamily') == 'RedHat'
  docker_args = "repo_opt => '--enablerepo=localmirror-extras'"
  default_image = 'alpine'
  second_image = 'busybox'
  default_image_tag = '3.7'
  default_digest = 'sha256:3dcdb92d7432d56604d4545cbd324b14e647b313626d99b889d0626de158f73a'
  default_dockerfile = '/root/Dockerfile'
  docker_command = "docker"
  default_docker_run_arg = ''
  default_run_command = "init"
  default_docker_exec_lr_command = '/bin/sh -c "touch /root/test_file.txt; while true; do echo hello world; sleep 1; done"'
  default_docker_exec_command = 'touch /root/test_file.txt'
  docker_mount_path = "/root"
  storage_driver = "devicemapper"
else 
  docker_args = ''
  default_image = 'alpine'
  second_image = 'busybox'
  default_image_tag = '3.7'
  default_digest = 'sha256:3dcdb92d7432d56604d4545cbd324b14e647b313626d99b889d0626de158f73a'
  default_dockerfile = '/root/Dockerfile'
  docker_command = "docker"
  default_docker_run_arg = ''
  default_run_command = "init"
  default_docker_exec_lr_command = '/bin/sh -c "touch /root/test_file.txt; while true; do echo hello world; sleep 1; done"'
  default_docker_exec_command = 'touch /root/test_file.txt'
  docker_mount_path = "/root"
  storage_driver = "overlay2"   
end

describe 'the Puppet Docker module' do
  context 'clean up before each test' do
    before(:each) do
      retry_on_error_matching(60, 5, /connection failure running/) do
        # Stop all container using systemd
        shell('ls -D -1 /etc/systemd/system/docker-container* | sed \'s/\/etc\/systemd\/system\///g\' | sed \'s/\.service//g\' | while read container; do service $container stop; done')
        # Delete all running containers
        shell("#{docker_command} rm -f $(#{docker_command} ps -a -q) || true")
        # Delete all existing images
        shell("#{docker_command} rmi -f $(#{docker_command} images -q) || true")
        # Check to make sure no images are present
        shell("#{docker_command} images | wc -l") do |r|
          expect(r.stdout).to match(/^0|1$/)
        end
        # Check to make sure no running containers are present
        shell("#{docker_command} ps | wc -l") do |r|
          expect(r.stdout).to match(/^0|1$/)
        end
      end
    end


    describe 'docker class' do
      context 'without any parameters' do
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

      context 'passing a storage driver' do
        before(:all) do
          @pp=<<-EOS
            class {'docker':
            #{docker_args},
            storage_driver => "#{storage_driver}",
            }
          EOS
        
          apply_manifest(@pp, :catch_failures => true)
          sleep 15
          end

          it 'should result in the docker daemon being configured with the specified storage driver' do
            shell("#{docker_command} info -f \"{{ .Driver}}\"") do |r|
              expect(r.stdout).to match (/#{storage_driver}/)
            end
          end  
      end          

      context 'passing a TCP address to bind to' do
        before(:all) do
          @pp =<<-EOS
            class { 'docker':
              tcp_bind => 'tcp://127.0.0.1:4444',
              #{docker_args}
            }
          EOS
          apply_manifest(@pp, :catch_failures => true)
          # A sleep to give docker time to execute properly
          sleep 4
        end

        it 'should run idempotently' do
          apply_manifest(@pp, :catch_changes => true) unless fact('selinux') == 'true'
        end

        it 'should result in docker listening on the specified address' do
          if fact('osfamily') == 'windows'
            shell('netstat -a -b') do |r|
              expect(r.stdout).to match(/127.0.0.1:4444/)
            end
          else
            shell('netstat -tulpn | grep docker') do |r|
              expect(r.stdout).to match(/tcp\s+0\s+0\s+127.0.0.1:4444\s+0.0.0.0\:\*\s+LISTEN\s+\d+\/docker/)
            end
          end
        end
      end

      context 'bound to a particular unix socket' do
        before(:each) do
          @pp =<<-EOS
            class { 'docker':
              socket_bind => 'unix:///var/run/docker.sock',
              #{docker_args}
            }
          EOS
          apply_manifest(@pp, :catch_failures => true)
          # A sleep to give docker time to execute properly
          sleep 4
        end

        it 'should run idempotently' do
          apply_manifest(@pp, :catch_changes => true) unless fact('selinux') == 'true'
        end

        it 'should show docker listening on the specified unix socket' do
          if fact('osfamily') != 'windows'  
            shell('ps aux | grep docker') do |r|
              expect(r.stdout).to match(/unix:\/\/\/var\/run\/docker.sock/)
            end
          end
        end
      end

      context 'uninstall docker' do
        after(:all) do
          @pp =<<-EOS
            class {'docker': #{docker_args},
              ensure => 'present'
            }
          EOS
          apply_manifest(@pp, :catch_failures => true)

          # Wait for reboot if windows
          sleep 300 if fact('osfamily') == 'windows'
        end

        it 'should uninstall successfully' do
          @pp =<<-EOS
            class {'docker': #{docker_args},
              ensure => 'absent'
            }
          EOS
          apply_manifest(@pp, :catch_failures => true)
          sleep 4
          shell('docker ps', :acceptable_exit_codes => [1, 127])
        end
      end
    end

    describe 'docker::image' do

      it 'should successfully download an image from the Docker Hub' do
        pp=<<-EOS
          class { 'docker': #{docker_args} }
          docker::image { '#{default_image}':
            ensure  => present,
            require => Class['docker'],
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell("#{docker_command} images") do |r|
          expect(r.stdout).to match(/#{default_image}/)
        end
      end

      it 'should successfully download an image based on a tag from the Docker Hub' do
        pp=<<-EOS
          class { 'docker': #{docker_args} }
          docker::image { '#{default_image}':
            ensure    => present,
            image_tag => '#{default_image_tag}',
            require   => Class['docker'],
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell("#{docker_command} images") do |r|
          expect(r.stdout).to match(/#{default_image}\s+#{default_image_tag}/)
        end
      end

      it 'should successfully download an image based on a digest from the Docker Hub' do
        pp=<<-EOS
          class { 'docker': #{docker_args} }
          docker::image { '#{default_image}':
            ensure       => present,
            image_digest => '#{default_digest}',
            require      => Class['docker'],
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell("#{docker_command} images --digests") do |r|
          expect(r.stdout).to match(/#{default_image}.*#{default_digest}/)
        end
      end

      it 'should create a new image based on a Dockerfile' do
        pp=<<-EOS
          class { 'docker': #{docker_args} }

          docker::image { 'alpine_with_file':
            docker_file => "#{default_dockerfile}",
            require     => Class['docker'],
          }

          file { '#{default_dockerfile}':
            ensure  => present,
            content => "FROM #{default_image}\nRUN echo test > #{default_dockerfile}_test.txt",
            before  => Docker::Image['alpine_with_file'],
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4
        if fact('osfamily') == 'windows'
          shell("#{docker_command} run alpine_with_file cmd /c dir Windows\\\\Temp") do |r|
            expect(r.stdout).to match(/_test.txt/)
          end
        else
          shell("#{docker_command} run alpine_with_file ls #{default_dockerfile}_test.txt") do |r|
            expect(r.stdout).to match(/#{default_dockerfile}_test.txt/)
          end
        end
      end

      it 'should create a new image based on a tar', :win_broken => true do
        pp=<<-EOS
          class { 'docker': #{docker_args} }
          docker::image { '#{default_image}':
            require => Class['docker'],
            ensure  => present,
          }

          docker::run { 'container_2_4':
            image   => '#{default_image}',
            command => '/bin/sh -c "touch /root/test_file_for_tar_test.txt; while true; do echo hello world; sleep 1; done"',
            require => Docker::Image['alpine'],
          }
        EOS

        pp2=<<-EOS
          class { 'docker': #{docker_args} }
          docker::image { 'alpine_from_commit':
            docker_tar => "/root/rootfs.tar"
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        # Commit currently running container as an image
        container_id = shell("#{docker_command} ps | awk 'FNR == 2 {print $1}'")
        shell("#{docker_command} commit #{container_id.stdout.strip} alpine_from_commit")

        # Stop all container using systemd
        shell('ls -D -1 /etc/systemd/system/docker-container* | sed \'s/\/etc\/systemd\/system\///g\' | sed \'s/\.service//g\' | while read container; do service $container stop; done')

        # Stop all running containers
        shell("#{docker_command} rm -f $(docker ps -a -q) || true")

        # Make sure no other containers are running
        shell("#{docker_command} ps | wc -l") do |r|
          expect(r.stdout).to match(/^1$/)
        end

        # Export new to a tar file
        shell("#{docker_command} save alpine_from_commit > /root/rootfs.tar")

        # Remove all images
        shell("#{docker_command} rmi $(docker images -q) || true")

        # Make sure no other images are present
        shell("#{docker_command} images | wc -l") do |r|
          expect(r.stdout).to match(/^1$/)
        end

        apply_manifest(pp2, :catch_failures => true)
        apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell("#{docker_command} run alpine_from_commit ls /root") do |r|
          expect(r.stdout).to match(/test_file_for_tar_test.txt/)
        end
      end

      it 'should successfully delete the image' do
        pp1=<<-EOS
          class { 'docker': #{docker_args} }
          docker::image { '#{default_image}':
            ensure  => present,
            require => Class['docker'],
          }
        EOS
        apply_manifest(pp1, :catch_failures => true)
        pp2=<<-EOS
          class { 'docker': #{docker_args} }
          docker::image { '#{default_image}':
            ensure => absent,
          }
        EOS
        apply_manifest(pp2, :catch_failures => true)
        apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell("#{docker_command} images") do |r|
          expect(r.stdout).to_not match(/#{default_image}/)
        end
      end
    end

    describe "docker::run"  do
      it 'should start a container with a configurable command' do
        pp=<<-EOS
          class { 'docker': #{docker_args}
          }

          docker::image { '#{default_image}':
            require => Class['docker'],
          }

          docker::run { 'container_3_1':
            image   => '#{default_image}',
            command => '#{default_docker_exec_lr_command}',
            require => Docker::Image['#{default_image}'],
            #{default_docker_run_arg}
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        container_id = shell("#{docker_command} ps | awk 'FNR == 2 {print $1}'")
        if fact('osfamily') == 'windows'
          shell("#{docker_command} exec #{container_id.stdout.strip} cmd /c dir Windows\\\\Temp") do |r|
            expect(r.stdout).to match(/test_file.txt/)
          end
        else
          shell("#{docker_command} exec #{container_id.stdout.strip} ls /root") do |r|
            expect(r.stdout).to match(/test_file.txt/)
          end
        end

        container_name = shell("#{docker_command} ps | awk 'FNR == 2 {print $NF}'")
        expect("#{container_name.stdout.strip}").to match(/(container-3-1|container_3_1)/)
      end

      it 'should start a container with port configuration' do
        pp=<<-EOS
          class { 'docker': #{docker_args}}

          docker::image { '#{default_image}':
            require => Class['docker'],
          }

          docker::run { 'container_3_2':
            image   => '#{default_image}',
            command => '#{default_run_command}',
            ports   => ['4444'],
            expose  => ['5555'],
            require => Docker::Image['#{default_image}'],
            #{default_docker_run_arg}
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell("#{docker_command} ps") do |r|
          expect(r.stdout).to match(/"#{default_run_command}".+5555\/tcp\, 0\.0\.0.0\:\d+\-\>4444\/tcp/)
        end
      end

      it 'should start a container with the hostname set' do
        pp=<<-EOS
          class { 'docker': #{docker_args} }

          docker::image { '#{default_image}':
            require => Class['docker'],
          }

          docker::run { 'container_3_3':
            image    => '#{default_image}',
            command  => '#{default_run_command}',
            hostname => 'testdomain.com',
            require  => Docker::Image['#{default_image}'],
            #{default_docker_run_arg}
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        container_id = shell("#{docker_command} ps | awk 'FNR == 2 {print $1}'")

        shell("#{docker_command} exec #{container_id.stdout.strip} hostname") do |r|
          expect(r.stdout).to match(/testdomain.com/)
        end
      end

      it 'should start a container while mounting local volumes' do
        pp=<<-EOS
          class { 'docker': #{docker_args} }

          docker::image { '#{default_image}':
            require => Class['docker'],
          }

          docker::run { 'container_3_4':
            image   => '#{default_image}',
            command => '#{default_run_command}',
            volumes => ["#{docker_mount_path}:#{docker_mount_path}/mnt:rw"],
            require => Docker::Image['#{default_image}'],
            #{default_docker_run_arg}
          }

          file { '#{docker_mount_path}/test_mount.txt':
            ensure => present,
            before => Docker::Run['container_3_4'],
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4
        container_id = shell("#{docker_command} ps | awk 'FNR == 2 {print $1}'")
        if fact('osfamily') == 'windows'
          shell("#{docker_command} exec #{container_id.stdout.strip} cmd /c dir Windows\\\\Temp\\\\mnt") do |r|
            expect(r.stdout).to match(/test_mount.txt/)
          end
        else
          shell("#{docker_command} exec #{container_id.stdout.strip} ls /root/mnt") do |r|
            expect(r.stdout).to match(/test_mount.txt/)
          end
        end
      end

      #cpuset is not supported on Docker Windows
      #STDERR: C:/Program Files/Docker/docker.exe: Error response from daemon: invalid option: Windows does not support CpusetCpus.
      it 'should start a container with cpuset paramater set', :win_broken => true do
        pp=<<-EOS
          class { 'docker': #{docker_args} }

          docker::image { '#{default_image}':
            require => Class['docker'],
          }

          docker::run { 'container_3_5_5':
            image   => '#{default_image}',
            command => '#{default_run_command}',
            cpuset  => ['0'],
            require => Docker::Image['#{default_image}'],
            #{default_docker_run_arg}
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell('#{docker_command} inspect container_3_5_5') do |r|
          expect(r.stdout).to match(/"CpusetCpus"\: "0"/)
        end
      end

      #leagacy container linking was not implemented on Windows. --link is a legacy Docker feature: https://docs.docker.com/network/links/
      it 'should start multiple linked containers', :win_broken => true do
        pp=<<-EOS
          class { 'docker': #{docker_args} }

          docker::image { '#{default_image}':
            require => Class['docker'],
          }

          docker::run { 'container_3_5_1':
            image   => '#{default_image}',
            command => '#{default_run_command}',
            require => Docker::Image['#{default_image}'],
            #{default_docker_run_arg}
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        container_1 = shell("#{docker_command} ps | awk 'FNR == 2 {print $NF}'")

        pp2=<<-EOS
          class { 'docker': #{docker_args} }

          docker::image { '#{default_image}':
            require => Class['docker'],
          }

          docker::run { 'container_3_5_2':
            image   => '#{default_image}',
            command => '#{default_run_command}',
            depends => ['#{container_1.stdout.strip}'],
            links   => "#{container_1.stdout.strip}:the_link",
            require => Docker::Image['#{default_image}'],
            #{default_docker_run_arg}
          }
        EOS

        apply_manifest(pp2, :catch_failures => true)
        apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        container_2 = shell("#{docker_command} ps | awk 'FNR == 2 {print $NF}'")

        container_id = shell("#{docker_command} ps | awk 'FNR == 2 {print $1}'")
        shell("#{docker_command} inspect -f \"{{ .HostConfig.Links }}\" #{container_id.stdout.strip}") do |r|
          expect(r.stdout).to match("/#{container_1.stdout.strip}:/#{container_2.stdout.strip}/the_link")
        end
      end

      it 'should stop a running container' do
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
            image   => '#{default_image}',
            running => false,
            require => Docker::Image['#{default_image}'],
            #{default_docker_run_arg}
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell("#{docker_command} ps | wc -l") do |r|
          expect(r.stdout).to match(/^2$/)
        end

        apply_manifest(pp2, :catch_failures => true)
        apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell("#{docker_command} ps | wc -l") do |r|
          expect(r.stdout).to match(/^1$/)
        end
      end

      it 'should stop a running container and remove container' do
        pp=<<-EOS
          class { 'docker': #{docker_args} }

          docker::image { '#{default_image}':
            require => Class['docker'],
          }

          docker::run { 'container_3_6_1':
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

          docker::run { 'container_3_6_1':
            ensure  => 'absent',
            image   => '#{default_image}',
            require => Docker::Image['#{default_image}'],
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 15

        shell("#{docker_command} inspect container_3_6_1", :acceptable_exit_codes => [0])

        apply_manifest(pp2, :catch_failures => true)
        apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 15

        shell("#{docker_command} inspect container_3_6_1", :acceptable_exit_codes => [1])
      end

      it 'should allow dependency for ordering of independent run and image' do
        pp=<<-EOS
          class { 'docker': #{docker_args} }

          docker::image { '#{default_image}': }

          docker::run { 'container_3_7_1':
            image   => '#{default_image}',
            command => '#{default_run_command}',
            #{default_docker_run_arg}
          }

          docker::image { '#{second_image}':
            require => Docker::Run['container_3_7_1'],
          }

          docker::run { 'container_3_7_2':
            image   => '#{second_image}',
            command => '#{default_run_command}',
            #{default_docker_run_arg}
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

      end
      
      it 'should restart a unhealthy container' do
      pp5=<<-EOS
        docker::run { 'container_3_7_3':
          image   => '#{default_image}',
          command => '#{default_run_command}',
          health_check_cmd => 'echo',
          restart_on_unhealthy => true,
          #{default_docker_run_arg}
          }
          EOS

        if fact('osfamily') == 'windows'
          apply_manifest(pp5, :catch_failures => true)
        else
          apply_manifest(pp5, :catch_failures => true) do |r|
            expect(r.stdout).to match(/docker-container_3_7_3-systemd-reload/)
          end
        end
      end
    end

    describe "docker::exec"  do
      it 'should run a command inside an already running container' do
        pp=<<-EOS
          class { 'docker': #{docker_args} }

          docker::image { '#{default_image}':
            require => Class['docker'],
          }

          docker::run { 'container_4_1':
            image   => '#{default_image}',
            command => '#{default_run_command}',
            require => Docker::Image['#{default_image}'],
            #{default_docker_run_arg}
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 15

        container_1 = shell("#{docker_command} ps | awk 'FNR == 2 {print $NF}'")

        pp2=<<-EOS
          class { 'docker': #{docker_args} }
          docker::exec { 'test_command':
            container => '#{container_1.stdout.strip}',
            command   => '#{default_docker_exec_command}',
            tty       => true,
          }
        EOS

        apply_manifest(pp2, :catch_failures => true)

        # A sleep to give docker time to execute properly
        sleep 4

        container_id = shell("#{docker_command} ps | awk 'FNR == 2 {print $1}'")
        if fact('osfamily') == 'windows'
          shell("#{docker_command} exec #{container_id.stdout.strip} cmd /c dir Windows\\\\Temp") do |r|
            expect(r.stdout).to match(/test_file.txt/)
          end
        else
          shell("#{docker_command} exec #{container_id.stdout.strip} ls /root") do |r|
            expect(r.stdout).to match(/test_file.txt/)
          end
        end
      end

      it 'should only run if notified when refreshonly is true' do
        container_name = 'container_4_2'
        pp=<<-EOS
          class { 'docker': #{docker_args} }

          docker::image { '#{default_image}': }

          docker::run { '#{container_name}':
            image   => '#{default_image}',
            command => '#{default_run_command}',
            #{default_docker_run_arg}
          }

          docker::exec { 'test_command':
            container   => '#{container_name}',
            command     => '#{default_docker_exec_command}',
            refreshonly => true,
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        if fact('osfamily') == 'windows'
          shell("#{docker_command} exec #{container_name} cmd /c dir Windows\\\\Temp") do |r|
            expect(r.stdout).to_not match(/test_file.txt/)
          end
        else
          shell("#{docker_command} exec #{container_name} ls /root") do |r|
            expect(r.stdout).to_not match(/test_file.txt/)
          end
        end

        pp_extra=<<-EOS
          file { '#{default_dockerfile}_dummy_file':
            ensure => 'present',
            notify => Docker::Exec['test_command'],
          }
        EOS

        pp2 = pp + pp_extra

        apply_manifest(pp2, :catch_failures => true)
        apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        if fact('osfamily') == 'windows'
          shell("#{docker_command} exec #{container_name} cmd /c dir Windows\\\\Temp") do |r|
            expect(r.stdout).to match(/test_file.txt/)
          end
        else
          shell("#{docker_command} exec #{container_name} ls /root") do |r|
            expect(r.stdout).to match(/test_file.txt/)
          end
        end
      end
    end
  end
end