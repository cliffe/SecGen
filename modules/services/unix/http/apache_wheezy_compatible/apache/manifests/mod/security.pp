class apache::mod::security (
  $logroot                    = $::apache::params::logroot,
  $crs_package                 = $::apache::params::modsec_crs_package,
  $activated_rules             = $::apache::params::modsec_default_rules,
  $modsec_dir                  = $::apache::params::modsec_dir,
  $modsec_secruleengine        = $::apache::params::modsec_secruleengine,
  $audit_log_relevant_status   = '^(?:5|4(?!04))',
  $audit_log_parts             = $::apache::params::modsec_audit_log_parts,
  $secpcrematchlimit           = $::apache::params::secpcrematchlimit,
  $secpcrematchlimitrecursion  = $::apache::params::secpcrematchlimitrecursion,
  $allowed_methods             = 'GET HEAD POST OPTIONS',
  $content_types               = 'application/x-www-form-urlencoded|multipart/form-data|text/xml|application/xml|application/x-amf',
  $restricted_extensions       = '.asa/ .asax/ .ascx/ .axd/ .backup/ .bak/ .bat/ .cdx/ .cer/ .cfg/ .cmd/ .com/ .config/ .conf/ .cs/ .csproj/ .csr/ .dat/ .db/ .dbf/ .dll/ .dos/ .htr/ .htw/ .ida/ .idc/ .idq/ .inc/ .ini/ .key/ .licx/ .lnk/ .log/ .mdb/ .old/ .pass/ .pdb/ .pol/ .printer/ .pwd/ .resources/ .resx/ .sql/ .sys/ .vb/ .vbs/ .vbproj/ .vsdisco/ .webinfo/ .xsd/ .xsx/',
  $restricted_headers          = '/Proxy-Connection/ /Lock-Token/ /Content-Range/ /Translate/ /via/ /if/',
  $secdefaultaction            = 'deny',
  $anomaly_score_blocking      = 'off',
  $inbound_anomaly_threshold   = '5',
  $outbound_anomaly_threshold  = '4',
  $critical_anomaly_score      = '5',
  $error_anomaly_score         = '4',
  $warning_anomaly_score       = '3',
  $notice_anomaly_score        = '2',
  $secrequestmaxnumargs        = '255',
  $secrequestbodylimit         = '13107200',
  $secrequestbodynofileslimit  = '131072',
  $secrequestbodyinmemorylimit = '131072',
) inherits ::apache::params {
  include ::apache

  $_secdefaultaction = $secdefaultaction ? {
    /log/   => $secdefaultaction, # it has log or nolog,auditlog or log,noauditlog
    default => "${secdefaultaction},log",
  }

  if $::osfamily == 'FreeBSD' {
    fail('FreeBSD is not currently supported')
  }

  if ($::osfamily == 'Suse' and $::operatingsystemrelease < '11') {
    fail('SLES 10 is not currently supported.')
  }

  ::apache::mod { 'security':
    id  => 'security2_module',
    lib => 'mod_security2.so',
  }


  ::apache::mod { 'unique_id_module':
    id  => 'unique_id_module',
    lib => 'mod_unique_id.so',
  }

  if $crs_package  {
    package { $crs_package:
      ensure => 'latest',
      before => [
        File[$::apache::confd_dir],
        File[$modsec_dir],
      ],
    }
  }

  # Template uses:
  # - logroot
  # - $modsec_dir
  # - $audit_log_parts
  # - secpcrematchlimit
  # - secpcrematchlimitrecursion
  # - secrequestbodylimit
  # - secrequestbodynofileslimit
  # - secrequestbodyinmemorylimit
  file { 'security.conf':
    ensure  => file,
    content => template('apache/mod/security.conf.erb'),
    mode    => $::apache::file_mode,
    path    => "${::apache::mod_dir}/security.conf",
    owner   => $::apache::params::user,
    group   => $::apache::params::group,
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }

  file { $modsec_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    purge   => true,
    force   => true,
    recurse => true,
    require => Package['httpd'],
  }

  file { "${modsec_dir}/activated_rules":
    ensure  => directory,
    owner   => $::apache::params::user,
    group   => $::apache::params::group,
    mode    => '0555',
    purge   => true,
    force   => true,
    recurse => true,
    notify  => Class['apache::service'],
  }

  # Template uses:
  # - $_secdefaultaction
  # - $critical_anomaly_score
  # - $error_anomaly_score
  # - $warning_anomaly_score
  # - $notice_anomaly_score
  # - $inbound_anomaly_threshold
  # - $outbound_anomaly_threshold
  # - $anomaly_score_blocking
  # - $allowed_methods
  # - $content_types
  # - $restricted_extensions
  # - $restricted_headers
  # - $secrequestmaxnumargs
  file { "${modsec_dir}/security_crs.conf":
    ensure  => file,
    content => template('apache/mod/security_crs.conf.erb'),
    require => File[$modsec_dir],
    notify  => Class['apache::service'],
  }

  unless $::operatingsystem == 'SLES' { apache::security::rule_link { $activated_rules: } }

}
