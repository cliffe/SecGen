require_relative '../../../../../lib/post_provision_test'

# No SecGen inputs: the module installs a fixed set of packages.
class HandyCliToolsTest < PostProvisionTest
  PACKAGES = %w[vim-tiny vim rsync psmisc curl sudo info].freeze
  # label => command that prints its version/usage and exits 0
  TOOLS = {
    'vim' => 'vim --version',
    'vim.tiny' => 'vim.tiny --version',
    'curl' => 'curl --version',
    'rsync' => 'rsync --version',
    'killall (psmisc)' => 'killall --version',
    'pstree (psmisc)' => 'pstree --version',
    'sudo' => 'sudo --version',
    'info' => 'info --version'
  }.freeze

  def initialize
    self.module_name = 'handy_cli_tools'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('vim installed', 'which vim', 'vim')
      test_local_command('curl installed', 'which curl', 'curl')
      test_local_command('rsync installed', 'which rsync', 'rsync')
      # match the status line, not the name: dpkg echoes a missing package's name on stderr
      PACKAGES.each do |pkg|
        test_local_command("#{pkg} package installed", "dpkg -s #{pkg}", 'Status: install ok installed')
      end
      test_local_command('killall installed', 'which killall', 'killall')
      test_local_command('pstree installed', 'which pstree', 'pstree')
      test_local_command('sudo installed', 'which sudo', 'sudo')
      test_local_command('info installed', 'which info', 'info')
    end
    tier(2) do
      test_command_succeeds('vim --version', 'vim --version')
      test_command_succeeds('curl --version', 'curl --version')
      # run every tool as an unprivileged user so PATH and missing libraries show up
      TOOLS.each do |label, cmd|
        test_command_succeeds("#{label} runs", cmd, user: 'nobody')
      end
    end
  end
end

HandyCliToolsTest.new.run
