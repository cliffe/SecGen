# @summary Configure a Context element in $CATALINA_BASE/conf/server.xml
#
# @param catalina_base
#   Specifies the base directory of the Tomcat installation to manage. Valid options: a string containing an absolute path.
# @param context_ensure
#   Specifies whether the [Context XML element](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html) should exist in the configuration file.
# @param doc_base
#   Specifies a Document Base (or Context Root) directory or archive file. Maps to the [docBase XML attribute](http://tomcat.apache.org/tomcat-8.0-doc/config/context.html#Common_Attributes). Valid options: a string containing a path (either an absolute path or a path relative to the appBase directory of the owning Host). `$name`.
# @param parent_service
#   Specifies which Service XML element the Context should nest under. Valid options: a string containing the name attribute of the Service.
# @param parent_engine
#   Specifies which Engine element the Context should nest under. Only valid if `parent_host` is specified. Valid options: a string containing the name attribute of the Engine.
# @param parent_host
#   Specifies which Host element the Context should nest under. Valid options: a string containing the name attribute of the Host.
# @param additional_attributes
#   Specifies any further attributes to add to the Context. Valid options: a hash of '< attribute >' => '< value >' pairs.
# @param attributes_to_remove
#   Specifies an array of attributes to remove from the element. Valid options: an array of strings.
# @param server_config
#   Specifies a server.xml file to manage. Valid options: a string containing an absolute path.
# @param show_diff
#   Specifies display differences when augeas changes files, defaulting to true. Valid options: true or false.
#
define tomcat::config::server::context (
  Optional[Stdlib::Absolutepath] $catalina_base         = undef,
  Enum['present','absent']       $context_ensure        = 'present',
  Optional[String[1]]            $doc_base              = undef,
  Optional[String[1]]            $parent_service        = undef,
  Optional[String[1]]            $parent_engine         = undef,
  Optional[String[1]]            $parent_host           = undef,
  Hash                           $additional_attributes = {},
  Array                          $attributes_to_remove  = [],
  Optional[String[1]]            $server_config         = undef,
  Boolean                        $show_diff             = true,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($facts['augeas']['version'], '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  if $doc_base {
    $_doc_base = $doc_base
  } else {
    $_doc_base = $name
  }

  if $parent_service {
    $_parent_service = $parent_service
  } else {
    $_parent_service = 'Catalina'
  }

  if $parent_engine and ! $parent_host {
    warning('context elements cannot be nested directly under engine elements, ignoring $parent_engine')
  }

  if $parent_engine and $parent_host {
    $_parent_engine = $parent_engine
  } else {
    $_parent_engine = undef
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  # lint:ignore:140chars
  if $parent_host and ! $_parent_engine {
    $path = "Server/Service[#attribute/name='${_parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${_doc_base}']"
  } elsif $parent_host and $_parent_engine {
    $path = "Server/Service[#attribute/name='${_parent_service}']/Engine[#attribute/name='${_parent_engine}']/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${_doc_base}']"
  } else {
    $path = "Server/Service[#attribute/name='${_parent_service}']/Engine/Host/Context[#attribute/docBase='${_doc_base}']"
  }
  # lint:endignore

  if $context_ensure == 'absent' {
    $augeaschanges = "rm ${path}"
  } else {
    $context = "set ${path}/#attribute/docBase ${_doc_base}"

    if ! empty($additional_attributes) {
      $_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${path}/#attribute/"), "'")
    } else {
      $_additional_attributes = undef
    }

    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${path}/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }

    $augeaschanges = delete_undef_values(flatten([$context, $_additional_attributes, $_attributes_to_remove]))
  }

  augeas { "${_catalina_base}-${_parent_service}-${_parent_engine}-${parent_host}-context-${name}":
    lens      => 'Xml.lns',
    incl      => $_server_config,
    changes   => $augeaschanges,
    show_diff => $show_diff,
  }
}
