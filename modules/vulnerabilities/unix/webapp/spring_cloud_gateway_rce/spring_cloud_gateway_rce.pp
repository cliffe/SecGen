contain spring_cloud_gateway_rce::install
contain spring_cloud_gateway_rce::configure
contain spring_cloud_gateway_rce::service
Class['spring_cloud_gateway_rce::install']
-> Class['spring_cloud_gateway_rce::configure']
-> Class['spring_cloud_gateway_rce::service']
