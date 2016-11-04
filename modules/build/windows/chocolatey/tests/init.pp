#class rich::packages {
  $pkg = 'notepadplusplus'

  package { $pkg:
    ensure          => 'latest',
    provider        => 'chocolatey',
  }
#}
