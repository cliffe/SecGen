require_relative '../../../../../lib/post_provision_test'

# node_sha256 is not checked: it only guards the download, and the tarball it verifies is deleted once
# unpacked, so nothing on the built VM records it.
class NodejsTest < PostProvisionTest
  def initialize
    self.module_name = 'nodejs'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    node_version = self.json_inputs['node_version']&.first
    packages = (self.json_inputs['global_packages'] || []).map(&:to_s).reject { |pkg| pkg.strip.empty? }
    user = login_user

    tier(1) do
      if node_version
        test_local_command("node #{node_version} unpacked",
                           "test -x /opt/node-v#{node_version}-linux-x64/bin/node && echo ok", 'ok')
      end
      test_local_command('/opt/node follows the installed version', 'readlink -f /opt/node', '/opt/node-v')
      test_local_command('node, npm and npx are on the default PATH',
                         'for b in node npm npx; do test -x "/usr/local/bin/$b" || exit 1; done; echo ok', 'ok')
    end

    tier(2) do
      # As an ordinary account, so an install only root can read, or a missing shared library, fails here
      if node_version
        test_local_command('node runs and reports the installed version',
                           'node --version', "v#{node_version}", user: user)
      else
        test_local_command('node runs', 'node --version', 'v', user: user)
      end
      test_command_succeeds('npm runs', 'npm --version', user: user)
      # A global install has to land on the default PATH, or a tool another module installs is invisible
      test_local_command('npm installs globally into /usr/local', 'npm config get prefix', '/usr/local', user: user)

      packages.each do |pkg|
        # the directory npm unpacks into, dropping any @<version> suffix but keeping a leading @scope
        name = pkg.sub(/\A(@?[^@]+).*\z/, '\1')
        test_local_command("global package #{name} installed",
                           "test -d /usr/local/lib/node_modules/#{name} && echo ok", 'ok')
        test_command_succeeds("global package #{name} is importable", "node -e \"require.resolve('#{name}')\"",
                              user: user)
      end
    end
  end

  # The module creates no accounts, so whichever ordinary login account the system has stands in for a student.
  # nil means the check runs as root instead, which is the best available on a base with no such account.
  def login_user
    found = run_vagrant_ssh("awk -F: '$3>=1000 && $3<60000 && $6 ~ /^\\/home\\// {print $1; exit}' /etc/passwd")
    user = found[:stdout].to_s.strip
    user.empty? ? nil : user
  end
end

NodejsTest.new.run
