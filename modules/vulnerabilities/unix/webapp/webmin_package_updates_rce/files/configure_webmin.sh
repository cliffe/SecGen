#!/bin/bash
# Configure a freshly installed Webmin 1.996 for the CVE-2022-36446 lab:
#   - bind miniserv to the requested port (SSL stays on, as the .deb sets it)
#   - create a Webmin-native administrator account with the given credentials
#     and grant it every module (so it can reach Software Package Updates, the
#     module the exploit abuses)
#
# Webmin's postinst only sets up the `root` login, which authenticates against
# the Unix root password through PAM. The exploit needs a login whose password
# we control from a datastore, so this creates a dedicated webmin-native user
# instead of touching the system root password.
#
# Credentials and port come from the environment (WEBMIN_USER, WEBMIN_PASS,
# WEBMIN_PORT) so a generated password with shell metacharacters is passed
# verbatim rather than through a shell command line.
set -e

USERNAME="$WEBMIN_USER"
PASSWORD="$WEBMIN_PASS"
PORT="$WEBMIN_PORT"
CONF=/etc/webmin

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$PORT" ]; then
  echo "ERROR: WEBMIN_USER, WEBMIN_PASS and WEBMIN_PORT must be set" >&2
  exit 1
fi

if [ ! -f "$CONF/miniserv.conf" ]; then
  echo "ERROR: $CONF/miniserv.conf not found - Webmin install did not complete" >&2
  exit 1
fi

# Port. miniserv.conf always has a port= line; listen= is optional.
sed -i "s/^port=.*/port=${PORT}/" "$CONF/miniserv.conf"
if grep -q '^listen=' "$CONF/miniserv.conf"; then
  sed -i "s/^listen=.*/listen=${PORT}/" "$CONF/miniserv.conf"
fi

# Create the user line (login:crypt:0). Seed crypt with 'x' first; changepass.pl
# then replaces it with a hash in whatever scheme miniserv.conf is configured
# for (changepass.pl refuses to run for a user that does not already exist).
if ! grep -q "^${USERNAME}:" "$CONF/miniserv.users"; then
  echo "${USERNAME}:x:0" >> "$CONF/miniserv.users"
fi
/usr/share/webmin/changepass.pl "$CONF" "$USERNAME" "$PASSWORD"

# Grant the account access to every installed module. Webmin's setup writes the
# root login an ACL line listing all modules (`root: <allmods>`); reuse that list
# so the new admin gets the same full access, including package-updates.
ALLMODS="$(sed -n 's/^root: //p' "$CONF/webmin.acl" | head -n1)"
if [ -z "$ALLMODS" ]; then
  # Fall back to enumerating installed modules if the root line is missing.
  ALLMODS="$(ls /usr/share/webmin/*/module.info 2>/dev/null \
             | sed 's#/usr/share/webmin/##; s#/module.info##' | tr '\n' ' ')"
fi
if grep -q "^${USERNAME}:" "$CONF/webmin.acl"; then
  sed -i "s#^${USERNAME}:.*#${USERNAME}: ${ALLMODS}#" "$CONF/webmin.acl"
else
  echo "${USERNAME}: ${ALLMODS}" >> "$CONF/webmin.acl"
fi

echo "configure_webmin.sh: configured ${USERNAME} on port ${PORT}"
