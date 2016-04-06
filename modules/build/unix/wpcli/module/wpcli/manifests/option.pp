define wp::option (
	$location,
	$key = $title,
	$value = undef,
	$ensure = present
) {
	case $ensure {
		present: {
			$command = "get $key"
		}
		equal: {
			if $value == undef {
				fail('Option value must be specified')
			}
			$command = "update $key $value"
		}
		absent: {
			$command = "delete $key"
		}
		default: {
			fail('Invalid option operation')
		}
	}

	wp::command { "$location option $command":
		location => $location,
		command => "option $command"
	}
}