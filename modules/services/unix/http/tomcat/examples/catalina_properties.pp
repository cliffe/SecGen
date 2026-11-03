tomcat::config::properties { "${_catalina_base} catalina.properties":
  catalina_home => $_catalina_home,
  catalina_base => $_catalina_base,
  user          => $_user,
  group         => $_group,
}
