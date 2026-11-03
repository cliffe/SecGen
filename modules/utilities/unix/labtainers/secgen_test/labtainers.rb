require_relative '../../../../../lib/post_provision_test'

class LabtainersTest < PostProvisionTest
  def initialize
    self.module_name = 'labtainers'
    self.module_path = get_module_path(__FILE__)
    super
  end

  # Inputs not checked: 'flags' is declared but labtainers' Puppet never reads
  # it (see module concern in the report).
  def test_module
    super

    lab = self.json_inputs['lab']&.first
    accounts = (self.json_inputs['accounts'] || []).map { |raw| JSON.parse(raw) }
    strings_to_leak = self.json_inputs['strings_to_leak'] || []
    env = 'PYTHONPATH=/opt/labtainer/scripts/labtainer-student/bin/:/opt/labtainer/scripts/labtainer-instructor/bin/ LABTAINER_DIR=/opt/labtainer/'
    student_dir = '/opt/labtainer/scripts/labtainer-student'

    tier(1) do
      test_local_command('labtainer directory exists', 'test -d /opt/labtainer && echo present', 'present')
      test_local_command('labtainer-student bin exists', 'test -d /opt/labtainer/scripts/labtainer-student/bin && echo present', 'present')
      test_local_command('labtainer binary present', 'test -f /opt/labtainer/scripts/labtainer-student/bin/labtainer && echo present', 'present')
      test_local_command('virtualenv present', 'test -d /opt/labtainer/venv && echo present', 'present')

      # packages installed by labtainers::install
      %w[apt-transport-https ca-certificates curl gnupg2 software-properties-common python3-pip
         openssh-server python3-netaddr python3-parse python3-dateutil okular gnome-terminal].each do |pkg|
        test_local_command("#{pkg} installed?", "dpkg -l #{pkg} | grep -E '^ii'", pkg)
      end

      test_local_command('checkwork_json installed root-owned and executable',
                         "stat -c '%a %U:%G' #{student_dir}/bin/checkwork_json", '755 root:root')
      test_local_command('venv python present', 'test -x /opt/labtainer/venv/bin/python && echo present', 'present')
      test_local_command('labtainer logs directory is world-writable', "stat -c '%a' /opt/labtainer/logs", '777')
      test_local_command('pull.log present', 'test -f /opt/labtainer/logs/pull.log && echo present', 'present')
      test_local_command('setup_scripts logs directory present', 'test -d /opt/labtainer/setup_scripts/logs && echo present', 'present')
      test_local_command('student .tmp is world-writable', "stat -c '%a' #{student_dir}/.tmp", '777')
      %w[labtainer-instructor/grader.log labtainer-instructor/saki.log labtainer-student/labtainer.log labtainer-student/grader.log].each do |log|
        test_local_command("#{log} is world-writable", "stat -c '%a' /opt/labtainer/scripts/#{log}", '666')
      end

      # grader account: exists, in the docker group, PATH set up
      test_local_command('grader account exists', 'getent passwd grader', 'grader')
      test_local_command('grader is in the docker group', 'id -nG grader', 'docker')
      test_local_command('grader profile adds labtainer to PATH', 'cat /home/grader/.profile', 'labtainer-student/bin')
      test_local_command('grader image pulled', "docker images --format '{{.Repository}}'", 'mfthomps/labtainer.grader')

      if lab
        test_local_command("lab #{lab} installed", "test -d /opt/labtainer/labs/#{lab} && echo present", 'present')
        test_local_command("lab #{lab} images pulled", "docker images --format '{{.Repository}}'", "#{lab}.")
      end

      # each string to leak is appended to the lab's read_first.txt
      if lab
        strings_to_leak.each do |str|
          test_local_command("read_first.txt for #{lab} contains #{str}",
                             "grep -cF #{Shellwords.escape(str)} /opt/labtainer/labs/#{lab}/docs/read_first.txt", '1')
        end
      end

      # per-account set-up
      accounts.each do |account|
        username = account['username']
        next unless username
        home = username == 'root' ? '/root' : "/home/#{username}"
        test_local_command("#{username}: labtainer-student link", "readlink #{home}/labtainer/labtainer-student", student_dir)
        test_local_command("#{username}: PATH patched in .profile", "cat #{home}/.profile", 'labtainer-student/bin')
        test_local_command("#{username}: LABTAINER_DIR in .bashrc", "cat #{home}/.bashrc", 'LABTAINER_DIR="/opt/labtainer/"')
        %w[.config/autostart/auto_start_lab.desktop .local/share/applications/start_lab.desktop].each do |desktop|
          test_local_command("#{username}: #{desktop} starts #{lab}", "cat #{home}/#{desktop}", "labtainer #{lab};") if lab
        end
      end
    end

    tier(2) do
      test_command_succeeds('labtainer bin executable', 'test -x /opt/labtainer/scripts/labtainer-student/bin/labtainer')
      test_local_command('docker available', 'which docker', '/usr/bin/docker')
      test_command_succeeds('docker daemon answers', 'docker info')
      test_command_succeeds('virtualenv imports labtainer dependencies',
                            '/opt/labtainer/venv/bin/python -c "import docker, netaddr, parse, dateutil"')
      test_command_succeeds('checkwork_json is executable', "test -x #{student_dir}/bin/checkwork_json")

      # labtainer must be started from the student directory (it runs bin/start.py)
      launch = "cd #{student_dir} && #{env} #{student_dir}/bin/labtainer --version"
      test_local_command('labtainer runs (root)', launch, 'labtainer')
      accounts.each do |account|
        username = account['username']
        next unless username
        test_local_command("labtainer runs as #{username}", launch, 'labtainer', user: username)
      end
    end
  end
end

LabtainersTest.new.run
