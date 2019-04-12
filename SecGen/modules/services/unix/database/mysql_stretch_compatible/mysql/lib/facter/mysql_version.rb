Facter.add('mysql_version') do
  setcode do
    mysql_ver = Facter::Util::Resolution.exec('mysql --version')
    mysql_ver.match(%r{\d+\.\d+\.\d+})[0] if mysql_ver
  end
end
