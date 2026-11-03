# Installs iptables and (on Debian) iptables-persistent, and enables netfilter-persistent,
# via the bundled puppetlabs/firewall class. Previously this file was empty, so
# only the firewall type was available and nothing was installed.
include firewall
