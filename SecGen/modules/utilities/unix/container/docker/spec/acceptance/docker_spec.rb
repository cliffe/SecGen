require 'spec_helper_acceptance'

broken = false

registry_port = 5000

if fact('osfamily') == 'windows'
  win_host = only_host_with_role(hosts, 'default')
  @windows_ip = win_host.ip
  docker_arg = "docker_ee => true, extra_parameters => '\"insecure-registries\": [ \"#{@windows_ip}:5000\" ]'"
  docker_registry_image = 'stefanscherer/registry-windows'
  docker_network = 'nat'
  registry_host = @windows_ip
  config_file = '/cygdrive/c/Users/Administrator/.docker/config.json'
  root_dir = "C:/Windows/Temp"
  server_strip = "#{registry_host}_#{registry_port}"
  bad_server_strip = "#{registry_host}_5001"
  broken = true
else
  if fact('osfamily') == 'RedHat'
    docker_args = "repo_opt => '--enablerepo=localmirror-extras'"
  else
    docker_arg = ''
  end
  docker_registry_image = 'registry'
  docker_network = 'bridge'
  registry_host = '127.0.0.1'
  server_strip = "#{registry_host}:#{registry_port}"
  bad_server_strip = "#{registry_host}:5001"
  config_file = '/root/.docker/config.json'
  root_dir = "/root"
end

describe 'docker' do
  package_name = 'docker-ce'
  service_name = 'docker'
  command = 'docker'

  context 'When adding system user', :win_broken => broken do
    let(:pp) {"
            class { 'docker': #{docker_arg}
              docker_users => ['user1']
            }
    "}

     it 'the docker daemon' do
       apply_manifest(pp, :catch_failures=>true) do |r|
         expect(r.stdout).to_not match(/docker-systemd-reload-before-service/)
       end
     end
   end

  context 'with default parameters', :win_broken => broken do
    let(:pp) {"
			class { 'docker':
        docker_users => [ 'testuser' ],
        #{docker_args}
			}
			docker::image { 'nginx': }
			docker::run { 'nginx':
				image   => 'nginx',
				net     => 'host',
				require => Docker::Image['nginx'],
			}
			docker::run { 'nginx2':
				image   => 'nginx',
				restart => 'always',
				require => Docker::Image['nginx'],
			}
    "}

    it 'should apply with no errors' do
      apply_manifest(pp, :catch_failures=>true)
    end

    it 'should be idempotent' do
      apply_manifest(pp, :catch_changes=>true)
    end

    describe package(package_name) do
      it { is_expected.to be_installed }
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe command("#{command} version") do
      its(:exit_status) { should eq 0 }
    end

    describe command("#{command} images"), :sudo => true do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /nginx/ }
    end

    describe command("#{command} inspect nginx"), :sudo => true do
      its(:exit_status) { should eq 0 }
    end

    describe command("#{command} inspect nginx2"), :sudo => true do
      its(:exit_status) { should eq 0 }
    end

    describe command("#{command} ps --no-trunc | grep `cat /var/run/docker-nginx2.cid`"), :sudo => true do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /nginx -g 'daemon off;'/ }
    end

    describe command('netstat -tlndp') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /0\.0\.0\.0\:80/ }
    end

    describe command('id testuser | grep docker') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /docker/ }
    end
  end

  context "When asked to have the latest image of something", :win_broken => broken do
    let(:pp) {"
        class { 'docker':
          docker_users => [ 'testuser' ]
        }
	docker::image { 'busybox': ensure => latest }
    "}
    it 'should apply with no errors' do
      apply_manifest(pp, :catch_failures=>true)
    end
    it 'should be idempotent' do
      apply_manifest(pp, :catch_changes=>true)
    end
  end

  context "When registry_mirror is set", :win_broken => broken do
    let(:pp) {"
      class { 'docker':
        registry_mirror => 'http://testmirror.io'
      }
    "}
     it 'should apply with no errors' do
       apply_manifest(pp, :catch_failures=>true)
     end

    it 'should have a registry mirror set' do
      shell('ps -aux | grep docker') do |r|
        expect(r.stdout).to match(/--registry-mirror=http:\/\/testmirror.io/)
      end
    end
  end

  context 'registry' do
    before(:all) do
      @registry_address = "#{registry_host}:#{registry_port}"
      @registry_bad_address = "#{registry_host}:5001"
      # @registry_email = 'user@example.com'
      @manifest = <<-EOS
        class { 'docker': #{docker_arg}}
        docker::run { 'registry':
          image         => '#{docker_registry_image}',
          pull_on_start => true,
          restart       => 'always',
          net           => '#{docker_network}',
          ports         => '#{registry_port}:#{registry_port}',
        }
      EOS
      retry_on_error_matching(60, 5, /connection failure running/) do
        apply_manifest(@manifest, :catch_failures=>true)
      end
      # avoid a race condition with the registry taking time to start
      # on some operating systems
      sleep 10
    end

    it 'should be able to login to the registry', :retry => 3, :retry_wait => 10 do
      manifest = <<-EOS
        docker::registry { '#{@registry_address}':
          username => 'username',
          password => 'password',
        }
      EOS
      apply_manifest(manifest, :catch_failures=>true)
      shell("grep #{@registry_address} #{config_file}", :acceptable_exit_codes => [0])
      shell("test -e \"#{root_dir}/registry-auth-puppet_receipt_#{server_strip}_root\"", :acceptable_exit_codes => [0])
    end

    it 'should be able to logout from the registry' do
      manifest = <<-EOS
        docker::registry { '#{@registry_address}':
          ensure=> absent,
        }
      EOS
      apply_manifest(manifest, :catch_failures=>true)
      shell("grep #{@registry_address} #{config_file}", :acceptable_exit_codes => [1,2])
      # shell("grep #{@registry_email} #{@config_file}", :acceptable_exit_codes => [1,2])
    end

    it 'should not create receipt if registry login fails' do
      manifest = <<-EOS
        docker::registry { '#{@registry_bad_address}':
          username => 'username',
          password => 'password',
        }
      EOS
      apply_manifest(manifest, :catch_failures=>true)
      shell("grep #{@registry_bad_address} #{config_file}", :acceptable_exit_codes => [1,2])
      shell("test -e \"#{root_dir}/registry-auth-puppet_receipt_#{bad_server_strip}_root\"", :acceptable_exit_codes => [1])
    end

  end

end
