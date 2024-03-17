# Class: easychat_bo::install
# Install process for easychat
#
class easychat_bo::install {
  $user = 'shunoban' ##$secgen_parameters['leaked_username'][0]

  file { 'C://Users/vagrant/Desktop/ecssetup.exe':
    ensure => present,
    source => 'puppet:///modules/easychat_bo/ecssetup.exe',
  }
  # this needs to be executed when a user logs in, hence the path
  -> file { "C://Users/${user}/AppData/Roaming/Microsoft/Windows/STARTM~1/Programs/Startup/close.ahk":
    ensure => present,
    source => 'puppet:///modules/easychat_bo/close.ahk',
  }
  -> file { 'C://Users/vagrant/Desktop/AutoHotkey_2.0.2_setup.exe':
    ensure => present,
    source => 'puppet:///modules/easychat_bo/AutoHotkey_2.0.2_setup.exe',
  }
  -> package { 'AutoHotkey':
    ensure          => installed,
    source          => 'C://Users/vagrant/Desktop/AutoHotkey_2.0.2_setup.exe',
    install_options => ['/silent'],
  }
  -> package { 'Easy Chat Server 3.1':
    ensure          => installed,
    source          => 'C://Users/vagrant/Desktop/ecssetup.exe',
    install_options => ['/VERYSILENT', '/NORESTART'],
  }
  # here we use the short path to remove issues with spaces in the path
  -> file { 'C://EFSSOF~1/EasyCh~1/option.ini':
    ensure => present,
    source => 'puppet:///modules/easychat_bo/option.ini',
  }
  -> exec { 'ec-allow-firewall':
    command => 'C:\Windows\System32\cmd.exe /c netsh advfirewall firewall add rule name="Easy Chat Server" dir=in action=allow program="C:\EFSSOF~1\EasyCh~1\EasyChat.exe" enable=yes'
  }
  -> exec { 'exec-easychat':
    command => 'C:\Windows\System32\cmd.exe /c start "easychat" /b "C:\EFSSOF~1\EasyCh~1\EasyChat.exe"',
  }
  -> exec { 'close-registration':
    cwd     => "C:\\Users\\${user}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup",
    command => 'C:\Users\vagrant\UX\AutoHotkeyUX.exe close.ahk',
  }
}
