# Entry point: enable mod_userdir on the required Apache service and create the
# accounts (with public_html directories) that the misconfiguration then leaks.
include apache_userdir_enum::config
