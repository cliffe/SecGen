## manage additional entries for the properties file, typically catalina.properties
define tomcat::config::properties::property (
  $catalina_base,
  $value,
  $property = $name,
) {
  concat::fragment { "${catalina_base}/conf/catalina.properties property ${property}":
    target  => "${catalina_base}/conf/catalina.properties",
    content => "${property}=${value}",
  }
}
