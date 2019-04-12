Facter.add(:iptables_persistent_version) do
  confine :operatingsystem => %w{Debian Ubuntu}
  setcode do
    # Throw away STDERR because dpkg >= 1.16.7 will make some noise if the
    # package isn't currently installed.
    os = Facter.value(:operatingsystem)
    os_release = Facter.value(:operatingsystemrelease)
    if (os == 'Debian' and (Puppet::Util::Package.versioncmp(os_release, '8.0') >= 0)) or
       (os == 'Ubuntu' and (Puppet::Util::Package.versioncmp(os_release, '14.10') >= 0))
      cmd = "dpkg-query -Wf '${Version}' netfilter-persistent 2>/dev/null"
    else
      cmd = "dpkg-query -Wf '${Version}' iptables-persistent 2>/dev/null"
    end
    version = Facter::Util::Resolution.exec(cmd)

    if version.nil? or !version.match(/\d+\.\d+/)
      nil
    else
      version
    end
  end
end
