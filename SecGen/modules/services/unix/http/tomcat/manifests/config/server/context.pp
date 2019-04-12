# Definition tomcat::config::server::context
#
# Configure a Context element in $CATALINA_BASE/conf/server.xml
#
# Parameters:
# - $catalina_base is the root of the Tomcat installation
# - $context_ensure specifies whether you are trying to add or remove the Context
#   element. Valid values are 'true', 'false', 'present', or 'absent'. Defaults
#   to 'present'.
# - $doc_base is the docBase attribute of the Context.
#   If not specified, defaults to $name.
# - $parent_service is the Service element this Context should be nested beneath.
#   Defaults to 'Catalina'.
# - $parent_engine is the `name` attribute to the Engine element the Host of this Context 
#   should be nested beneath. Only valid if $parent_host is specified.
# - $parent_host is the `name` attribute to the Host element this Context
#   should be nested beneath.
# - An optional hash of $additional_attributes to add to the Context. Should be of
#   the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Context.
#
define tomcat::config::server::context (
  $catalina_base         = undef,
  $context_ensure        = 'present',
  $doc_base              = undef,
  $parent_service        = undef,
  $parent_engine         = undef,
  $parent_host           = undef,
  $additional_attributes = {},
  $attributes_to_remove  = [],
  $server_config         = undef,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($context_ensure, '^(present|absent|true|false)$')
  validate_hash($additional_attributes)
  validate_array($attributes_to_remove)

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

  if $parent_host and ! $_parent_engine {
    $path = "Server/Service[#attribute/name='${_parent_service}']/Engine/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${_doc_base}']"
  } elsif $parent_host and $_parent_engine {
    $path = "Server/Service[#attribute/name='${_parent_service}']/Engine[#attribute/name='${_parent_engine}']/Host[#attribute/name='${parent_host}']/Context[#attribute/docBase='${_doc_base}']"
  } else {
    $path = "Server/Service[#attribute/name='${_parent_service}']/Engine/Host/Context[#attribute/docBase='${_doc_base}']"
  }

  if $context_ensure =~ /^(absent|false)$/ {
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
    lens    => 'Xml.lns',
    incl    => $_server_config,
    changes => $augeaschanges,
  }
}
