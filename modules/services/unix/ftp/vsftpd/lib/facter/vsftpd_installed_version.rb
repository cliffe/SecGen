Facter.add(:vsftpd_installed_version) do
  setcode do
    output = Facter::Util::Resolution.exec('vsftpd -v 0>&1') || 'vsftpd: version 0'
    output.gsub(/^vsftpd: version ([\d\.]+)$/, '\1')
  end
end
