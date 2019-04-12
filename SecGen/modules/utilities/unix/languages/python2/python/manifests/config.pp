# == Define: python::config
#
# Optionally installs the gunicorn service
#
# === Examples
#
# include python::config
#
# === Authors
#
# Sergey Stankevich
# Ashley Penney
# Fotis Gimian
#

class python::config {

  Class['python::install'] -> Python::Pip <| |>
  Class['python::install'] -> Python::Requirements <| |>
  Class['python::install'] -> Python::Virtualenv <| |>

  Python::Virtualenv <| |> -> Python::Pip <| |>

  if $python::manage_gunicorn {
    if $python::gunicorn != 'absent' {
      Class['python::install'] -> Python::Gunicorn <| |>

      Python::Gunicorn <| |> ~> Service['gunicorn']

      service { 'gunicorn':
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => false,
        pattern    => '/usr/bin/gunicorn',
      }
    }
  }

}
