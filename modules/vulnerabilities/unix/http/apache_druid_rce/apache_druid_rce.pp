# Apache Druid 0.20 - RCE 
# https://github.com/rapid7/metasploit-framework/blob/master/modules/exploits/linux/http/apache_druid_js_rce.rb
# https://github.com/rapid7/metasploit-framework/blob/master/documentation/modules/exploit/linux/http/apache_druid_js_rce.md
contain apache_druid_rce::install
contain apache_druid_rce::configure
contain apache_druid_rce::service
Class['apache_druid_rce::install']
-> Class['apache_druid_rce::configure']
-> Class['apache_druid_rce::service']
