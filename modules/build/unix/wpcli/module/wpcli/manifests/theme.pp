define wp::theme (
	$location,
	$ensure = enabled
) {
	#$name = $title,
	include wp::cli

	case $ensure {
		enabled: {
			$command = "activate $title"
		}
		default: {
			fail("Invalid ensure for wp::theme")
		}
	}
	wp::command { "$location theme $command":
		location => $location,
		command => "theme $command"
	}
}