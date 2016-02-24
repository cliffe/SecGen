  class cleanup::config {
# removes bash history
  exec { "rm":
      command => "rm -rf .bash_history",
      path    => "/bin/",
  }
# finds every file and modifies with date may 2006
# todo: CW - find a way to do this quicker, as it takes the most of the time when spinning up a vm, also commented out for testing purposes
#  exec { "find":
#	  command => "find / -exec touch -d '17 May 2006 14:16' {} \\;",
#	  path => "/usr/bin/",
#   timeout => 5000
#  }

# disables eth1 which runs the public network for each vulnerable machine 
#  vagrant runs over 10.0 for eth0 .. eth1 for public .. and eth2 for private.

    exec { "ifconfig":
	  command => "ifconfig eth1 down",
	  path => "/sbin/",
  }
# changes default vagrant password, would kind of be pointless if they could just ssh to vagrant/vagrant :P
# this never worked.
# user {
#    'vagrant':
#      ensure => present,
#      password => 'superdupersecurepassword',
# }

  # or you can remove the user entierly, up to you 'but i you are playing around with vagrant might cause problems'
  #use this option only when you are rolling out to users.

  #   user { 'vagrant':
  #     uid => '444',
  #     gid => '444',
  #     ensure => 'absent',
  #     password => '!'
  # }

}