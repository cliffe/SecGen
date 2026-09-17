# begining of puppet code execution

contain elfinder::install
contain elfinder::apache
contain elfinder::configure
Class['elfinder::install'] ->
Class['elfinder::apache'] ->
Class['elfinder::configure'] 