# Probably not needed
class gentoken {
  $packages = ["dmidecode"]
  package { $packages:
    ensure => "installed",
  }
}
