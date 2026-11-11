# Minimal plain-Java web app that logs a request header through log4j 2.14.1.
contain minimal_log4j_webapp::install
contain minimal_log4j_webapp::service
Class['minimal_log4j_webapp::install']
-> Class['minimal_log4j_webapp::service']
