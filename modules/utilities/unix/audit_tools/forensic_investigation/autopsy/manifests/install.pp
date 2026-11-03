class autopsy::install {
  # autopsy is a front end to The Sleuth Kit; the package depends on it, but
  # declare it so the CLI tools (fls, icat) the test and labs use are guaranteed.
  # ensure_packages avoids a duplicate declaration if another module wants it.
  ensure_packages(['sleuthkit'])

  package { 'autopsy':
    ensure  => installed,
    require => Package['sleuthkit'],
  }
}
