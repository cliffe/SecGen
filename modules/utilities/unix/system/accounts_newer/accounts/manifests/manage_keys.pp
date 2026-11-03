# @summary
#   This resource manages ssh keys for a user.
#
# @param key_file
#   Specifies the path of the ssh key file.
#
# @param keyspec
#   Specifies the content of the ssh key file.
#
# @param user
#   Specifies the ssh login username.
#
# @param ensure
#   Specifies whether the keys will be added ('present') or removed ('absent').
#
# @param key_owner
#   Specifies the owner of the ssh key file.
#
# @api private
#
define accounts::manage_keys (
  Stdlib::Unixpath         $key_file,
  String                   $keyspec,
  Accounts::User::Name     $user,
  Enum['absent','present'] $ensure    = 'present',
  Accounts::User::Name     $key_owner = $user,
) {
  $key_def = accounts_ssh_authorized_keys_line_parser($keyspec)
  if (! $key_def) {
    err("Could not interpret SSH key definition: '${keyspec}'")
  }
  else {
    if (! empty($key_def[0])) {
      $key_options = accounts_ssh_options_parser($key_def[0]) # validates the options
    } else {
      $key_options = undef
    }
    $key_type    = $key_def[1]
    $key_content = $key_def[2]
    $key_md5     = md5($key_def[2])
    $key_name    = "${key_def[3]}_${key_md5}"

    $key_title = "${user}_${key_type}_${key_name}"

    # ssh_authorized_key is no longer part of Puppet's core types (it moved to the
    # sshkeys_core module), and the Puppet on SecGen's bookworm base doesn't ship it
    # ("Unknown resource type: 'ssh_authorized_key'"), so write the key line with
    # stdlib's file_line. key_management creates key_file with the right owner and
    # mode when keys are present, and removes the whole file when they are absent.
    if $ensure == 'present' {
      file_line { $key_title:
        ensure  => present,
        path    => $key_file,
        line    => strip($keyspec),
        require => File[$key_file],
      }
    }
  }
}
