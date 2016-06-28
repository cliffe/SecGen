# class {'misconfig_root::parse_facter_data':}


class {'misconfig_root::change_root_permissions':
  files_to_change_permissions => {
    ### '/etc/shadow'
    # '/etc/shadow' => '0000', # Gives root only permissions
    '/etc/shadow' => '0644', # Gives write permissions to group members and other users
    # '/etc/shadow' => '0640', # Gives write permissions to group members
    # '/etc/shadow' => '0604', # Gives write permissions to any user
    # '/etc/shadow' => '0622', # Gives read permissions to group members and other users
    # '/etc/shadow' => '0602', # Gives read permissions to any user
    # '/etc/shadow' => '0602', # Gives read permissions to any user
    # '/etc/shadow' => '0600', # Gives read and write permissions to file owner
    # '/etc/shadow' => '0400', # Gives write permissions to file owner
    # '/etc/shadow' => '0200', # Gives read permissions to file owner
    ### '/etc/shadow-'
    # '/etc/shadow-' => '0000', # Gives root only permissions
    '/etc/shadow-' => '0644', # Gives write permissions to group members and other users
    # '/etc/shadow-' => '0640', # Gives write permissions to group members
    # '/etc/shadow-' => '0604', # Gives write permissions to any user
    # '/etc/shadow-' => '0622', # Gives read permissions to group members and other users
    # '/etc/shadow-' => '0602', # Gives read permissions to any user
    # '/etc/shadow-' => '0602', # Gives read permissions to any user
    # '/etc/shadow-' => '0600', # Gives read and write permissions to file owner
    # '/etc/shadow-' => '0400', # Gives write permissions to file owner
    # '/etc/shadow-' => '0200', # Gives read permissions to file owner

    ### '/etc/passwd'
    # '/etc/passwd' => '0000', # Gives root only permissions
    '/etc/passwd' => '0644', # Gives write permissions to group members and other users
    # '/etc/passwd' => '0640', # Gives write permissions to group members
    # '/etc/passwd' => '0604', # Gives write permissions to any user
    # '/etc/passwd' => '0622', # Gives read permissions to group members and other users
    # '/etc/passwd' => '0602', # Gives read permissions to any user
    # '/etc/passwd' => '0602', # Gives read permissions to any user


    ### '/etc/passwd-'
    # '/etc/passwd-' => '0000', # Gives root only permissions
    '/etc/passwd-' => '0644', # Gives write permissions to group members and other users
    # '/etc/passwd-' => '0640', # Gives write permissions to group members
    # '/etc/passwd-' => '0604', # Gives write permissions to any user
    # '/etc/passwd-' => '0622', # Gives read permissions to group members and other users
    # '/etc/passwd-' => '0602', # Gives read permissions to any user
    # '/etc/passwd-' => '0602', # Gives read permissions to any user
    # '/etc/passwd-' => '0600', # Gives read and write permissions to file owner
    # '/etc/passwd-' => '0400', # Gives write permissions to file owner
    # '/etc/passwd-' => '0200', # Gives read permissions to file owner

    ### '/etc/gshadow'
    # '/etc/gshadow' => '0000', # Gives root only permissions
    '/etc/gshadow' => '0644', # Gives write permissions to group members and other users
    # '/etc/gshadow' => '0640', # Gives write permissions to group members
    # '/etc/gshadow' => '0604', # Gives write permissions to any user
    # '/etc/gshadow' => '0622', # Gives read permissions to group members and other users
    # '/etc/gshadow' => '0602', # Gives read permissions to any user
    # '/etc/gshadow' => '0602', # Gives read permissions to any user
    # '/etc/gshadow' => '0600', # Gives read and write permissions to file owner
    # '/etc/gshadow' => '0400', # Gives write permissions to file owner
    # '/etc/gshadow' => '0200', # Gives read permissions to file owner

    ### '/etc/gshadow-'
    # '/etc/gshadow-' => '0000', # Gives root only permissions
    '/etc/gshadow-' => '0644', # Gives write permissions to group members and other users
    # '/etc/gshadow-' => '0640', # Gives write permissions to group members
    # '/etc/gshadow-' => '0604', # Gives write permissions to any user
    # '/etc/gshadow-' => '0622', # Gives read permissions to group members and other users
    # '/etc/gshadow-' => '0602', # Gives read permissions to any user
    # '/etc/gshadow-' => '0602', # Gives read permissions to any user
    # '/etc/gshadow-' => '0600', # Gives read and write permissions to file owner
    # '/etc/gshadow-' => '0400', # Gives write permissions to file owner
    # '/etc/gshadow-' => '0200', # Gives read permissions to file owner

    ### '/etc/group'
    # '/etc/group' => '0000', # Gives root only permissions
    '/etc/group' => '0644', # Gives write permissions to group members and other users
    # '/etc/group' => '0640', # Gives write permissions to group members
    # '/etc/group' => '0604', # Gives write permissions to any user
    # '/etc/group' => '0622', # Gives read permissions to group members and other users
    # '/etc/group' => '0602', # Gives read permissions to any user
    # '/etc/group' => '0602', # Gives read permissions to any user
    # '/etc/group' => '0600', # Gives read and write permissions to file owner
    # '/etc/group' => '0400', # Gives write permissions to file owner
    # '/etc/group' => '0200', # Gives read permissions to file owner

    ### '/etc/group-'
    # '/etc/group-' => '0644', # Gives root only permissions
    '/etc/group-' => '0644', # Gives write permissions to group members and other users
    # '/etc/group-' => '0640', # Gives write permissions to group members
    # '/etc/group-' => '0604', # Gives write permissions to any user
    # '/etc/group-' => '0622', # Gives read permissions to group members and other users
    # '/etc/group-' => '0602', # Gives read permissions to any user
    # '/etc/group-' => '0602', # Gives read permissions to any user
    # '/etc/group-' => '0600', # Gives read and write permissions to file owner
    # '/etc/group-' => '0400', # Gives write permissions to file owner
    # '/etc/group-' => '0200', # Gives read permissions to file owner

    ### '/etc/fstab'
    '/etc/fstab' => '0664', # Gives write and read access to group members and write access to other users

    ### '/etc/profile'
    '/etc/profile' => '0644', # Gives write access to both group members and other users

    ### '/etc/sudoers'
    # '/etc/sudoers' => '0000', # Gives root only permissions
    '/etc/sudoers' => '0444', # Gives write access to group members and other users
    # '/etc/sudoers' => '0440', # Gives write access to group members
    # '/etc/sudoers' => '0404', # Gives write access to other users
    # '/etc/sudoers' => '0600', # Gives read and write permissions to file owner
    # '/etc/sudoers' => '0400', # Gives write permissions to file owner
    # '/etc/sudoers' => '0200', # Gives read permissions to file owner
  }
}