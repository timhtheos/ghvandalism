#!/bin/bash

# Vars
color_highlight='\033[0;33m'
color_error='\033[0;31m'
color_none='\033[0m'

# Echo
function echoex() {
  echo
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${color_error}echoex(): Define first and second arguments.${color_none}"
    exit
  elif [ $1 = "ok" ]; then
    echo -e "${color_highlight}${2}${color_none}"
  elif [ $1 = "er" ]; then
    echo -e "${color_error}${2}${color_none}"
  else
    echo -e "${color_error}echoex(): First param is limited to \"ok\" and \"er\" only.${color_none}"
    exit
  fi
}

# Reset Auth Token in the guise of incrementing Auth Note Suffix
function reset_auth_token() {
  # Increment auth note suffix
  auth_note_suffix=$(($auth_note_suffix+1))
  sed -i -e '/auth_note_suffix=/d' config.info
  sed -i -e '$ a\
    auth_note_suffix="'"$auth_note_suffix"'"' config.info
  echoex ok "Auth note suffix has been changed."

  sed -i -e '/auth_token=/d' config.info
  sed -i -e '$ a\
    auth_token=""' config.info
  echoex ok "Auth token has been emptied."

  # Re-run to generate new auth token
  echoex ok "Restarting install..."
  bash install.sh
}
