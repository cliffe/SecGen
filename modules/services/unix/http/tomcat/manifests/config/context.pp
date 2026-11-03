# @summary Configure attributes for the Context element in $CATALINA_BASE/conf/context.xml
#
# @param catalina_base
#   Specifies the root of the Tomcat installation.
# @param additional_attributes
#   Specifies any additional attributes to add to the Context. Should be a hash of the format 'attribute' => 'value'. Optional
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings. `[]`.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::context (
  Optional[Stdlib::Absolutepath] $catalina_base          = undef,
  Hash                           $additional_attributes  = {},
  Array                          $attributes_to_remove   = [],
  Boolean                        $show_diff              = true,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  $base_path = 'Context'

  if ! empty($additional_attributes) {
    $set_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${base_path}/#attribute/"), "'")

    # Extra augeas to add atttibutes if there are currently no attrributes in <Context> element
    augeas { "context-add_attribute_${_catalina_base}":
      incl    => "${catalina_base}/conf/context.xml",
      lens    => 'Xml.lns',
      context => "/files/${catalina_base}/conf/context.xml",
      changes => ['ins #attribute before Context/#text[1]'] + $set_additional_attributes,
      onlyif  => 'match Context/#attribute size == 0',
    }
  } else {
    $set_additional_attributes = undef
  }
  if ! empty(any2array($attributes_to_remove)) {
    $rm_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${base_path}/#attribute/")
  } else {
    $rm_attributes_to_remove = undef
  }

  $_watched_resource = 'set Context/WatchedResource/#text "WEB-INF/web.xml"'

  $changes = delete_undef_values(flatten([
        $_watched_resource,
        $set_additional_attributes,
        $rm_attributes_to_remove,
  ]))

  if ! empty($changes) {
    augeas { "context-${_catalina_base}":
      lens      => 'Xml.lns',
      incl      => "${_catalina_base}/conf/context.xml",
      changes   => $changes,
      show_diff => $show_diff,
    }
  }
}
