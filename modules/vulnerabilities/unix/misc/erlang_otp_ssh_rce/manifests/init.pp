class erlang_otp_ssh_rce {
  contain erlang_otp_ssh_rce::install
  contain erlang_otp_ssh_rce::config
  contain erlang_otp_ssh_rce::service

  Class['erlang_otp_ssh_rce::install']
    -> Class['erlang_otp_ssh_rce::config']
    -> Class['erlang_otp_ssh_rce::service']
}