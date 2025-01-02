class phish_victim_bot::install {

  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $usernames = $secgen_parameters['usernames']
  $passwords = $secgen_parameters['passwords']
  $phish_victim_bot_configs = $secgen_parameters['phish_victim_bot_configs']

  ensure_packages(['zip','libreoffice-writer','libreoffice-calc','xvfb'])

  if ($operatingsystem == 'Debian') {
    case $operatingsystemrelease {
      /^(12).*/: { # do 12.x bookworm stuff
        ensure_packages(['openjdk-17-jre', 'openjdk-17-jdk'])
      }
      /^(9|10).*/: { # do 9.x stretch stuff
        ensure_packages(['openjdk-11-jre', 'openjdk-11-jdk'])
      }
      /^7.*/: { # do 7.x wheezy stuff
        # Will error -- TODO needs repo
        ensure_packages(['openjdk-11-jre', 'openjdk-11-jdk'])
      }
      'kali-rolling': { # do kali
        ensure_packages(['openjdk-11-jre', 'openjdk-11-jdk'])
      }
      default: {
      }
    }
  }
  user { 'guest':
    ensure     => present,
    password   => pw_hash("guestpassword", 'SHA-512', 'bXlzYWx0'),
    managehome => true,
  }
  if $usernames {
    $usernames.each |$index, $username| {
      # Create user
      user { $username:
        ensure     => present,
        password   => pw_hash($passwords[$index], 'SHA-512', 'bXlzYWx0'),
        managehome => true,
      } ->
      file { "/home/$username/.user.properties":
        ensure   => present,
        owner    => $username,
        group    => $username,
        mode     => '0600',
        content => $phish_victim_bot_configs[$index],
      } ->
      file { [ "/home/$username/.config/", "/home/$username/.config/libreoffice/", "/home/$username/.config/libreoffice/4/", "/home/$username/.config/libreoffice/4/user/"]:
        ensure => 'directory',
        owner    => $username,
        group    => $username,
      } ->
      file { "/home/$username/.config/libreoffice/4/user/registrymodifications.xcu":
        ensure   => present,
        owner    => $username,
        group    => $username,
        mode     => '0600',
        source => 'puppet:///modules/phish_victim_bot/libreoffice-macros-registrymodifications.xcu',
      }

      # run on each boot via cron
      cron { "$username-mail":
        command     => "Xvfb :9$index & export DISPLAY=:9$index && sleep 60 && cd /home/$username && java -cp /opt/mailreader/mail.jar:/opt/mailreader/activation-1.1-rev-1.jar:/opt/mailreader/ MailReader &",
        special     => 'reboot',
        user        => $username,
      }

      ::secgen_functions::leak_files { "$username-mail-file-leak":
        storage_directory => "/home/$username",
        leaked_filenames  => [$leaked_filenames[$index]],
        strings_to_leak   => [$strings_to_leak[$index]],
        owner             => $username,
        mode              => '0600',
        leaked_from       => "phish_victim_bot-$username",
      }

    }
  }
  file { '/opt/mailreader/':
    ensure   => directory,
    owner    => 'root',
    group    => 'root',
    mode     => '0755',
  }->
  file { '/opt/mailreader/MailReader.java':
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0755',
    source => 'puppet:///modules/phish_victim_bot/MailReader.java',
  }->
  file { '/opt/mailreader/activation-1.1-rev-1.jar':
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0755',
    source => 'puppet:///modules/phish_victim_bot/activation-1.1-rev-1.jar',
  }->
  file { '/opt/mailreader/mail.jar':
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0755',
    source => 'puppet:///modules/phish_victim_bot/mail.jar',
  }->
  exec{ 'compile to mailreader class':
    path    => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
    command => "javac -cp /opt/mailreader/mail.jar:/opt/mailreader/activation-1.1-rev-1.jar MailReader.java && chmod 0755 /opt/mailreader/MailReader.class && chown root:root /opt/mailreader/MailReader.class",
    cwd     => '/opt/mailreader/',
  }

}
