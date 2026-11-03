# @summary Manage the catalina.properties file
#
# @api private
#
define tomcat::config::properties (
  Stdlib::Absolutepath $catalina_base,
  String[1]            $catalina_home,
  String[1]            $user,
  String[1]            $group,
) {
  tag(sha1($catalina_base))
  tag(sha1($catalina_home))
  concat { "${catalina_base}/conf/catalina.properties":
    ensure_newline => true,
    owner          => $user,
    group          => $group,
    mode           => '0640',
  }
  concat::fragment { "${catalina_base} properties base file from catalina_home ${$catalina_home}/conf/catalina.properties":
    target => "${catalina_base}/conf/catalina.properties",
    source => "${catalina_home}/conf/catalina.properties",
    order  => '01',
  }
}
