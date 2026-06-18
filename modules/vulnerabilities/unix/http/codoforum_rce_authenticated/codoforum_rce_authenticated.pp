# begining of puppet code execution
#force sequential install -> apache -> configure ordering

contain codoforum_rce_authenticated::install
contain codoforum_rce_authenticated::apache
contain codoforum_rce_authenticated::mysql
contain codoforum_rce_authenticated::configure
Class['codoforum_rce_authenticated::install'] ->
Class['codoforum_rce_authenticated::apache'] ->
Class['codoforum_rce_authenticated::mysql']->
Class['codoforum_rce_authenticated::configure'] 
