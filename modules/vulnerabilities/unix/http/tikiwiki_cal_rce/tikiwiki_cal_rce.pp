contain tikiwiki_cal_rce::install
contain tikiwiki_cal_rce::maria
contain tikiwiki_cal_rce::apache
contain tikiwiki_cal_rce::tiki_install
contain tikiwiki_cal_rce::configure
Class['tikiwiki_cal_rce::install']
-> Class['tikiwiki_cal_rce::maria']
-> Class['tikiwiki_cal_rce::apache']
-> Class['tikiwiki_cal_rce::tiki_install']
-> Class['tikiwiki_cal_rce::configure']
