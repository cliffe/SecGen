class { 'nginx': }

nginx::resource::vhost{ 'www.myhost.com':
  www_root => '/usr/share/nginx/html',
}