class internet_explorer_11::install {
  include chocolatey

  notice('Installing Internet Explorer 11')

  package { 'ie11':
    ensure   => installed,
    provider => 'chocolatey',
  }
}