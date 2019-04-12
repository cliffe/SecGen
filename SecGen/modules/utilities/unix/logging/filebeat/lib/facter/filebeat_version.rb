require 'facter'
Facter.add('filebeat_version') do
  confine 'kernel' => ['FreeBSD', 'OpenBSD', 'Linux', 'Windows']
  if File.executable?('/usr/bin/filebeat')
    filebeat_version = Facter::Util::Resolution.exec('/usr/bin/filebeat version')
  elsif File.executable?('/usr/local/bin/filebeat')
    filebeat_version = Facter::Util::Resolution.exec('/usr/local/bin/filebeat --version')
  elsif File.executable?('/usr/share/filebeat/bin/filebeat')
    filebeat_version = Facter::Util::Resolution.exec('/usr/share/filebeat/bin/filebeat --version')
  elsif File.executable?('/usr/local/sbin/filebeat')
    filebeat_version = Facter::Util::Resolution.exec('/usr/local/sbin/filebeat --version')
  elsif File.exist?('c:\Program Files\Filebeat\filebeat.exe')
    filebeat_version = Facter::Util::Resolution.exec('"c:\Program Files\Filebeat\filebeat.exe" --version')
  end
  setcode do
    filebeat_version.nil? ? false : %r{^filebeat version ([^\s]+)?}.match(filebeat_version)[1]
  end
end
