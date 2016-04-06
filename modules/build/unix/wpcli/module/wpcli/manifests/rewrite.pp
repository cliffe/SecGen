define wp::rewrite (
	$location,
	$structure = $title
) {
	include wp::cli

	wp::command { "$location rewrite structure '$structure'":
		location => $location,
		command => "rewrite structure '$structure'"
	}
}