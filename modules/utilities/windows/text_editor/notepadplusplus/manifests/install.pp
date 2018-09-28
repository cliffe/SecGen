class notepadplusplus::install {
  include chocolatey

  notice('Installing notepad++')

  package { 'notepadplusplus':
    ensure   => installed,
    provider => 'chocolatey',
  }

  notice('Notepad++ install finished')
}