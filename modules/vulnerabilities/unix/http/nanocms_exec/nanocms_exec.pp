# nanocms init
# https://cxsecurity.com/issue/WLB-2022080027
# https://github.com/kalyan02/NanoCMS
contain nanocms_exec::install
contain nanocms_exec::apache
contain nanocms_exec::configure
Class['nanocms_exec::install']
-> Class['nanocms_exec::apache']
-> Class['nanocms_exec::configure']
