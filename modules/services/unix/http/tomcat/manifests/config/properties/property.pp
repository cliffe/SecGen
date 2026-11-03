# @summary Manage additional entries for the properties file, typically catalina.properties
#
# @param catalina_base
#   The catalina base of the catalina.properties file. The resource will manage the values in `${catalina_base}/conf/catalina.properties` . Required
# @param value
#   The value of the property. Required
# @param property
#   The name of the property. `$name`.
#
define tomcat::config::properties::property (
  Stdlib::Absolutepath $catalina_base,
  String[1] $value,
  String[1] $property = $name,
) {
  concat::fragment { "${catalina_base}/conf/catalina.properties property ${property}":
    target  => "${catalina_base}/conf/catalina.properties",
    content => "${property}=${value}",
  }
}
