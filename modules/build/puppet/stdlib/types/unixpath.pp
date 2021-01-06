# this regex rejects any path component that is a / or a NUL
type Stdlib::Unixpath = Pattern[/^\/([^\/\0]+\/*)*$/]
