class chkrootkit::configure {
  # Add cron job for chkrootkit, run it every minute so it's exploitable without a wait
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $cron_frequency = $secgen_parameters['cron_frequency'][0]

  case $cron_frequency {
    '1_minute': { $minute_frequency = '*' }
    '5_minutes': { $minute_frequency = '*/5' }
    '15_minutes': { $minute_frequency = '*/15' }
    '30_minutes': { $minute_frequency = '*/30' }
    default: { $minute_frequency = '*' }
  }

  cron { 'chkrootkit':
    command => '/usr/sbin/chkrootkit',
    user    => 'root',
    hour    => '*',
    minute  => $minute_frequency,
  }
}