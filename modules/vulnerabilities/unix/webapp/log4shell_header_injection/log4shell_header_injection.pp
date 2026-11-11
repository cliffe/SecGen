# Log4Shell JNDI header injection (CVE-2021-44228).
# The vulnerable log4j service is the required minimal_log4j_webapp module; this
# module only leaks the flag the exploit shell reads.
include log4shell_header_injection::configure
