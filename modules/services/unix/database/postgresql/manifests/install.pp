# Installs the Debian PostgreSQL server (15 on bookworm) and client.
class postgresql::install {
  ensure_packages(['postgresql', 'postgresql-client'])
}
