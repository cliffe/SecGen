contain jenkins_cli::install
contain jenkins_cli::configure
Class['jenkins_cli::install']
-> Class['jenkins_cli::configure']
