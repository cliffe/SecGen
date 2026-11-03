require_relative '../../../../../lib/post_provision_test'

class LibreofficeTest < PostProvisionTest
  def initialize
    self.module_name = 'libreoffice'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super
    tier(1) do
      test_local_command('libreoffice-writer installed?', 'dpkg -l libreoffice-writer | grep -E "^ii"', 'libreoffice-writer')
      test_local_command('libreoffice-calc installed?', 'dpkg -l libreoffice-calc | grep -E "^ii"', 'libreoffice-calc')
      test_local_command('libreoffice binary on PATH', 'command -v libreoffice', 'libreoffice')
    end
    tier(2) do
      test_command_succeeds('libreoffice binary exists', 'test -x /usr/bin/libreoffice')
      # no inputs to check: the module takes none
      test_command_succeeds('libreoffice runs', 'libreoffice --version')
      # headless conversion exercises Writer and Calc for real (own profile dir, no display needed)
      convert('writer', 'txt', 'hello writer', 'pdf')
      convert('calc', 'csv', 'a,b\n1,2', 'pdf')
    end
  end

  # Convert a small generated file with a headless LibreOffice and check the output is non-empty.
  def convert(app, ext, content, target)
    dir = "/tmp/secgen_lo_#{app}"
    cmd = "rm -rf #{dir} && mkdir -p #{dir} && printf '#{content}' > #{dir}/in.#{ext} && " \
          "cd #{dir} && HOME=#{dir} timeout 100 libreoffice --headless -env:UserInstallation=file://#{dir}/profile " \
          "--convert-to #{target} in.#{ext} >/dev/null 2>&1; test -s #{dir}/in.#{target}"
    name = "#{app} converts #{ext} to #{target} headless"
    out = run_vagrant_ssh(cmd, timeout: 120)
    if out[:exit_status] == 0
      pass_check(name, nil, tier: 2)
    else
      fail_check(name, "#{name} failed on #{get_system_name}", tier: 2,
                 evidence: "$ #{cmd}\n--- stdout\n#{out[:stdout]}\n--- stderr\n#{out[:stderr]}")
    end
  end
end

LibreofficeTest.new.run
