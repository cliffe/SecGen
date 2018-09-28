class add_registry_keys ($key_locations) {
  # $key_locations.each | Integer $index, String $key_location | {
    registry_key { $key_locations:
      ensure => present,
    }
  # }
}