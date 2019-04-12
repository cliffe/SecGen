require 'spec_helper_acceptance'

if fact('osfamily') == 'windows'
  docker_args = 'docker_ee => true'
  tmp_path = 'C:/cygwin64/tmp'
  test_container = 'nanoserver-sac2016'
  wait_for_container_seconds = 120
else
  docker_args = ''
  tmp_path = '/tmp'
  test_container = 'debian'
  wait_for_container_seconds = 10
end

describe 'docker stack' do
  before(:all) do
    retry_on_error_matching(60, 5, /connection failure running/) do
      @install_code = <<-code
        class { 'docker': #{docker_args} }
        docker::swarm {'cluster_manager':
            init   => true,
            ensure => 'present',
        }
      code
      apply_manifest(@install_code, :catch_failures=>true)
    end
  end

  context 'Creating stack' do
    let(:install) {"
    docker::stack { 'web':
      stack_name    => 'web',
      compose_files => ['#{tmp_path}/docker-stack.yml'],
      ensure        => present,
    }"
      }

    it 'should deploy stack' do
      apply_manifest(install, :catch_failures=>true)
      sleep wait_for_container_seconds
    end

    it 'should be idempotent' do
      apply_manifest(install, :catch_changes=>true)
    end

    it 'should find a stack' do
        shell('docker stack ls') do |r|
            expect(r.stdout).to match(/web/)
         end
    end

    it 'should find a docker container' do
        shell("docker ps | grep web_compose_test", :acceptable_exit_codes => [0])
      end
  end

  context 'Destroying stack' do
    let(:install) {"
        docker::stack { 'web':
          stack_name    => 'web',
          compose_files => ['#{tmp_path}/docker-stack.yml'],
          ensure        => present,
        }"
        }
        let(:destroy) {"
            docker::stack { 'web':
              stack_name    => 'web',
              compose_files => ['#{tmp_path}/docker-stack.yml'],
              ensure        => absent,
            }"
        }
        it 'should run successfully' do
            apply_manifest(destroy, :catch_failures=>true)
        end

        it 'should be idempotent' do
            apply_manifest(destroy, :catch_changes=>true)
        end

        it 'should not find a docker stack' do
            shell('docker stack ls') do |r|
               expect(r.stdout).to_not match(/web/)
            end
        end
    end

    context 'creating stack with multi compose files' do
        
        before(:all) do
            @install_code = <<-code
            docker::stack { 'web':
              stack_name    => 'web',
              compose_files => ['#{tmp_path}/docker-stack.yml', '#{tmp_path}/docker-stack-override.yml'],
              ensure        => present,
            }
          code
        
          apply_manifest(@install_code, :catch_failures=>true)
        end
    
        it "should find container with web_compose_test tag" do
            sleep wait_for_container_seconds
            shell("docker ps | grep web_compose_test", :acceptable_exit_codes => [0])
        end
      end
    
      context 'Destroying project with multiple compose files' do
        before(:all) do
                @install_code = <<-code
                docker::stack { 'web':
                  stack_name    => 'web',
                  compose_files => ['#{tmp_path}/docker-stack.yml', '#{tmp_path}/docker-stack-override.yml'],
                  ensure        => present,
                }
              code
            
              apply_manifest(@install_code, :catch_failures=>true)

              @destroy_code = <<-code
              docker::stack { 'web':
                stack_name    => 'web',
                compose_files => ['#{tmp_path}/docker-stack.yml', '#{tmp_path}/docker-stack-override.yml'],
                ensure        => absent,
              }
            code

            apply_manifest(@destroy_code, :catch_failures=>true)
            sleep 5 # wait for containers to stop
        end
    
        it 'should be idempotent' do
          apply_manifest(@destroy_code, :catch_changes=>true)
        end
    
        it 'should not find a docker stack' do
            shell('docker stack ls') do |r|
               expect(r.stdout).to_not match(/web/)
            end
        end

        it 'should not find a docker container' do
          shell("docker ps | grep #{test_container}", :acceptable_exit_codes => [1])
        end
      end

end