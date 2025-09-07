#!/usr/bin/env bash
# Build all Qman binary packages

source ../include/lib.sh

# Go to the directory that contains the script
cd "$( dirname "${BASH_SOURCE[0]}" )"
exit_on_error $?

# Set up help
help_summary "Build all Qman binary packages"
help_usage "${0} <branch or tag name>"
help_arg "Show this help message" "h"

# Show help and exit, if we got a `-h`
while getopts 'h' OPT
do
  case "${OPT}" in
    h)
      help
      exit 0
      ;;
  esac
done
shift "$(( ${OPTIND} -1 ))"

# Show help and exit, if $1 wasn't supplied
if [ "X${1}" == "X" ]
then
  help
  exit -1
fi

# Variables
NAME="qman"                                 # Program name
REMOTE="https://github.com/plp13/qman"      # Program remote repository location
SRC="$( pwd )/qman"                         # Local directory for project sources
PKG="$( pwd )/pkg"                          # Local directory for building the generic package
DEB="$( pwd )/deb"                          # Local directory for building the .deb package
BRANCH="${1}"                               # Branch or tag name
VERSION=""                                  # Program version (to be retrieved from `git`)
ARCH="x86-64"                               # Target architecture
ARCH_DEB="amd64"                            # Target architecture (deb version)

# Cleanup
title "Cleaning up"
cmdrun rm -fr "${SRC}"
cmdrun rm -fr "${PKG}"
cmdrun rm -fr "${DEB}"
ok

# Build the generic package
title "Building generic package"
cmdrun git clone -b "${BRANCH}" "${REMOTE}" "${SRC}"
cmdrun cd "${SRC}"
VERSION="$( git describe )"
exit_on_error $?
cmdrun git pull
cmdrun git apply ../qman.patch
cmdrun rm -fr build/
cmdrun meson setup "${BUILD_MESON_OPTIONS}" -Dtests=disabled -Dstaticexe=true -Dprefix="${PKG}/usr" -Dconfigdir="${PKG}/etc/xdg/qman" build/
cmdrun cd build/
cmdrun meson compile
cmdrun strip src/qman
cmdrun meson install
cmdrun cd ../../pkg/
cmdrun gzip --best -n usr/share/man/man1/qman.1
cmdrun tar czvf "../${NAME}-${VERSION}.${ARCH}.tar.gz" *
cmdrun cd ..
ok

# Build the .deb package
title "Building .deb"
cmdrun mkdir "${DEB}"
cmdrun cd "${DEB}"
cmdrun mkdir qman
cmdrun cp -fr "${PKG}/"* qman/
cmdrun mkdir qman/DEBIAN
bullet "*" "Populating qman/DEBIAN/control"
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
bullet "*" "Populating qman/DEBIAN/conffiles"
cat << EOF >> qman/DEBIAN/conffiles
/etc/xdg/qman/qman.conf
EOF
exit_on_error $?
for F in "${PKG}/etc/xdg/qman/themes/"*
do
  echo "/etc/xdg/qman/themes/$( basename "${F}" )" >> qman/DEBIAN/conffiles
  exit_on_error $?
done
cmdrun cp "${SRC}/LICENSE" qman/DEBIAN/copyright
cmdrun dpkg-deb --root-owner-group --build qman/ "../qman_${VERSION}_${ARCH_DEB}.deb"
cmdrun cd ..
ok

# .rpm (TBD)

exit 0
