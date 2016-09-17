######################################################
##### Purge all existing firewall rules (if any) #####
######################################################
resources { 'firewall':
  purge => true,
}

#####################################################
##### Default rules defined before custom rules #####
#####################################################
class pre {
  Firewall {
    require => undef,
  }
  # Default firewall rules
  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 reject local traffic not on loopback interface':
    iniface     => '! lo',
    proto       => 'all',
    destination => '127.0.0.1/8',
    action      => 'reject',
  }->
  firewall { '003 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }
}

######################################################
##### Custom rules defined between default rules #####
######################################################

# firewall { '004 custom rule example':
#   proto  => 'all',
#   state  => ['RELATED', 'ESTABLISHED'],
#   action => 'accept',
# }
#
# firewall { '005 custom rule example':
#   proto  => 'all',
#   state  => ['RELATED', 'ESTABLISHED'],
#   action => 'accept',
# }
#
# firewall { '006 custom rule example':
#   proto  => 'all',
#   state  => ['RELATED', 'ESTABLISHED'],
#   action => 'drop',
# }

####################################################
##### Default rules defined after custom rules #####
####################################################
class post {
  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }
}

Firewall {
  before  => Class['post'],
  require => Class['pre'],
}

class { ['pre', 'post']: }

class { 'firewall': }