include nginx

nginx::resource::location { 'www.test.com-params':
    ensure        => present,
    location      => '/some/url',
    vhost         => 'www.test.com',
    fastcgi_param => {
      'APP_ENV'     => 'production',
      'APP_VERSION' => '0.1.10',
      'APP_SECRET'  => 'hisfaihicasagfkjsa',
    },
}
