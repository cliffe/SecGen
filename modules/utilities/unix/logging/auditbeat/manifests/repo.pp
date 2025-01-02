# auditbeat::repo
# @api private
#
# @summary Manages the package repositories on the target nodes to install auditbeat
class auditbeat::repo inherits auditbeat {
  $apt_repo_url = $auditbeat::apt_repo_url ? {
    undef => "http://172.33.0.44/artifacts.elastic.co/packages/${auditbeat::major_version}.x/apt",
    default => $auditbeat::apt_repo_url,
  }
  $yum_repo_url = $auditbeat::yum_repo_url ? {
    undef => "http://172.33.0.44/artifacts.elastic.co/packages/${auditbeat::major_version}.x/yum",
    default => $auditbeat::yum_repo_url,
  }
  $gpg_key_url = $auditbeat::gpg_key_url ? {
    undef => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
    default => $auditbeat::gpg_key_url,
  }
  $gpg_key_id = $auditbeat::gpg_key_id ? {
    '' => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
    default => $auditbeat::gpg_key_id,
  }

  if ($auditbeat::manage_repo == true) and ($auditbeat::ensure == 'present') {
    case $facts['osfamily'] {
      'Debian': {
        include ::apt
        if !defined(Apt::Source['beats']) {
          apt::source{'beats':
            ensure   => $auditbeat::ensure,
            location => $apt_repo_url,
            release  => 'stable',
            repos    => 'main',
            key      => {
              id     => $gpg_key_id,
              source => $gpg_key_url,
            },
          }
          Class['apt::update'] -> Package['auditbeat']
        }
      }
      'RedHat': {
        if !defined(Yumrepo['beats']) {
          yumrepo{'beats':
            ensure   => $auditbeat::ensure,
            descr    => "Elastic repository for ${auditbeat::major_version}.x packages",
            baseurl  => $yum_repo_url,
            gpgcheck => 1,
            gpgkey   => $gpg_key_url,
            enabled  => 1,
          }
        }
      }
      'SuSe': {
        exec { 'suse_import_gpg':
          command => "/usr/bin/rpmkeys --import ${gpg_key_url}",
          unless  => "/usr/bin/test $(rpm -qa gpg-pubkey | grep -i \"${gpg_key_id}\" | wc -l) -eq 1",
          notify  => [ Zypprepo['beats'] ],
        }
        if !defined (Zypprepo['beats']) {
          zypprepo{'beats':
            baseurl     => $yum_repo_url,
            enabled     => 1,
            autorefresh => 1,
            name        => 'beats',
            gpgcheck    => 1,
            gpgkey      => $gpg_key_url,
            type        => 'yum',
          }
        }
      }
      default: {
      }
    }
  }
}
