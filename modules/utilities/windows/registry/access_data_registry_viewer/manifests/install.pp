class access_data_registry_viewer::install {
  include chocolatey

  package { 'access-data-registry-viewer':
    ensure   => installed,
    provider => 'chocolatey',
  }
}