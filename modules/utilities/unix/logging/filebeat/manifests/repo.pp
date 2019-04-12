# filebeat::repo
#
# Manage the repository for Filebeat (Linux only for now)
#
# @summary Manages the yum, apt, and zypp repositories for Filebeat
class filebeat::repo {
  $debian_repo_url = "https://artifacts.elastic.co/packages/${filebeat::major_version}.x/apt"
  $yum_repo_url = "https://artifacts.elastic.co/packages/${filebeat::major_version}.x/yum"

  case $::osfamily {
    'Debian': {
      include ::apt

      Class['apt::update'] -> Package['filebeat']

      if !defined(Apt::Source['beats']){
        apt::source { 'beats':
          ensure   => $::filebeat::alternate_ensure,
          location => $debian_repo_url,
          release  => 'stable',
          repos    => 'main',
          pin      => $::filebeat::repo_priority,
          key      => {
            id     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
            source => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          },
        }
      }
    }
    'RedHat', 'Linux': {
      if !defined(Yumrepo['beats']){
        yumrepo { 'beats':
          ensure   => $::filebeat::alternate_ensure,
          descr    => 'elastic beats repo',
          baseurl  => $yum_repo_url,
          gpgcheck => 1,
          gpgkey   => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
          priority => $::filebeat::repo_priority,
          enabled  => 1,
        }
      }
    }
    'Suse': {
      exec { 'topbeat_suse_import_gpg':
        command => 'rpmkeys --import https://artifacts.elastic.co/GPG-KEY-elasticsearch',
        unless  => 'test $(rpm -qa gpg-pubkey | grep -i "D88E42B4" | wc -l) -eq 1 ',
        notify  => [ Zypprepo['beats'] ],
      }
      if !defined(Zypprepo['beats']){
        zypprepo { 'beats':
          ensure      => $::filebeat::alternate_ensure,
          baseurl     => $yum_repo_url,
          enabled     => 1,
          autorefresh => 1,
          name        => 'beats',
          gpgcheck    => 1,
          gpgkey      => 'https://packages.elastic.co/GPG-KEY-elasticsearch',
          type        => 'yum',
        }
      }
    }
    default: {
      fail($filebeat::osfamily_fail_message)
    }
  }

}
