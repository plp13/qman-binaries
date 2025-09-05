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
BRANCH="${1}"

rm -fr "${SRC}"
exit_on_error $?
rm -fr "${PKG}"
exit_on_error $?
git clone -b "${BRANCH}" "${REMOTE}" "${SRC}"
exit_on_error $?
cd "${SRC}"
exit_on_error $?
git pull
exit_on_error $?
rm -fr build/
exit_on_error $?
meson setup -Dtests=disabled -Dstaticexe=true -Dprefix="${PKG}/usr" -Dconfigdir="${PKG}/etc/xdg/qman" build/
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
tar czvf ../${NAME}-${BRANCH}.tar.gz *
exit_on_error $?

exit 0
