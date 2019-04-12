# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html

class { 'golang':
  version   => '1.7.3',
  workspace => '/usr/local/src/go',
}
