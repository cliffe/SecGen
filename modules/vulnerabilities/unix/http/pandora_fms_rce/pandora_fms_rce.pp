
contain pandora_fms_rce::install
contain pandora_fms_rce::lamp 
contain pandora_fms_rce::pandora
Class['pandora_fms_rce::install'] ->
Class['pandora_fms_rce::lamp'] ->
Class['pandora_fms_rce::pandora'] 