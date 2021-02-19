class freefloatftp_user::install {
  $edb_app_path = "http://www.exploit-db.com/apps"
  $mirror_app_path = "http://schreuders.org/exploitdb-apps-mirror"
  $filename = "687ef6f72dcbbf5b2506e80a375377fa-freefloatftpserver.zip"
  $zipfile = "C:/freefloatftpserver.zip"
  $install_path = "C:/Users/vagrant/Downloads/freefloatftpserver"

# (new-object System.Net.WebClient).DownloadFile( 'https://hacktivity.aet.leedsbeckett.ac.uk/files/exploit-db-apps/cf7a11d305a1091b71fe3e5ed5b6a55c-freefloatftpserversvr-1.7.0.2.zip', 'C:/Users/vagrant/Downloads/freefloatftpserver.zip')
  # file { 'C:/Users/vagrant/Downloads/freefloatftpserver.zip':
  #   ensure => present,
  #   source => ["$mirror_app_path/cf7a11d305a1091b71fe3e5ed5b6a55c-freefloatftpserversvr-1.7.0.2.zip",
  #              "$edb_app_path/cf7a11d305a1091b71fe3e5ed5b6a55c-freefloatftpserversvr-1.7.0.2.zip"],
  #  } ->

   exec {'fetch freefloatftpserver':
     command => "(new-object System.Net.WebClient).DownloadFile( '$edb_app_path/$filename', '$zipfile'); (new-object System.Net.WebClient).DownloadFile( '$mirror_app_path/$filename', '$zipfile'); \$true ",
     # command => "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri \"$mirror_app_path\" -OutFile \"$install_path\" ",
     provider     => 'powershell',
     creates => "$zipfile",
     logoutput => true,
   }->
   # TODO: puppet fail if not created by this point

   file { "$install_path":
     ensure => 'directory',
   } ->

   package { "7zip.portable":
     ensure => installed,
     provider => 'chocolatey',
   } ->

   # exec { 'Expand-Archive -LiteralPath C:\Users\vagrant\Downloads\freefloatftpserver.zip -DestinationPath C:/Users/vagrant/Downloads/freefloatftpserver':
   #   # cwd     => 'C:/Users/vagrant/Downloads/freefloatftpserver',
   #   provider     => 'powershell',
   #   path  => ['/bin', '/usr/bin', '/usr/sbin', '/sbin',],
   #   creates => 'C:/Users/vagrant/Downloads/freefloatftpserver/Ftpconsole.exe',
   #   logoutput => true,
   # } ->
   exec { "&7z x $zipfile -o$install_path -y":
     provider     => 'powershell',
     creates => "$install_path/Win32/FTPServer.exe",
     logoutput => true,
     # returns => [0,1],
   } ->

   # exec { "C:\Users\vagrant\Downloads\freefloatftpserver\ftpbasicsvr.exe":
   #   cwd     => 'C:/Users/vagrant/Downloads/freefloatftpserver',
   #   provider     => 'shell',
   #   path  => ['/bin', '/usr/bin', '/usr/sbin', '/sbin',],
   # } ->

   # run service on boot
   exec { 'schtasks /create /rl HIGHEST /ru system /sc ONSTART /tn freefloatftp /f /tr C:\Users\vagrant\Downloads\freefloatftpserver\Win32\FTPServer.exe ':
     provider     => 'powershell',
     logoutput => true,
   } ->

   # allow this ftp server program through the firewall
   exec { 'netsh advfirewall firewall add rule name=freefloatftpserver dir=in action=allow program=C:\Users\vagrant\Downloads\freefloatftpserver\Win32\FTPServer.exe enable=yes':
     provider     => 'powershell',
     logoutput => true,
   } ->
   # improve reliability by adding the firewall rule (again) everytime the VM boots -- messy but works?
   exec { 'schtasks /create /rl HIGHEST /ru system /sc ONSTART /tn freefloatftpserverfirewall /f /tr "netsh advfirewall firewall add rule name=freefloatftpserver dir=in action=allow program=C:\Users\vagrant\Downloads\freefloatftpserver\Win32\FTPServer.exe enable=yes" ':
     provider     => 'powershell',
     logoutput => true,
   }



}
