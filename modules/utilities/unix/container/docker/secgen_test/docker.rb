require_relative '../../../../../lib/post_provision_test'
require 'shellwords'

class DockerTest < PostProvisionTest
  # Not checked: the HTTP proxy the manifest hardcodes for Docker, which is environment
  # specific rather than an input.
  def initialize
    self.module_name = 'docker'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    images = self.json_inputs['images'] || []

    tier(1) do
      test_local_command('docker binary present', 'which docker', 'docker')
      test_local_command('docker engine package installed', "dpkg-query -W -f='${Package} ${Status}\\n' 'docker-ce*' 'docker.io' 'docker-engine' 2>/dev/null", 'install ok installed')
      test_local_command('dockerd present', 'command -v dockerd', 'dockerd')
      test_local_command('docker service enabled', 'systemctl is-enabled docker', 'enabled')
      test_local_command('docker group exists', 'getent group docker', 'docker')
    end
    tier(2) do
      test_command_succeeds('docker version runs', 'docker --version')
      test_command_succeeds('docker daemon socket exists', 'test -S /var/run/docker.sock')
      test_local_command('docker service active', 'systemctl is-active docker | grep -x active', 'active')
      test_command_succeeds('docker daemon answers', 'docker info')
      # every configured image was pulled for offline use
      images.each do |image|
        test_command_succeeds("image #{image} pulled", "docker image inspect #{Shellwords.escape(image)}")
      end
      # a container really runs (no network needed; the image's entrypoint is bypassed)
      if (image = images.first)
        test_command_succeeds("container runs from #{image}",
                              "docker run --rm --network none --entrypoint /bin/true #{Shellwords.escape(image)}")
      end
    end
  end
end

DockerTest.new.run
