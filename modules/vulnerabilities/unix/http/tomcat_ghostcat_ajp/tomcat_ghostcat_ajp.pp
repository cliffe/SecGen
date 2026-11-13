# CVE-2020-1938 "Ghostcat": expose Tomcat's AJP connector on all interfaces
# with request-attribute injection re-enabled, so an unauthenticated attacker
# can read files under the web application (WEB-INF/*) over AJP.
include tomcat_ghostcat_ajp::configure
