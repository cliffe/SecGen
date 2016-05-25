# Base class. Declares default vhost on port 80 with filters.
class { 'apache': }

# Example from README adapted.
apache::vhost { 'readme.example.net':
  docroot => '/var/www/html',
  filters => [
    'FilterDeclare   COMPRESS',
    'FilterProvider  COMPRESS  DEFLATE resp=Content-Type $text/html',
    'FilterProvider  COMPRESS  DEFLATE resp=Content-Type $text/css',
    'FilterProvider  COMPRESS  DEFLATE resp=Content-Type $text/plain',
    'FilterProvider  COMPRESS  DEFLATE resp=Content-Type $text/xml',
    'FilterChain     COMPRESS',
    'FilterProtocol  COMPRESS  DEFLATE change=yes;byteranges=no',
  ],
}

