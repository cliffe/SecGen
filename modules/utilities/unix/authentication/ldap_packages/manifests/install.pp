class ldap_packages::install {
  # LDAP Client Utilities
  # Provides command-line tools for interacting with LDAP directories
  ensure_packages(['ldap-utils'])

  # Pre-seed debconf so nslcd and libnss-ldapd install without prompting.
  # Placeholder server settings; the packages are installed, not configured.
  exec { 'preseed-nslcd':
    command => "/bin/echo 'nslcd nslcd/ldap-uris string ldap://127.0.0.1/' | /usr/bin/debconf-set-selections && /bin/echo 'nslcd nslcd/ldap-base string dc=example,dc=com' | /usr/bin/debconf-set-selections && /bin/echo 'libnss-ldapd libnss-ldapd/nsswitch multiselect' | /usr/bin/debconf-set-selections",
    unless  => '/usr/bin/dpkg-query -W -f=\'${Status}\' nslcd 2>/dev/null | /bin/grep -q "install ok installed"',
  }

  # NSS and PAM LDAP Integration
  # Enables system authentication and name service lookups via LDAP.
  # libnss-ldap and libpam-ldap are not in Debian 12 (bookworm); libnss-ldapd
  # and libpam-ldapd (nss-pam-ldapd) replace them and provide the same
  # libnss_ldap.so.2 and pam_ldap.so.
  # NSS LDAP Daemon (nslcd) performs the LDAP queries for NSS and PAM
  package { ['libnss-ldapd', 'libpam-ldapd', 'nslcd']:
    ensure  => installed,
    require => Exec['preseed-nslcd'],
  }

  # Name Service Cache Daemon
  # Caches name service lookups to improve performance
  ensure_packages(['nscd'])

  # System Security Services Daemon
  # Provides access to identity and authentication remote resource providers
  ensure_packages(['sssd'])
}
