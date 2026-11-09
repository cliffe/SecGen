class apache_userdir_enum::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  $usernames = $secgen_parameters['usernames']

  # Enable mod_userdir and point it at /home/<user>/public_html.
  #
  # Indexes is deliberately dropped from the default options: with directory
  # listing off and no index file, a request for an existing user's public_html
  # returns 403 Forbidden, whereas a user without one returns 404 Not Found.
  # That 403-vs-404 difference is the username-enumeration oracle (CVE-2001-1013)
  # that auxiliary/scanner/http/apache_userdir_enum relies on.
  class { 'apache::mod::userdir':
    home         => '/home',
    dir          => 'public_html',
    disable_root => true,
    options      => ['SymLinksIfOwnerMatch', 'IncludesNoExec'],
  }

  # Create each valid account and its (empty) public_html directory. Real
  # accounts give the lab genuine usernames to discover; the empty public_html
  # with listing off is what makes /~user/ answer 403.
  if $usernames {
    $usernames.each |$username| {
      user { $username:
        ensure     => present,
        shell      => '/bin/bash',
        managehome => true,
      }

      # Home must be traversable by www-data so Apache can reach public_html and
      # return 403 (rather than 403-on-home) for an existing user.
      file { "/home/${username}":
        ensure  => directory,
        owner   => $username,
        group   => $username,
        mode    => '0755',
        require => User[$username],
      }

      file { "/home/${username}/public_html":
        ensure  => directory,
        owner   => $username,
        group   => $username,
        mode    => '0755',
        require => File["/home/${username}"],
      }
    }
  }
}
