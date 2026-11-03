require_relative '../../../../../lib/post_provision_test'

class LabtainersMarkerTest < PostProvisionTest
  def initialize
    self.module_name = 'labtainers_marker'
    self.module_path = get_module_path(__FILE__)
    super
  end

  def test_module
    super

    labs = self.json_inputs['lab'] || []
    flags = self.json_inputs['flags'] || []

    tier(1) do
      test_local_command('labflags directory exists', 'test -d /opt/labflags && echo present', 'present')
      test_local_command('labflags binary present', 'test -f /opt/labflags/labflags && echo present', 'present')
      test_local_command('labflags.rb present', 'test -f /opt/labflags/labflags.rb && echo present', 'present')
      # setuid root wrapper and root-owned, executable marker script
      test_local_command('labflags is setuid root', "stat -c '%a %U:%G' /opt/labflags/labflags", '4755 root:root')
      test_local_command('labflags.rb is root-owned and executable', "stat -c '%a %U:%G' /opt/labflags/labflags.rb", '755 root:root')

      # one flags file per lab input
      labs.each do |lab|
        test_local_command("#{lab} flags file present", "test -s /opt/labflags/#{lab}.flags.json && echo present", 'present')
        test_local_command("#{lab} flags file is valid JSON",
                           "ruby -rjson -e 'JSON.parse(File.read(ARGV[0])); puts %q(valid)' /opt/labflags/#{lab}.flags.json", 'valid')
      end

      # The acl template takes the last 10 supplied flags (it pops them off the
      # end); other labs' templates hold fixed flags, so only acl is checked.
      if labs.include?('acl')
        flags.last(10).each do |flag|
          test_local_command("acl flags file contains #{flag}",
                             "grep -cF #{Shellwords.escape(flag)} /opt/labflags/acl.flags.json", '1')
        end
      end
    end

    tier(2) do
      test_command_succeeds('labflags binary is executable', 'test -x /opt/labflags/labflags')
      test_command_succeeds('labflags is SUID', "stat -c '%a' /opt/labflags/labflags | grep -q '^4'")
      # the setuid wrapper must run for an unprivileged user (needs ruby on PATH at /usr/bin/ruby)
      test_local_command('labflags runs as an unprivileged user', '/opt/labflags/labflags', 'Processing labs', user: 'nobody')
    end
  end
end

LabtainersMarkerTest.new.run
