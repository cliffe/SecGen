# This class is called from kibana to configure the daemon's configuration
# file.
# It is not meant to be called directly.
#
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
class kibana::config {

  $_ensure = $::kibana::ensure ? {
    'absent' => $::kibana::ensure,
    default  => 'file',
  }
  $config = $::kibana::config

  file { '/etc/kibana/kibana.yml':
    ensure  => $_ensure,
    content => template("${module_name}/etc/kibana/kibana.yml.erb"),
    owner   => 'kibana',
    group   => 'kibana',
    mode    => '0660',
  }
}
