# @param catalina_base
# @param show_diff
define tomcat::config::example (
  Stdlin::Absolutepath $catalina_base = '/tmp',
  Boolean              $show_diff     = true,
) {
  include tomcat
}
