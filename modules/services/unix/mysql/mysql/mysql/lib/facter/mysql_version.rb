Facter.add("mysql_version") do
  setcode do
    mysql_ver = Facter::Util::Resolution.exec('mysql --version')
    if mysql_ver
      mysql_ver.match(/\d+\.\d+\.\d+/)[0]
    end
  end
end
