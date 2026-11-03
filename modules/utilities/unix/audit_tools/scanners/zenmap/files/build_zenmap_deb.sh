#!/bin/sh
# Builds Zenmap from the upstream Nmap source tarball into a venv at /opt/zenmap and
# registers it with dpkg as a "zenmap" package that links /usr/bin/zenmap to it.
set -e

VERSION=7.98
SHA256=ce847313eaae9e5c9f21708e42d2ab7b56c7e0eb8803729a3092f58886d897e6
WORK=$(mktemp -d /var/tmp/zenmap-build.XXXXXX)
trap 'rm -rf "$WORK"' EXIT

curl -fsSL --retry 3 -o "$WORK/nmap.tar.bz2" "https://nmap.org/dist/nmap-$VERSION.tar.bz2"
echo "$SHA256  $WORK/nmap.tar.bz2" | sha256sum -c -
tar -xjf "$WORK/nmap.tar.bz2" -C "$WORK" "nmap-$VERSION/zenmap"

# system site packages supply PyGObject and GTK, which pip cannot build sensibly
python3 -m venv --system-site-packages /opt/zenmap
/opt/zenmap/bin/pip install "$WORK/nmap-$VERSION/zenmap"

PKG="$WORK/pkg"
mkdir -p "$PKG/DEBIAN" "$PKG/usr/bin"
ln -s /opt/zenmap/bin/zenmap "$PKG/usr/bin/zenmap"
cat > "$PKG/DEBIAN/control" <<CONTROL
Package: zenmap
Version: $VERSION
Architecture: all
Maintainer: SecGen <secgen@localhost>
Depends: nmap, python3, python3-gi, python3-gi-cairo, gir1.2-gtk-3.0
Description: Nmap graphical front end, built from the upstream source
CONTROL
dpkg-deb --build "$PKG" "$WORK/zenmap.deb"
dpkg -i "$WORK/zenmap.deb"
