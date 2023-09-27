class python_crypto_libs::install{
  package { ['python3-pip', 'python3-numpy', 'python3-pycryptodome']:
    ensure => 'installed',
  }
}