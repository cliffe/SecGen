contain gitlab_13102::install
contain gitlab_13102::configure
Class['gitlab_13102::install']
-> Class['gitlab_13102::configure']
