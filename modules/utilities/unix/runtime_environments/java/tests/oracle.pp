java::oracle { 'jdk6' :
  ensure  => 'present',
  version => '6',
  java_se => 'jdk',
}
