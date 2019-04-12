# private
define tomcat::instance::dependencies (
  $catalina_home,
  $catalina_base,
) {
  $home_sha = sha1($catalina_home)
  $base_sha = sha1($catalina_base)

  Tomcat::Install                      <| tag == $base_sha or tag == $home_sha |>
  -> Tomcat::Service                   <| tag == $base_sha |>

  Tomcat::Install                      <| tag == $base_sha or tag == $home_sha |>
  -> Tomcat::Instance::Copy_from_home  <| tag == $base_sha |>
  -> Tomcat::Service                   <| tag == $base_sha |>

  Tomcat::Install                      <| tag == $base_sha or tag == $home_sha |>
  -> Tomcat::Service                   <| tag == $base_sha |>
  -> Tomcat::Config::Properties        <| tag == $base_sha |>
  Tomcat::Instance::Copy_from_home     <| tag == $base_sha |>
  -> Tomcat::Config::Properties        <| tag == $base_sha |>

  Tomcat::Install                      <| tag == $base_sha or tag == $home_sha |>
  -> Tomcat::Config::Server            <| tag == $base_sha |>
  ~> Tomcat::Service                   <| tag == $base_sha |>
  Tomcat::Instance::Copy_from_home     <| tag == $base_sha |>
  -> Tomcat::Config::Server            <| tag == $base_sha |>

  Tomcat::Install                      <| tag == $base_sha or tag == $home_sha |>
  -> Tomcat::Config::Server::Realm     <| tag == $base_sha |>
  ~> Tomcat::Service                   <| tag == $base_sha |>
  Tomcat::Instance::Copy_from_home     <| tag == $base_sha |>
  -> Tomcat::Config::Server::Realm     <| tag == $base_sha |>

  Tomcat::Install                      <| tag == $base_sha or tag == $home_sha |>
  -> Tomcat::Config::Server::Connector <| tag == $base_sha |>
  ~> Tomcat::Service                   <| tag == $base_sha |>
  Tomcat::Instance::Copy_from_home     <| tag == $base_sha |>
  -> Tomcat::Config::Server::Connector <| tag == $base_sha |>

  Tomcat::Install                      <| tag == $base_sha or tag == $home_sha |>
  -> Tomcat::Setenv::Entry             <| tag == $base_sha |>
  -> Tomcat::Service                   <| tag == $base_sha |>

  Tomcat::Install                      <| tag == $base_sha or tag == $home_sha |>
  -> Tomcat::War                       <| tag == $base_sha |>
  -> Tomcat::Service                   <| tag == $base_sha |>
}
