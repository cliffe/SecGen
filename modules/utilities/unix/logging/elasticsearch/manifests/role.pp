# Manage shield/x-pack roles.
#
# @param ensure
#   Whether the role should be present or not.
#   Set to 'absent' to ensure a role is not present.
#
# @param mappings
#   A list of optional mappings defined for this role.
#
# @param privileges
#   A hash of permissions defined for the role. Valid privilege settings can
#   be found in the Shield/x-pack documentation.
#
# @example create and manage the role 'power_user' mapped to an LDAP group.
#   elasticsearch::role { 'power_user':
#     privileges => {
#       'cluster' => 'monitor',
#       'indices' => {
#         '*' => 'all',
#       },
#     },
#     mappings => [
#       "cn=users,dc=example,dc=com",
#     ],
#   }
#
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
define elasticsearch::role (
  Enum['absent', 'present'] $ensure     = 'present',
  Array                     $mappings   = [],
  Hash                      $privileges = {},
) {
  validate_slength($name, 30, 1)
  if $elasticsearch::security_plugin == undef {
    fail("\"${elasticsearch::security_plugin}\" required")
  }

  if empty($privileges) or $ensure == 'absent' {
    $_role_ensure = 'absent'
  } else {
    $_role_ensure = $ensure
  }

  if empty($mappings) or $ensure == 'absent' {
    $_mapping_ensure = 'absent'
  } else {
    $_mapping_ensure = $ensure
  }

  elasticsearch_role { $name :
    ensure     => $_role_ensure,
    privileges => $privileges,
  }

  elasticsearch_role_mapping { $name :
    ensure   => $_mapping_ensure,
    mappings => $mappings,
  }
}
