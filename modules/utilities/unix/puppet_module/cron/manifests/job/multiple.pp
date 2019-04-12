# Type: cron::job::multiple
#
# This type creates multiple cron jobs via a single file in /etc/cron.d/
#
# Parameters:
#   jobs - required - a hash of multiple cron jobs using the same structure as
#     cron::job and using the same defaults for each parameter.
#   ensure - The state to ensure this resource exists in. Can be absent, present
#     Defaults to 'present'
#   environment - An array of environment variable settings.
#     Defaults to an empty set ([]).
#   mode - The mode to set on the created job file
#     Defaults to 0644.
#
# Sample Usage:
#
# cron::job::multiple { 'test':
#   jobs => [
#     {
#       minute      => '55',
#       hour        => '5',
#       date        => '*',
#       month       => '*',
#       weekday     => '*',
#       user        => 'rmueller',
#       command     => '/usr/bin/uname',
#     },
#     {
#       command     => '/usr/bin/sleep 1',
#     },
#     {
#       command     => '/usr/bin/sleep 10',
#       special     => 'reboot',
#     },
#   ],
#   environment => [ 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"' ],
# }
# 
# This will generate those three cron jobs in `/etc/cron.d/test`:
# 55 5 * * *  rmueller  /usr/bin/uname
# * * * * *  root  /usr/bin/sleep 1
# @reboot root /usr/bin/sleep 10
#
define cron::job::multiple(
  Array[Struct[{
    Optional['command']     => String[1],
    Optional['minute']      => Variant[Integer,String[1]],
    Optional['hour']        => Variant[Integer,String[1]],
    Optional['date']        => Variant[Integer,String[1]],
    Optional['month']       => Variant[Integer,String[1]],
    Optional['weekday']     => Variant[Integer,String[1]],
    Optional['special']     => String[1],
    Optional['environment'] => Array[String],
    Optional['user']        => String[1],
    Optional['description'] => String,
  }]]                      $jobs,
  Enum['absent','present'] $ensure      = 'present',
  Array[String]            $environment = [],
  String[4,4]              $mode        = '0644',
) {
  case $ensure {
    'absent': {
      file { "job_${title}":
        ensure => absent,
        path   => "/etc/cron.d/${title}",
      }
    }
    default:  {
      file { "job_${title}":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => $mode,
        path    => "/etc/cron.d/${title}",
        content => template('cron/multiple.erb'),
      }
    }
  }
}
