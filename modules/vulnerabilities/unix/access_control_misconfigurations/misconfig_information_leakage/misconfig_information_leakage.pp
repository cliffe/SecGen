# class {'misconfig_information_leakage::parse_facter_data':}


class {'misconfig_information_leakage::change_information_leakage_permissions':
  files_to_change_permissions => {
    ### '/etc/shadow'
    '/etc/shadow' => '0622', # Gives read permissions to group members and other users
    # '/etc/shadow' => '0602', # Gives read permissions to any user
    # '/etc/shadow' => '0602', # Gives read permissions to any user

    ### '/etc/shadow-'
    '/etc/shadow-' => '0622', # Gives read permissions to group members and other users
    # '/etc/shadow-' => '0602', # Gives read permissions to any user
    # '/etc/shadow-' => '0602', # Gives read permissions to any user

    # ### '/etc/passwd'
    # '/etc/passwd' => '0622', # Gives read permissions to group members and other users
    # # '/etc/passwd' => '0602', # Gives read permissions to any user
    # # '/etc/passwd' => '0602', # Gives read permissions to any user


    ### '/etc/passwd-'
    '/etc/passwd-' => '0622', # Gives read permissions to group members and other users
    # '/etc/passwd-' => '0602', # Gives read permissions to any user
    # '/etc/passwd-' => '0602', # Gives read permissions to any user

    ### '/etc/gshadow'
    '/etc/gshadow' => '0622', # Gives read permissions to group members and other users
    # '/etc/gshadow' => '0602', # Gives read permissions to any user
    # '/etc/gshadow' => '0602', # Gives read permissions to any user

    ### '/etc/gshadow-'
    '/etc/gshadow-' => '0622', # Gives read permissions to group members and other users
    '/etc/gshadow-' => '0602', # Gives read permissions to any user
    '/etc/gshadow-' => '0602', # Gives read permissions to any user

    ### '/etc/group'
    '/etc/group' => '0622', # Gives read permissions to group members and other users
    # '/etc/group' => '0602', # Gives read permissions to any user
    # '/etc/group' => '0602', # Gives read permissions to any user

    ### '/etc/group-'
    '/etc/group-' => '0622', # Gives read permissions to group members and other users
    # '/etc/group-' => '0602', # Gives read permissions to any user
    # '/etc/group-' => '0602', # Gives read permissions to any user

    ### '/etc/fstab'
    '/etc/fstab' => '0664', # Gives write and read access to group members and write access to other users

    ### '/etc/profile'
    '/etc/profile' => '0622', # Gives read access to both group members and other users
    # '/etc/profile' => '0620', # Gives read access to group members
    # '/etc/profile' => '0602', # Gives read access to other users

    # ### '/etc/sudoers'
    # '/etc/sudoers' => '0422', # Gives read access to group members and other users
    # # '/etc/sudoers' => '0420', # Gives read access to group members
    # # '/etc/sudoers' => '0402', # Gives read access to other users

    ### '/var/log'
    '/var/log' => '0622',
    # '/var/log' => '0620',
    # '/var/log' => '0602',

    ### '/var/mail/root'
    '/var/mail/root' => '0622',
    # '/var/mail/root' => '0620',
    # '/var/mail/root' => '0602',


    ### '/var/mail'
    '/var/mail' => '0622',
    # '/var/mail' => '0620',
    # '/var/mail' => '0602',

    ### '/var/spool'
    '/var/spool' => '0622',
    # '/var/spool' => '0620',
    # '/var/spool' => '0602',

    ### '/var/spool/lpd'
    '/var/spool/lpd' => '0622',
    # '/var/spool/lpd' => '0620',
    # '/var/spool/lpd' => '0602',

    ### '/var/lib/pgsql'
    '/var/lib/pgsql' => '0622',
    # '/var/lib/pgsql' => '0620',
    # '/var/lib/pgsql' => '0602',

    ### '/var/lib/mysql'
    '/var/lib/mysql' => '0622',
    # '/var/lib/mysql' => '0620',
    # '/var/lib/mysql' => '0602',

    ### /var/lib/dhcp3/dhclient.leases
    '/var/lib/dhcp3/dhclient.leases' => '0622',
    # '/var/lib/dhcp3/dhclient.leases' => '0620',
    # '/var/lib/dhcp3/dhclient.leases' => '0602',

    ### '/etc/httpd/logs/access_log'
    '/etc/httpd/logs/access_log' => '0622',
    # '/etc/httpd/logs/access_log' => '0620',
    # '/etc/httpd/logs/access_log' => '0602',

    ### '/etc/httpd/logs/error_log'
    '/etc/httpd/logs/error_log' => '0622',
    # '/etc/httpd/logs/error_log' => '0620',
    # '/etc/httpd/logs/error_log' => '0602',

    ### '/var/log/apache2/access_log'
    '/var/log/apache2/access_log' => '0622',
    # '/var/log/apache2/access_log' => '0620',
    # '/var/log/apache2/access_log' => '0602',

    ### /var/log/apache2/error_log
    '/var/log/apache2/error_log' => '0622',
    # '/var/log/apache2/error_log' => '0620',
    # '/var/log/apache2/error_log' => '0602',

    ### /var/log/apache/access_log
    '/var/log/apache/access_log' => '0622',
    # '/var/log/apache/access_log' => '0620',
    # '/var/log/apache/access_log' => '0602',

    ### /var/log/auth.log
    '/var/log/auth.log' => '0622',
    # '/var/log/auth.log' => '0620',
    # '/var/log/auth.log' => '0602',

    ### /var/log/chttp.log
    '/var/log/chttp.log' => '0622',
    # '/var/log/chttp.log' => '0620',
    # '/var/log/chttp.log' => '0602',

    ### /var/log/cups/error_log
    '/var/log/cups/error_log' => '0622',
    # '/var/log/cups/error_log' => '0620',
    # '/var/log/cups/error_log' => '0602',

    ### /var/log/dpkg.log
    '/var/log/dpkg.log' => '0622',
    # '/var/log/dpkg.log' => '0620',
    # '/var/log/dpkg.log' => '0602',

    ### /var/log/faillog
    '/var/log/faillog' => '0622',
    # '/var/log/faillog' => '0620',
    # '/var/log/faillog' => '0602',

    ### /var/log/httpd/access_log
    '/var/log/httpd/access_log' => '0622',
    # '/var/log/httpd/access_log' => '0620',
    # '/var/log/httpd/access_log' => '0602',

    ### /var/log/httpd/error.log
    '/var/log/httpd/error.log' => '0622',
    # '/var/log/httpd/error.log' => '0620',
    # '/var/log/httpd/error.log' => '0602',

    ### /var/log/lastlog
    '/var/log/lastlog' => '0622',
    # '/var/log/lastlog' => '0620',
    # '/var/log/lastlog' => '0602',

    ### /var/log/lighttpd/access.log
    '/var/log/lighttpd/access.log' => '0622',
    # '/var/log/lighttpd/access.log' => '0620',
    # '/var/log/lighttpd/access.log' => '0602',

    ### /var/log/lighttpd/error.log
    '/var/log/lighttpd/error.log' => '0622',
    # '/var/log/lighttpd/error.log' => '0620',
    # '/var/log/lighttpd/error.log' => '0602',

    ### /var/log/lighttpd/lighttpd.access.log
    '/var/log/lighttpd/lighttpd.access.log' => '0622',
    # '/var/log/lighttpd/lighttpd.access.log' => '0620',
    # '/var/log/lighttpd/lighttpd.access.log' => '0602',

    ### /var/log/lighttpd/lighttpd.error.log
    '/var/log/lighttpd/lighttpd.error.log' => '0622',
    # '/var/log/lighttpd/lighttpd.error.log' => '0620',
    # '/var/log/lighttpd/lighttpd.error.log' => '0602',

    ### /var/log/messages
    '/var/log/messages' => '0622',
    # '/var/log/messages' => '0620',
    # '/var/log/messages' => '0602',

    ### /var/log/secure
    '/var/log/secure' => '0622',
    # '/var/log/secure' => '0620',
    # '/var/log/secure' => '0602',

    ### /var/log/syslog
    '/var/log/syslog' => '0622',
    # '/var/log/syslog' => '0620',
    # '/var/log/syslog' => '0602',

    ### /var/log/wtmp
    '/var/log/wtmp' => '0622',
    # '/var/log/wtmp' => '0620',
    # '/var/log/wtmp' => '0602',

    ### /var/log/xferlog
    '/var/log/xferlog' => '0622',
    # '/var/log/xferlog' => '0620',
    # '/var/log/xferlog' => '0602',

    ### /var/log/yum.log
    '/var/log/yum.log' => '0622',
    # '/var/log/yum.log' => '0620',
    # '/var/log/yum.log' => '0602',

    ### /var/run/utmp
    '/var/run/utmp' => '0622',
    # '/var/run/utmp' => '0620',
    # '/var/run/utmp' => '0602',

    ### /var/webmin/miniserv.log
    '/var/webmin/miniserv.log' => '0622',
    # '/var/webmin/miniserv.log' => '0620',
    # '/var/webmin/miniserv.log' => '0602',

    ### /var/www/logs/access_log
    '/var/www/logs/access_log' => '0622',
    # '/var/www/logs/access_log' => '0620',
    # '/var/www/logs/access_log' => '0602',

    ### /var/www/logs/access.log
    '/var/www/logs/access.log' => '0622',
    # '/var/www/logs/access.log' => '0620',
    # '/var/www/logs/access.log' => '0602',

    ### /var/lib/dhcp3/
    '/var/lib/dhcp3' => '0622',
    # '/var/lib/dhcp3' => '0620',
    # '/var/lib/dhcp3' => '0602',

    ### /var/log/postgresql/
    '/var/log/postgresql' => '0622',
    # '/var/log/postgresql' => '0620',
    # '/var/log/postgresql' => '0602',

    ### /var/log/proftpd/
    '/var/log/proftpd' => '0622',
    # '/var/log/proftpd' => '0620',
    # '/var/log/proftpd' => '0602',

    ### /var/log/samba/
    '/var/log/samba' => '0622',
    # '/var/log/samba' => '0620',
    # '/var/log/samba' => '0602',

    ### /etc/fstab
    '/etc/fstab' => '0622',
    # '/etc/fstab' => '0620',
    # '/etc/fstab' => '0602',
  },
}