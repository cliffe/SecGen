# == Define Resource Type: apache::balancer
#
# This type will create an apache balancer cluster file inside the conf.d
# directory. Each balancer cluster needs one or more balancer members (that can
# be declared with the apache::balancermember defined resource type). Using
# storeconfigs, you can export the apache::balancermember resources on all
# balancer members, and then collect them on a single apache load balancer
# server.
#
# === Requirement/Dependencies:
#
# Currently requires the puppetlabs/concat module on the Puppet Forge and uses
# storeconfigs on the Puppet Master to export/collect resources from all
# balancer members.
#
# === Parameters
#
# [*name*]
# The namevar of the defined resource type is the balancer clusters name.
# This name is also used in the name of the conf.d file
#
# [*proxy_set*]
# Hash, default empty. If given, each key-value pair will be used as a ProxySet
# line in the configuration.
#
# [*target*]
# String, default undef. If given, path to the file the balancer definition will
# be written.
#
# [*collect_exported*]
# Boolean, default 'true'. True means 'collect exported @@balancermember
# resources' (for the case when every balancermember node exports itself),
# false means 'rely on the existing declared balancermember resources' (for the
# case when you know the full set of balancermembers in advance and use
# apache::balancermember with array arguments, which allows you to deploy
# everything in 1 run)
#
#
# === Examples
#
# Exporting the resource for a balancer member:
#
# apache::balancer { 'puppet00': }
#
define apache::balancer (
  $proxy_set = {},
  $collect_exported = true,
  $target = undef,
) {
  include ::apache::mod::proxy_balancer

  if versioncmp($apache::mod::proxy_balancer::apache_version, '2.4') >= 0 {
    $lbmethod = $proxy_set['lbmethod'] ? {
      undef   => 'byrequests',
      default => $proxy_set['lbmethod'],
    }
    ensure_resource('apache::mod', "lbmethod_${lbmethod}")
  }

  if $target {
    $_target = $target
  } else {
    $_target = "${::apache::confd_dir}/balancer_${name}.conf"
  }

  concat { "apache_balancer_${name}":
    owner  => '0',
    group  => '0',
    path   => $_target,
    mode   => $::apache::file_mode,
    notify => Class['Apache::Service'],
  }

  concat::fragment { "00-${name}-header":
    target  => "apache_balancer_${name}",
    order   => '01',
    content => "<Proxy balancer://${name}>\n",
  }

  if $collect_exported {
    Apache::Balancermember <<| balancer_cluster == $name |>>
  }
  # else: the resources have been created and they introduced their
  # concat fragments. We don't have to do anything about them.

  concat::fragment { "01-${name}-proxyset":
    target  => "apache_balancer_${name}",
    order   => '19',
    content => inline_template("<% @proxy_set.keys.sort.each do |key| %> Proxyset <%= key %>=<%= @proxy_set[key] %>\n<% end %>"),
  }

  concat::fragment { "01-${name}-footer":
    target  => "apache_balancer_${name}",
    order   => '20',
    content => "</Proxy>\n",
  }
}
