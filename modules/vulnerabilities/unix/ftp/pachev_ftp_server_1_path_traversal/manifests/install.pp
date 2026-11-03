# Builds the bundled Pachev FTP server from source, offline. The vendor
# tarball holds the crates its Cargo.lock pins, a .cargo/config that points
# crates.io at them, and a Cargo.lock that replaces upstream's with one change:
# slog 1.5.2 -> 1.7.1, because 1.5.2 no longer compiles (it implements Sync
# for fmt::Arguments). cargo needs no network and never re-resolves versions.
class pachev_ftp_server_1_path_traversal::install {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = $secgen_parameters['leaked_username'][0]
  $src_dir = '/opt/pachev_ftp/pachev_ftp-master/ftp_server'

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  ensure_packages(['rustc', 'cargo', 'unzip', 'acl'])

  file { '/opt/pachev_ftp':
    ensure  => 'directory',
    owner   => $user,
    mode    => '0755',
    require => User[$user],
  } ->

  file { '/opt/pachev_ftp/pachev_ftp-master.zip':
    source  => 'puppet:///modules/pachev_ftp_server_1_path_traversal/pachev_ftp-master.zip',
    owner   => $user,
    mode    => '0755',
  } ->

  file { '/opt/pachev_ftp/pachev_ftp_server_vendor.tar.gz':
    source  => 'puppet:///modules/pachev_ftp_server_1_path_traversal/pachev_ftp_server_vendor.tar.gz',
    mode    => '0644',
  } ->

  exec { 'unzip-pachev-ftp-master':
    command => 'unzip pachev_ftp-master.zip',
    cwd     => '/opt/pachev_ftp/',
    creates => '/opt/pachev_ftp/pachev_ftp-master/',
    require => Package['unzip'],
  } ->

  exec { 'unpack-pachev-ftp-vendor':
    command => 'tar -xzf /opt/pachev_ftp/pachev_ftp_server_vendor.tar.gz',
    cwd     => $src_dir,
    creates => "${src_dir}/vendor",
  } ->

  exec { 'build-ftpserver':
    command     => 'cargo build --release',
    cwd         => $src_dir,
    environment => ['HOME=/root', 'CARGO_HOME=/root/.cargo'],
    creates     => "${src_dir}/target/release/ftp_server",
    timeout     => 0,
    logoutput   => true,
    require     => Package['rustc', 'cargo'],
  }

}
