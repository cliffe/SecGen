contain tikiwiki_cal_rce_unauth::install
contain tikiwiki_cal_rce_unauth::maria
contain tikiwiki_cal_rce_unauth::apache
contain tikiwiki_cal_rce_unauth::tiki_install
contain tikiwiki_cal_rce_unauth::configure
Class['tikiwiki_cal_rce_unauth::install']
-> Class['tikiwiki_cal_rce_unauth::maria']
-> Class['tikiwiki_cal_rce_unauth::apache']
-> Class['tikiwiki_cal_rce_unauth::tiki_install']
-> Class['tikiwiki_cal_rce_unauth::configure']
