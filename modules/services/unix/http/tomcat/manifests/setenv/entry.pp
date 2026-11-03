# @summary This define adds an entry to the setenv.sh script.
#
# @param value
#   Provides the value(s) of the managed parameter. Valid options: a string or an array. If passing an array, separate values with a single space.
# @param ensure
#   Determines whether the fragment should exist in the configuration file. Valid options: 'present', 'absent'. 
# @param catalina_home
#   Root of the Tomcat installation.
# @param config_file
#   Specifies the configuration file to edit. Valid options: a string containing an absolute path. 
# @param param
#   Specifies a parameter to manage. Valid options: a string. `name` passed in your defined type.
# @param name
#   `$param`
# @param quote_char
#   Specifies a character to include before and after the specified value. Valid options: a string (usually a single or double quote). 
# @param order
#   Determines the ordering of your parameters in the configuration file (parameters with lower `order` values appear first.) Valid options: an integer or a string containing an integer. `10`.
# @param addto
#
# @param doexport
#   Specifies if you want to append export to the entry. Valid options: Boolean
# @param user
#   Specifies the owner of the config file. `$::tomcat::user`.
# @param group
#   Specifies the group of the config file. `$::tomcat::group`.
#
define tomcat::setenv::entry (
  Variant[String[1], Array[String[1]]]  $value,
  Enum['present', 'absent']             $ensure = 'present',
  Optional[String[1]]                   $catalina_home = undef,
  Optional[String[1]]                   $config_file   = undef,
  String[1]                             $param         = $name,
  Optional[String[1]]                   $quote_char    = undef,
  Variant[String[1], Integer]           $order         = '10',
  Optional[String[1]]                   $addto         = undef,
  Boolean                               $doexport      = true,
  Optional[String[1]]                   $user          = undef,
  Optional[String[1]]                   $group         = undef,
) {
  include tomcat
  $_user = pick($user, $tomcat::user)
  $_group = pick($group, $tomcat::group)
  $_catalina_home = pick($catalina_home, $tomcat::catalina_home)
  $home_sha = sha1($_catalina_home)
  tag($home_sha)

  Tomcat::Install <| tag == $home_sha |>
  -> Tomcat::Setenv::Entry[$name]

  $_config_file = $config_file ? {
    undef   => "${_catalina_home}/bin/setenv.sh",
    default => $config_file,
  }

  if ! $quote_char {
    $_quote_char = ''
  } else {
    $_quote_char = $quote_char
  }

  if ! defined(Concat[$_config_file]) {
    concat { $_config_file:
      owner          => $_user,
      group          => $_group,
      mode           => '0755',
      ensure_newline => true,
    }
  }

  if $doexport {
    $_doexport = 'export'
  } else {
    $_doexport = ''
  }

  if $addto {
    $_content = inline_template('<%= @_doexport %> <%= @param %>=<%= @_quote_char %><%= Array(@value).join(" ") %><%= @_quote_char %> ; <%= @_doexport %> <%= @addto %>="$<%= @addto %> $<%= @param %>"')
  } else {
    $_content = inline_template('<%= @_doexport %> <%= @param %>=<%= @_quote_char %><%= Array(@value).join(" ") %><%= @_quote_char+"\n" %>')
  }
  concat::fragment { "setenv-${name}":
    target  => $_config_file,
    content => $_content,
    order   => $order,
  }
}
