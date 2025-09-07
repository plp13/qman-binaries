# Library of bash constants and functions
#
# Usage: source ../lib/lib.sh

# Set to 1 to suppress all output
_Q=0

# Colors
_R="\e[31m"       # Red
_G="\e[32m"       # Green
_B="\e[1m"        # Bold white
_N="\e[0m"        # Normal

# Help variables
_HS=""            # Command summary
_HU=""            # Command usage example
_HAD=()           # Arguments' descriptions
_HAS=()           # Arguments' short options

# Suppress all output
quiet() {
  _Q=1
}

# Un-suppress all output
noquiet() {
  _Q=0
}

# Print [ OK ]
ok() {
  if [ ${_Q} -eq 1 ]; then return; fi

  echo -e "[ ${_G}OK${_N} ]"
}

# Print [ ERROR ]
error() {
  if [ ${_Q} -eq 1 ]; then return; fi

  echo -e "[ ${_R}ERROR${_N} ]"
}

# Print a title. Title text is defined in $1.
title() {
  if [ ${_Q} -eq 1 ]; then return; fi

  echo -e "${_B}$1${_N}"
}

# Print a bullet. Bullet character is defined in $1 and text in $2.
bullet() {
  if [ ${_Q} -eq 1 ]; then return; fi

  echo -e "${_B}${1} ${_N} ${2}"
}

# Print a message. Preamble is defined in $1 and text in $2.
message() {
  if [ ${_Q} -eq 1 ]; then return; fi

  echo -e "${_B}${1}:${_N} ${2}"
}

# Help setup: set your command's summary. The summary is defined in $1.
help_summary() {
  _HS="${1}"
}

# Help setup: set your command's usage example. The usage example is defined in
# $1.
help_usage() {
  _HU="${1}"
}

# Help setup: add a command line argument. Argument description is defined in
# $1, and short option in $2. Long options are not supported.
help_arg() {
  _HAD+=( "${1}" )
  _HAS+=( "${2}" )
}

# Print the help message
help() {
  title "${_HS}"
  
  echo ""
  echo "Usage:"
  printf "  %s\n" "${_HU}"

  echo ""
  echo "Command-line arguments:"
  args=${#_HAD[@]}
  for i in $( seq 0 1 $(( args - 1 )) )
  do
    printf "  %-2s %-20s %s\n" "-${_HAS[${i}]}" "${_HAD[${i}]}"
  done
}

# If $1 is non-zero, call error() and exit
exit_on_error() {
  if [ "X${1}" != "X0" ]
  then
    error
    exit ${1}
  fi
}

cmdrun() {
  bullet ">" "${*}"
  "${@}"
  exit_on_error $?
}
