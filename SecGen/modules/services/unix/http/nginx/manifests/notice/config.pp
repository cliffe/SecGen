class nginx::notice::config {
  $message = "[nginx] *** DEPRECATION WARNING***: HI! I notice that you're declaring some attributes in Class[nginx]. It is highly recommended to set these values via Hiera going forward. This will become mandatory in the near future. Please check out https://github.com/jfryman/puppet-nginx/blob/master/docs/hiera.md for more information."

  notify { $message: }
}
