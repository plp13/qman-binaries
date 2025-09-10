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
NAME="qman"                            # Program name
REMOTE="https://github.com/plp13/qman" # Program remote repository location
ROOT="$( pwd )"                        # Location of this script
SRC="${ROOT}/${NAME}"                  # Local directory for project sources
PKG="${ROOT}/pkg"                      # Local directory for building the .tar.gz package
DEB="${ROOT}/deb"                      # Local directory for building the .deb package
RPM="${ROOT}/rpm"                      # Local directory for building the .rpm package
BRANCH="${1}"                          # Branch or tag name
VERSION=""                             # Program version
VERSION_RPM=""                         # Program version (.rpm format)
ARCH="x86-64"                          # Target architecture
ARCH_DEB="amd64"                       # Target architecture (.deb format)
ARCH_RPM="x86_64"                      # Target architecture (.rpm format)
AUTHOR="Pantelis Panayiotou"           # Author name
EMAIL="p.panayiotou@gmail.com"         # Author email address
TRGT_PKG=""                            # Target fn for generic package (.tar.gz)
TRGT_DEB=""                            # Target fn for Debian package (.deb)
TRGT_RPM=""                            # Target fn for Red Hat package (.rpm)

# Cleanup
title "Cleaning up"
cmdrun rm -fr "${SRC}"
cmdrun rm -fr "${PKG}"
cmdrun rm -fr "${DEB}"
cmdrun rm -fr "${RPM}"
cmdrun rm -f "${ROOT}/"*".tar.gz"
cmdrun rm -f "${ROOT}/"*".deb"
cmdrun rm -f "${ROOT}/"*".rpm"
ok

# Retrieve the sources
title "Retrieving ${NAME} sources"
cmdrun git clone -b "${BRANCH}" "${REMOTE}" "${SRC}"
cmdrun cd "${SRC}"
VERSION="$( git describe )"
VERSION_RPM="$( echo "${VERSION}" | sed 's/-/./g' )"
TRGT_PKG="${NAME}-${VERSION}.${ARCH}.tar.gz"
TRGT_DEB="${NAME}_${VERSION}_${ARCH_DEB}.deb"
TRGT_RPM="${NAME}-${VERSION_RPM}-1.${ARCH_RPM}.rpm"
exit_on_error $?
cmdrun git pull
if [ -f "../${NAME}.patch" ]
then
  cmdrun git apply "../${NAME}.patch"
fi
cmdrun cd ..
ok

# Build the generic package (.tar.gz)
title "Building generic package (.tar.gz)"
cmdrun cd "${SRC}"
cmdrun rm -fr build/
cmdrun meson setup "${BUILD_MESON_OPTIONS}" -Dtests=disabled -Dstaticexe=true -Dprefix="${PKG}/usr" -Dconfigdir="${PKG}/etc/xdg/qman" build/
cmdrun cd build/
cmdrun meson compile
cmdrun strip src/qman
cmdrun meson install
cmdrun cd "${PKG}"
cmdrun gzip --best -n usr/share/man/man1/qman.1
cmdrun tar czvf "${ROOT}/${TRGT_PKG}" *
cmdrun cd ..
ok

# Build the Debian package (.deb)
title "Building Debian package (.deb)"
cmdrun mkdir "${DEB}"
cmdrun cd "${DEB}"
cmdrun mkdir "${NAME}" 
cmdrun cp -fr "${PKG}/"* "${NAME}/"
cmdrun mkdir "${NAME}/DEBIAN"
bullet "*" "Populating ${NAME}/DEBIAN/control"
cat << EOF >> "${NAME}/DEBIAN/control"
Package: ${NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH_DEB}
Maintainer: ${AUTHOR} <${EMAIL}>
Description: A more modern manual page viewer for our terminals
EOF
exit_on_error $?
bullet "*" "Populating ${NAME}/DEBIAN/conffiles"
cat << EOF >> "${NAME}/DEBIAN/conffiles"
/etc/xdg/qman/qman.conf
EOF
exit_on_error $?
for F in "${PKG}/etc/xdg/qman/themes/"*
do
  echo "/etc/xdg/qman/themes/$( basename "${F}" )" >> qman/DEBIAN/conffiles
  exit_on_error $?
done
cmdrun cp "${SRC}/LICENSE" ${NAME}/DEBIAN/copyright
cmdrun dpkg-deb --root-owner-group --build ${NAME}/ "${ROOT}/${TRGT_DEB}"
cmdrun cd ..
ok

# Build the Red Hat package (.rpm)
title "Building Red Hat package (.rpm)"
exit_on_error $?
cmdrun mkdir "${RPM}"
cmdrun cd "${RPM}"
cmdrun mkdir BUILD
cmdrun mkdir BUILDROOT
cmdrun mkdir RPMS
cmdrun mkdir SRPMS
cmdrun mkdir SOURCES
cmdrun mkdir SPECS
cmdrun cp "${ROOT}/${TRGT_PKG}" SOURCES/
bullet "*" "Populating SPECS/${NAME}.spec"
cat << EOF >> "SPECS/${NAME}.spec"
Name:           ${NAME}
Version:        ${VERSION_RPM}
Release:        1
Summary:        A more modern manual page viewer for our terminals
BuildArch:      ${ARCH_RPM}
License:        BSD-2-Clause
Source0:        ${TRGT_PKG}

%description
Unix manual pages are lovely. They are concise, well-written, complete, and
downright useful. However, the standard way of accessing them from the
command-line hasn't changed since the early days.

Qman aims to change that. It's a modern, full-featured manual page viewer
featuring hyperlinks, web browser like navigation, a table of contents for each
page, incremental search, on-line help, and more. It also strives to be fast and
tiny, so that it can be used everywhere. For this reason, it's been written in
plain C and has only minimal dependencies.

%global debug_package %{nil}

%prep
%setup

%build

%install
rm -fr "\${RPM_BUILD_ROOT}"

DST="\${RPM_BUILD_ROOT}/%{_bindir}"
mkdir -p "\${DST}"
cp -r ${PKG}/usr/bin/* "\${DST}/"

DST="\${RPM_BUILD_ROOT}/%{_sysconfdir}"
mkdir -p "\${DST}"
cp -r ${PKG}/etc/* "\${DST}/"

DST="\${RPM_BUILD_ROOT}/%{_mandir}"
mkdir -p "\${DST}"
cp -r ${PKG}/usr/share/man/* "\${DST}/"

DST="\${RPM_BUILD_ROOT}/%{_docdir}"
mkdir -p "\${DST}"
cp -r ${PKG}/usr/share/doc/* "\${DST}/"

%clean
rm -rf "\${RPM_BUILD_ROOT}"

%files
EOF
exit_on_error $?
cmdrun tar ztf "SOURCES/${TRGT_PKG}" | grep "usr/bin/" | grep -v '/$' | sed 's/usr\/bin\//%{_bindir}\//g' >> "SPECS/${NAME}.spec"
cmdrun tar ztf "SOURCES/${TRGT_PKG}" | grep "etc/" | grep -v '/$' | sed 's/etc\//%{_sysconfdir}\//g' >> "SPECS/${NAME}.spec"
cmdrun tar ztf "SOURCES/${TRGT_PKG}" | grep "usr/share/man/" | grep -v '/$' | sed 's/usr\/share\/man\//%{_mandir}\//g' >> "SPECS/${NAME}.spec"
cmdrun tar ztf "SOURCES/${TRGT_PKG}" | grep "usr/share/doc/" | grep -v '/$' | sed 's/usr\/share\/doc\//%{_docdir}\//g' >> "SPECS/${NAME}.spec"
bullet "*" "Populating SPECS/${NAME}.spec"
cat << EOF >> "SPECS/${NAME}.spec"

%changelog
* $( date '+%a %b %d %Y' ) ${AUTHOR} <${EMAIL}> - ${VERSION_RPM}
- Build RPM package for ${NAME} ${VERSION_RPM}
EOF
exit_on_error $?
cmdrun rpmbuild --define "_topdir ${PWD}" --build-in-place -bb "SPECS/${NAME}.spec"
cmdrun mv "RPMS/${ARCH_RPM}/${TRGT_RPM}" ..
cd ..
ok

exit 0
