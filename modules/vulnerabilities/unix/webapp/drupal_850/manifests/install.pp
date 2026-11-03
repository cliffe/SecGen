class drupal_850::install {
    Exec { path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin']}

    # PHP comes from the php7_patched utility (php-fpm on 127.0.0.1:9000).
    # The database is packaged MariaDB (creates the mysql user, auto-starts);
    # Drupalgeddon2 is an application vuln, so the DB engine is not the subject.
    ensure_packages(['mariadb-server'])

    $archive = 'drupal-8.5.0.tar.gz'

    #Drupal installation
    file {"/usr/local/src/${archive}":
        ensure => file,
        source => "puppet:///modules/drupal_850/${archive}",
    } ->
    file {"/usr/local/src/drupal_pre_setup.tar.gz":
        ensure => file,
        source => "puppet:///modules/drupal_850/drupal_pre_setup.tar.gz",
    } ->
    file {"/usr/local/src/drupal_pre_setup.sql":
        ensure => file,
        source => "puppet:///modules/drupal_850/drupal_pre_setup.sql",
    } ->
    # apache2 is installed later (apache.pp); create the web root now so the
    # unpack has somewhere to land.
    file { '/var/www':
        ensure => directory,
        mode   => '0755',
    } ->
    exec { 'unpack-drupal':
        cwd => '/usr/local/src',
        command => "tar -xzf ${archive} -C /var/www",
    } ->
    exec { 'chown-drupal':
        command => "chown www-data. /var/www/drupal-8.5.0 -R",
    }
}
