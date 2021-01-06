# Class to test deftype
define test::deftype( $param = 'foo' ) {
  notify { "deftype: ${title}": }
}
