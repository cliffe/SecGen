class samba_symlink_traversal::install {

  # Insert the 'allow insecure wide links = yes' line into the [global] section
  exec { 'sed-insert-global-allow-insecure-wide-links':
    command => "/bin/sed -i \'/\\[global\\]/a allow insecure wide links = yes\' /etc/samba/smb.conf"
  }

  concat { '/etc/samba/smb.conf':
    ensure => present,
  }

  concat::fragment { 'smb-conf-base':
    source => '/etc/samba/smb.conf',
    target => '/etc/samba/smb.conf',
    order => '01',
  }

  concat::fragment { 'smb-conf-wide-links':
    source => 'puppet:///modules/samba_symlink_traversal/smb_conf_wide_links',
    target => '/etc/samba/smb.conf',
    order => '03',
  }
}