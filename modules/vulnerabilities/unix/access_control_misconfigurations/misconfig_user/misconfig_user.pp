# class { 'misconfig_user::parse_facter_data.pp':}

class { 'misconfig_user::change_user_permissions':
  files_to_change_permissions => {
    # os information made writable
    '/etc/issue' => '0666',
    '/etc/*-release' => '0666',
    '/etc/lsb-release' => '0666',      # Debian based
    '/etc/redhat-release' => '0666',   # Redhat based


    # os version made writable
    '/proc/version' => '0666',


    # Unreadable by anyone other then superuser until changed here
    '/etc/shadow' => '0644', ##### <<<<< Can change users password
    '/etc/shadow-' => '0644', ##### <<<<< Can read and crack backup file hashes
    '/etc/passwd' => '0644', ##### <<<<< Can change user account information and password hash (if system doesn't use shadow file)
    '/etc/passwd-' => '0644', ##### <<<<< Can read user account information and password hash (if system doesn't use shadow file)
    '/etc/gshadow' => '0644', ##### <<<<<
    '/etc/gshadow-' => '0644',
    '/etc/group' => '0644',
    '/etc/group-' => '0644',
    '/etc/fstab' => '0664',
    '/etc/profile' => '0646',
    '/etc/sudoers' => '0444',
    '/home' => '0444',

    # Application information files made readable and writable
    '/usr/bin/' => '0666',
    '/sbin/' => '0666',
    '/var/cache/apt/archivesO' => '0666',
    '/var/cache/yum/' => '0666',

    # Readable but changed to write permissions for all other users [Cron job files]
    '/var/spool/cron' => '0666',
    '/etc/cron*' => '0666',
    '/etc/at.allow' => '0666',
    '/etc/at.deny' => '0666',
    '/etc/cron.allow' => '0666',
    '/etc/cron.deny' => '0666',
    '/etc/crontab' => '0666',
    '/etc/anacrontab' => '0666',
    '/var/spool/cron/crontabs/root' => '0666',

    # Readable but changed to write permissions for all other users [Network files]
    '/etc/services' => '0666', # <--- Check if this is already readable, I think it is
    '/sbin/ifconfig' => '0666',
    '/etc/network/interfaces' => '0666',
    '/etc/sysconfig/network' => '0666',
    '/etc/resolv.conf' => '0666',
    '/etc/sysconfig/network' => '0666',
    '/etc/networks' => '0666',
    '/sbin/route' => '0666',
    # '/var/mail/' => '0666',

    # If common programs are on change config files to read and write
    '/var/apache2/config.inc' => '0666',
    '/var/lib/mysql/mysql/user.MYD' => '0666',
    '/root/anaconda-ks.cfg' => '0666',

    # # User account dependent for common programs (needs to be set up so can select user)
    # '~/.nano_history' => '0666',
    # '~/.atftp_history' => '0666',
    # '~/.mysql_history' => '0666',
    # '~/.php_history' => '0666',
    #
    # # User account dependent (needs to be set up so can select user)
    # '~/.aptitude' => '0766',
    # '~/.aptitude/config' => '0766',
    # '~/.ssh/id_rsa' => '0644',
    # '~/.ssh/id_dsa' => '0644',
    # '~/.ssh/authorized_keys' => '0644',
    # '~/.sh_history' => '0644',
    # '~/.forward' => '0644',

    # Enviroment variables
    '/etc/profile' => '0644',
    '/etc/bashrc' => '0644',
    # '~/.bash_profile' => '0644',
    # '~/.bashrc' => '0644',
    # '~/.bash_logout' => '0644',

    # User information files
    # '~/.bashrc' => '0666',
    # '~/.profile' => '0666',
    '/var/mail/root' => '0666',
    '/var/spool/mail/root' => '0666',

    # Private key information
    # '~/.ssh/authorized_keys' => '0666',
    # '~/.ssh/identity.pub' => '0666',
    # '~/.ssh/identity' => '0666',
    # '~/.ssh/id_rsa.pub' => '0666',
    # '~/.ssh/id_rsa' => '0666',
    # '~/.ssh/id_dsa.pub' => '0666',
    # '~/.ssh/id_dsa' => '0666',
    '/etc/ssh/ssh_config' => '0666',
    '/etc/ssh/sshd_config' => '0666',
    '/etc/ssh/ssh_host_dsa_key.pub' => '0666',
    '/etc/ssh/ssh_host_dsa_key' => '0666',
    '/etc/ssh/ssh_host_rsa_key.pub' => '0666',
    '/etc/ssh/ssh_host_rsa_key' => '0666',
    '/etc/ssh/ssh_host_key.pub' => '0666',
    '/etc/ssh/ssh_host_key' => '0666',

    # var dir made writable
    '/var/log' => '0666',
    '/var/mail' => '0666',
    '/var/spool' => '0666',
    '/var/spool/lpd' => '0666',
    '/var/lib/pgsql' => '0666',
    '/var/lib/mysql' => '0666',
    '/var/lib/dhcp3/dhclient.leases' => '0666',

    # All website files (if present) made writable
    '/var/www/' => '0666',
    '/srv/www/htdocs/' => '0666',
    '/usr/local/www/apache22/data/' => '0666',
    '/opt/lampp/htdocs/' => '0666',
    '/var/www/html/' => '0666',

    # Common service files
    '/etc/syslog.conf' => '0666',
    '/etc/chttp.conf' => '0666',
    '/etc/lighttpd.conf' => '0666',
    '/etc/cups/cupsd.conf' => '0666',
    '/etc/inetd.conf' => '0666',
    '/etc/apache2/apache2.conf' => '0666',
    '/etc/my.conf' => '0666',
    '/etc/httpd/conf/httpd.conf' => '0666',
    '/opt/lampp/etc/httpd.conf' => '0666',
  }
}