# Fact: java_version
#
# Purpose: get full java version string
#
# Resolution:
#   Tests for presence of java, returns nil if not present
#   returns output of "java -version" and splits on \n + '"'
#
# Caveats:
#   none
#
# Notes:
#   None
Facter.add(:java_version) do
  # the OS-specific overrides need to be able to return nil,
  # to indicate "no java available". Usually returning nil
  # would mean that facter falls back to a lower priority
  # resolution, which would then trigger MODULES-2637. To
  # avoid that, we confine the "default" here to not run
  # on those OS.
  # Additionally, facter versions prior to 2.0.1 only support
  # positive matches, so this needs to be done manually in setcode.
  setcode do
    unless [ 'openbsd', 'darwin' ].include? Facter.value(:operatingsystem).downcase
      if Facter::Util::Resolution.which('java')
        Facter::Util::Resolution.exec('java -Xmx8m -version 2>&1').lines.first.split(/"/)[1].strip
      end
    end
  end
end

Facter.add(:java_version) do
  confine :operatingsystem => 'OpenBSD'
  has_weight 100
  setcode do
    Facter::Util::Resolution.with_env("PATH" => '/usr/local/jdk-1.7.0/jre/bin:/usr/local/jre-1.7.0/bin') do
      if Facter::Util::Resolution.which('java')
        Facter::Util::Resolution.exec('java -Xmx8m -version 2>&1').lines.first.split(/"/)[1].strip
      end
    end
  end
end

Facter.add(:java_version) do
  confine :operatingsystem => 'Darwin'
  has_weight 100
  setcode do
    unless /Unable to find any JVMs matching version/ =~ Facter::Util::Resolution.exec('/usr/libexec/java_home --failfast 2>&1')
      Facter::Util::Resolution.exec('java -Xmx8m -version 2>&1').lines.first.split(/"/)[1].strip
    end
  end
end
