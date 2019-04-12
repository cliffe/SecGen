# Definition: xinetd::service
#
# sets up a xinetd service
# all parameters match up with xinetd.conf(5) man page
#
# Parameters:
#   $ensure         - optional - defaults to 'present'
#   $log_on_success - optional - may contain any combination of
#                       'PID', 'HOST', 'USERID', 'EXIT', 'DURATION', 'TRAFFIC'
#   $log_on_success_operator - optional - defaults to '+='.  This is whether or
#                              not values specified will be add, set or remove
#                              from the default.
#   $log_on_failure - optional - may contain any combination of
#                       'HOST', 'USERID', 'ATTEMPT'
#   $log_on_failure_operator - optional - defaults to '+='.  This is whether or
#                              not values specified will be add, set or remove
#                              from the default.
#   $service_type   - optional - type setting in xinetd
#                       may contain any combinarion of 'RPC', 'INTERNAL',
#                       'TCPMUX/TCPMUXPLUS', 'UNLISTED'
#   $cps            - optional
#   $flags          - optional
#   $per_source     - optional
#   $port           - optional - determines the service port (required if service is not listed in /etc/services)
#   $server         - required - determines the program to execute for this service
#   $server_args    - optional
#   $disable        - optional - defaults to "no"
#   $socket_type    - optional - defaults to "stream"
#   $protocol       - optional - defaults to "tcp"
#   $user           - optional - defaults to "root"
#   $group          - optional - defaults to "root"
#   $groups         - optional - defaults to "yes"
#   $instances      - optional - defaults to "UNLIMITED"
#   $only_from      - optional
#   $wait           - optional - based on $protocol will default to "yes" for udp and "no" for tcp
#   $xtype          - deprecated - use $service_type instead 
#   $no_access      - optional
#   $access_times   - optional
#   $log_type       - optional
#   $bind           - optional
#   $nice           - optional - integer between -20 and 19, inclusive.
#   $redirect       - optional - ip or hostname and port of the target service
#
# Actions:
#   setups up a xinetd service by creating a file in /etc/xinetd.d/
#
# Requires:
#   $server must be set
#   $port must be set
#
# Sample Usage:
#   # setup tftp service
#   xinetd::service { 'tftp':
#     port        => '69',
#     server      => '/usr/sbin/in.tftpd',
#     server_args => '-s $base',
#     socket_type => 'dgram',
#     protocol    => 'udp',
#     cps         => '100 2',
#     flags       => 'IPv4',
#     per_source  => '11',
#     nice        => 19,
#   } # xinetd::service
#
define xinetd::service (
  $server,
  $port                    = undef,
  $ensure                  = present,
  $log_on_success          = undef,
  $log_on_success_operator = '+=',
  $log_on_failure          = undef,
  $log_on_failure_operator = '+=',
  $service_type            = undef,
  $service_name            = $title,
  $cps                     = undef,
  $disable                 = 'no',
  $flags                   = undef,
  $group                   = undef,
  $groups                  = 'yes',
  $instances               = 'UNLIMITED',
  $per_source              = undef,
  $protocol                = 'tcp',
  $server_args             = undef,
  $socket_type             = 'stream',
  $user                    = undef,
  $only_from               = undef,
  $wait                    = undef,
  $xtype                   = undef,
  $no_access               = undef,
  $access_times            = undef,
  $log_type                = undef,
  $bind                    = undef,
  $nice                    = undef,
  $env                     = undef,
  $redirect                = undef,
) {

  include ::xinetd

  if $user {
    $_user = $user
  } else {
    $_user = $xinetd::params::default_user
  }

  if $group {
    $_group = $group
  } else {
    $_group = $xinetd::params::default_group
  }

  if $wait {
    $_wait = $wait
  } else {
    validate_re($protocol, '(tcp|udp)')
    $_wait = $protocol ? {
      'tcp' => 'no',
      'udp' => 'yes'
    }
  }

  if $xtype {
    warning ('The $xtype parameter to xinetd::service is deprecated. Use the service_type parameter instead.')
  }

  if $nice != undef {
    validate_integer($nice)

    if $nice < -20 or $nice > 19 {
      fail("Invalid value for nice, ${nice}")
    }
  }

  # Template uses:
  # - $port
  # - $disable
  # - $socket_type
  # - $protocol
  # - $_wait
  # - $user
  # - $group
  # - $groups
  # - $server
  # - $bind
  # - $service_type
  # - $server_args
  # - $only_from
  # - $per_source
  # - $log_on_success
  # - $log_on_success_operator
  # - $log_on_failure
  # - $log_on_failure_operator
  # - $cps
  # - $flags
  # - $xtype (deprecated)
  # - $no_access
  # - $access_types
  # - $log_type
  # - $nice
  # - $redirect
  file { "${xinetd::confdir}/${title}":
    ensure  => $ensure,
    owner   => 'root',
    mode    => '0644',
    content => template('xinetd/service.erb'),
    notify  => Service[$xinetd::service_name],
    require => File[$xinetd::confdir],
  }

}
