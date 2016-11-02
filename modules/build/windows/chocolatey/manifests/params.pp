# chocolatey::params - Default parameters
class chocolatey::params {
  $install_location         = $::choco_install_path # default is C:\ProgramData\chocolatey
  $download_url             = 'https://chocolatey.org/api/v2/package/chocolatey/'
  $use_7zip                 = false
  $install_timeout_seconds  = 1500
  $enable_autouninstaller   = true
  $chocolatey_version       = $::chocolateyversion
}
