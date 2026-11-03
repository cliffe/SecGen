class kali_web::install{

  Exec{
    path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
  }


  # The following is a workaround for the crackmapexec package triggering our IPS
  # almost everything in kali-tools-top10:
  ensure_packages(['apache-users', 'apache2', 'beef-xss', 'burpsuite', 'cadaver', 'commix', 'cutycapt', 'default-mysql-server', 'dirb', 'dirbuster', 'hamster-sidejack', 'heartleech', 'httprint', 'httrack', 'hydra', 'jboss-autopwn', 'joomscan', 'jsql-injection', 'medusa', 'mitmproxy', 'ncrack', 'nikto', 'nmap', 'oscanner', 'owasp-mantra-ff', 'padbuster', 'paros', 'patator', 'php', 'php-mysql', 'proxychains4', 'proxytunnel', 'qsslcaudit', 'redsocks', 'sidguesser', 'siege', 'skipfish', 'slowhttptest', 'sqldict', 'sqlitebrowser', 'sqlmap', 'sqlninja', 'sqlsus', 'ssldump', 'sslh', 'sslscan', 'sslsniff', 'sslsplit', 'sslyze', 'stunnel4', 'thc-ssl-dos', 'tlssled', 'tnscmd10g', 'uniscan', 'wafw00f', 'wapiti', 'watobo', 'webacoo', 'webscarab', 'weevely', 'wfuzz', 'whatweb', 'wireshark', 'wpscan', 'xsser', 'zaproxy'])
  # TODO: re-add 'maltego' (after 'jsql-injection') once the package mirror serves it again;
  # its .deb failed with Hash Sum mismatch (mirror upstream timeout, 2026-10-28).
  # except webshells, nishang, laudanum, davtest, 'plecost','eyewitness', 'lbd', 
  # 'hydra-gtk', # TODO fixme

  # TODO: test current zaproxy doesn't still need this fix:
  # Temporary changes:
  #   Safely remove just the zaproxy package: (apt-cache depends kali-tools-web | grep 'Depends:' | awk {'print $2'} | xargs apt-mark manual) && apt-get remove zaproxy
  #   install the zaproxy-2.9.0-0kali1 debian package

  # exec { 'safely remove the zaproxy package':
  #   command => "apt-cache depends kali-tools-web | grep 'Depends:' | awk {'print \$2'} | xargs apt-mark manual",
  #   require => Package['kali-tools-web']
  # } ~>
  # package{ 'zaproxy':
  #   ensure => 'absent',
  #   before => Exec['create /opt/zaproxy-2.9.0'],
  # }
  #
  # exec { 'create /opt/zaproxy-2.9.0':
  #   command => 'mkdir /opt/zaproxy-2.9.0',
  # } ~>
  # file { '/opt/zaproxy-2.9.0/zaproxy_2.9.0-0kali1_all.deb':
  #   source => 'puppet:///modules/kali_web/zaproxy_2.9.0-0kali1_all.deb'
  # } ~>
  # exec { 'install zap 2.9.0':
  #   command => 'dpkg -i /opt/zaproxy-2.9.0/zaproxy_2.9.0-0kali1_all.deb',
  #   require => Package['zaproxy']
  # }
}
