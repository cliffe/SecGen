# Class lamp::apache
# This class installs Apache Web Server with help of puppetlabs-apache module with enabled PHP
#

class lamp::apache {
  class {'::apache':  mpm_module => 'prefork',}
  include ::apache::mod::php
}
