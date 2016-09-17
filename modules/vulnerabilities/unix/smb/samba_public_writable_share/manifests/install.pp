class samba_public_writable_share::install {

  concat { '/etc/samba/smb.conf':
    ensure => present,
  }

  concat::fragment { 'smb-conf-base':
    source => '/etc/samba/smb.conf',
    target => '/etc/samba/smb.conf',
    order => '01',
  }

  concat::fragment { 'smb-conf-public-share-definition':
    source => 'puppet:///modules/samba_public_writable_share/smb_conf_public_share_definition',
    target => '/etc/samba/smb.conf',
    order => '02',
  }

}