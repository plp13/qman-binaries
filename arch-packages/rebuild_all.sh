#!/usr/bin/env bash
# Rebuild and reinstall all packages required by Qman, static libraries enabled

source ../include/lib.sh

# Go to the directory that contains the script
cd "$( dirname "${BASH_SOURCE[0]}" )"
exit_on_error $?

# Set up help
help_summary "Rebuild and reinstall all packages required by Qman, static libraries enabled"
help_usage "${0}"
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

# Packages to rebuild
PACKAGES=( 'ncurses' 'libbsd' 'zlib' 'bzip2' 'xz' )

# Rebuild and reinstall the packages
for P in "${PACKAGES[@]}"
do
  title "Building ${P}"
  cmdrun pkgctl repo clone "${P}"
  cmdrun cd "${P}"
  cmdrun git reset --hard
  cmdrun git pull
  if [ -f "../${P}.patch" ]
  then
    cmdrun git apply "../${P}.patch"
  fi
  cmdrun makepkg --config ../makepkg.conf --force --skippgpcheck
  cmdrun sudo pacman -U "${P}-"[0-9]*".pkg.tar"
  cmdrun cd ..
  ok
done

exit 0
