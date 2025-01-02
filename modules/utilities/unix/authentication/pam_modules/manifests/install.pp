class pam_modules::install {
  # Security and Access Control Modules
  # Provides brute force protection, two-factor auth, and biometric authentication
  ensure_packages(['libpam-abl', 'libpam-google-authenticator', 'libpam-oath'])
  ensure_packages(['libqrencode4'])
  # not installed: 'libpam-barada', 'libpam-biometric'

  # Authentication Backend Modules
  # Provides integration with various authentication systems like LDAP, MySQL, Kerberos
  ensure_packages(['libpam-ldapd', 'libpam-mysql', 'libpam-krb5',
                 'libpam-heimdal'])

  # Storage and Encryption Modules
  # Handles encrypted filesystems and mount operations
  ensure_packages(['libpam-mount', 'libpam-encfs', 'libpam-fscrypt'])

  # Password Quality and Policy Modules
  # Enforces password strength and policies
  ensure_packages(['libpam-passwdqc', 'libpam-pwdfile', 'libpam-pwquality'])

  # System Integration Modules
  # Handles system-level integration with cgroups, chroot, and namespaces
  # ensure_packages(['libpam-cgfs', 'libpam-cgroup', 'libpam-chroot',
  #               'libpam-net', 'libpam-cap'])

  # Smart Card and Hardware Token Modules
  # Enables authentication using PKCS#11 smart cards and hardware tokens
  #ensure_packages(['libpam-p11', 'libpam-pkcs11', 'libpam-poldi'])

  # Desktop Environment Integration
  # Provides integration with desktop environments and wallets
  #ensure_packages(['libpam-gnome-keyring', 'libpam-kwallet5',
  #               'libpam-kwallet-common'])

}
