#!/usr/bin/env bash
# Build all Qman binary packages

exit_on_error() {
  if [ "X${1}" != "X0" ]
  then
    echo "Command failed"
    exit ${1}
  fi
}

if [ "X${1}" == "X" ]
then
  echo "Usage: ${0} <branch or tag name>"
  exit -1
fi

cd "$( dirname "${BASH_SOURCE[0]}" )"
exit_on_error $?

NAME="qman"
REMOTE="https://github.com/plp13/qman"
SRC="$( pwd )/qman"
PKG="$( pwd )/pkg"
DEB="$( pwd )/deb"
BRANCH="${1}"
ARCH="x86-64"
ARCH_DEB="amd64"

# Cleanup
echo "*** Cleaning up"
rm -fr "${SRC}"
exit_on_error $?
rm -fr "${PKG}"
exit_on_error $?
rm -fr "${DEB}"
exit_on_error $?

# Generic package
echo "*** Building generic package"
exit_on_error $?
git clone -b "${BRANCH}" "${REMOTE}" "${SRC}"
exit_on_error $?
cd "${SRC}"
exit_on_error $?
VERSION="$( git describe )"
exit_on_error $?
git pull
exit_on_error $?
git apply ../qman.patch
exit_on_error $?
rm -fr build/
exit_on_error $?
meson setup "${BUILD_MESON_OPTIONS}" -Dtests=disabled -Dstaticexe=true -Dprefix="${PKG}/usr" -Dconfigdir="${PKG}/etc/xdg/qman" build/
exit_on_error $?
cd build/
exit_on_error $?
meson compile
exit_on_error $?
strip src/qman
exit_on_error $?
meson install
exit_on_error $?
cd ../../pkg/
exit_on_error $?
gzip --best -n usr/share/man/man1/qman.1
exit_on_error $?
tar czvf "../${NAME}-${VERSION}.${ARCH}.tar.gz" *
exit_on_error $?
cd ..
exit_on_error $?

# .deb
echo "*** Building .deb"
exit_on_error $?
mkdir "${DEB}"
exit_on_error $?
cd "${DEB}"
exit_on_error $?
mkdir qman
exit_on_error $?
cp -fr "${PKG}/"* qman/
exit_on_error $?
mkdir qman/DEBIAN
exit_on_error $?
cat << EOF >> qman/DEBIAN/control
Package: qman
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH_DEB}
Maintainer: Pantelis Panayiotou <p.panayiotou@gmail.com>
Description: A more modern manual page viewer for our terminals
EOF
exit_on_error $?
cat << EOF >> qman/DEBIAN/conffiles
/etc/xdg/qman/qman.conf
EOF
for F in "${PKG}/etc/xdg/qman/themes/"*
do
  echo "/etc/xdg/qman/themes/$( basename "${F}" )" >> qman/DEBIAN/conffiles
  exit_on_error $?
done
cp "${SRC}/LICENSE" qman/DEBIAN/copyright
exit_on_error $?
dpkg-deb --root-owner-group --build qman/ "../qman_${VERSION}_${ARCH_DEB}.deb"
exit_on_error $?
cd ..
exit_on_error $?

# .rpm (TBD)

exit 0
