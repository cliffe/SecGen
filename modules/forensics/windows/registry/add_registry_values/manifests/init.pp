class add_registry_values($key_location, $key_value_type, $key_value) {

  # $key_locations.each | Integer $index, String $key_location | {
    registry_key { $key_location:
      ensure => present,
    }

    registry_value { $key_location:
      ensure => present,
      type   => $key_value_type,
      data   => $key_value,
    }
    # }
}