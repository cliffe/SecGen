class hosts::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)

  # The declared read_fact is 'hostnames'. Older scenarios feed the same list
  # in as 'hosts', so accept that as a fallback.
  $hostnames = $secgen_parameters['hostnames'] ? {
    undef   => $secgen_parameters['hosts'],
    default => $secgen_parameters['hostnames'],
  }
  $ip_addresses = $secgen_parameters['IP_addresses']
  if $hostnames and $ip_addresses {
    $hostnames.each |$index, $hostname| {
      host { $hostname:
        ensure => present,
        ip     => $ip_addresses[$index],
      }
    }
  }
}
