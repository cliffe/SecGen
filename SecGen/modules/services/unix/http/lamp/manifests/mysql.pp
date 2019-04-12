# Class lamp::mysql
# This class installs mysql database server from puppetlabs-mysql module as a LAMP component

class lamp::mysql {

 include ::mysql::server

}
