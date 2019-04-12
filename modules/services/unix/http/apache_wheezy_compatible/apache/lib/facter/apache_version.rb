Facter.add(:apache_version) do
  setcode do
    if Facter::Util::Resolution.which('apachectl')
      apache_version = Facter::Util::Resolution.exec('apachectl -v 2>&1')
      Facter.debug "Matching apachectl '#{apache_version}'"
      %r{^Server version: Apache\/(\d+.\d+(.\d+)?)}.match(apache_version)[1]
    elsif Facter::Util::Resolution.which('apache2ctl')
      apache_version = Facter::Util::Resolution.exec('apache2ctl -v 2>&1')
      Facter.debug "Matching apache2ctl '#{apache_version}'"
      %r{^Server version: Apache\/(\d+.\d+(.\d+)?)}.match(apache_version)[1]
    end
  end
end
