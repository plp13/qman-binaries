#!/usr/bin/env bash
# Rebuild and reinstall all packages required by Qman, static libraries enabled

exit_on_error() {
  if [ "X${1}" != "X0" ]
  then
    echo "Command failed"
    exit ${1}
  fi
}

cd "$( dirname "${BASH_SOURCE[0]}" )"
exit_on_error $?

PACKAGES=( 'ncurses' 'libbsd' 'zlib' 'bzip2' 'xz' )

for P in "${PACKAGES[@]}"
do
  echo "*** Building ${P}"
  pkgctl repo clone "${P}"
  exit_on_error $?
  cd "${P}"
  exit_on_error $?
  git reset --hard
  exit_on_error $?
  git pull
  exit_on_error $?
  if [ -f "../${P}.patch" ]
  then
    git apply "../${P}.patch"
    exit_on_error $?
  fi
  makepkg --config ../makepkg.conf --force --skippgpcheck
  exit_on_error $?
  sudo pacman -U "${P}-"[0-9]*".pkg.tar"
  exit_on_error $?
  cd ..
  exit_on_error $?
done

exit 0
