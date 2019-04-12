# == Define: python::dotfile
#
# Manages any python dotfiles with a simple config hash.
#
# === Parameters
#
# [*ensure*]
#  present|absent. Default: present
#
# [*filename*]
#  Filename. Default: $title
#
# [*mode*]
#  File mode. Default: 0644
#
# [*owner*]
# [*group*]
#  Owner/group. Default: `root`/`root`
#
# [*config*]
#  Config hash. This will be expanded to an ini-file. Default: {}
#
# === Examples
#
# python::dotfile { '/var/lib/jenkins/.pip/pip.conf':
#   ensure => present,
#   owner  => 'jenkins',
#   group  => 'jenkins',
#   config => {
#     'global' => {
#       'index-url       => 'https://mypypi.acme.com/simple/'
#       'extra-index-url => https://pypi.risedev.at/simple/
#     }
#   }
# }
#
#
define python::dotfile (
  $ensure   = 'present',
  $filename = $title,
  $owner    = 'root',
  $group    = 'root',
  $mode     = '0644',
  $config   = {},
) {
  $parent_dir = dirname($filename)

  exec { "create ${title}'s parent dir":
    command => "install -o ${owner} -g ${group} -d ${parent_dir}",
    path    => [ '/usr/bin', '/bin', '/usr/local/bin', ],
    creates => $parent_dir,
  }

  file { $filename:
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => template("${module_name}/inifile.erb"),
    require => Exec["create ${title}'s parent dir"],
  }
}
