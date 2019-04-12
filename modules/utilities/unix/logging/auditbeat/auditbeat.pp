$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
$logstash_ip = $secgen_parameters['logstash_ip'][0]
$logstash_port = 0 + $secgen_parameters['logstash_port'][0]
$files_to_audit = $secgen_parameters['files_to_audit']
# TODO - check if we need this (or are account accesses automatically audited)?
# Even if we don't need it - we will need to add the accounts to watch into the 'watchers' section when we reach that point.
# $accounts_to_audit = $secgen_parameters['accounts_to_audit']

class { 'auditbeat':
  modules => [
    # {
    #   'module'  => 'file_integrity',
    #   'enabled' => true,
    #   'paths'   => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', '/etc'],
    # },
    {
      'module'  => 'auditd',
      'enabled' => true,
      'audit_rules' => template('auditbeat/audit_rules.erb'),
    },
  ],
  outputs => {
    'logstash' => {
      'hosts' => ["$logstash_ip:$logstash_port"],
    },
  },
}