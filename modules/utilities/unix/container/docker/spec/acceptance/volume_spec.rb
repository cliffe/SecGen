require 'spec_helper_acceptance'

broken = false

if fact('osfamily') == 'windows'
  docker_args = 'docker_ee => true'
  command = "\"/cygdrive/c/Program Files/Docker/docker\""
elsif ('osfamily') == 'RedHat'
  docker_args = "repo_opt => '--enablerepo=localmirror-extras'"
  command = 'docker'
else
  command = 'docker'
end

describe 'docker volume' do
  before(:all) do
    retry_on_error_matching(60, 5, /connection failure running/) do
      install_code = "class { 'docker': #{docker_args} }"
      apply_manifest(install_code, :catch_failures => true)
    end
  end

  it 'should expose volume subcommand' do
    shell("#{command} volume --help", :acceptable_exit_codes => [0])
  end

  context 'with a local volume described in Puppet' do
    before(:all) do
      @name = 'test-volume'
      @pp = <<-code
        docker_volume { '#{@name}':
          ensure => present,
        }
      code
      apply_manifest(@pp, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(@pp, :catch_changes => true)
    end

    it 'should have created a volume' do
      shell("#{command} volume inspect #{@name}", :acceptable_exit_codes => [0])
    end

    after(:all) do
      shell("#{command} volume rm #{@name}")
    end
  end
end