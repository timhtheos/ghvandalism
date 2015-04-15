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

# Reset Auth Note Suffix
# In effect: Auth Tokens shall be empty
function reset_auth_tokens() {
  # Auth note suffix change (increment +1)
  auth_note_suffix=$(($auth_note_suffix+1))
  sed -i -e '/auth_note_suffix=/d' config.info
  sed -i -e '$ a\
    auth_note_suffix="'"$auth_note_suffix"'"' config.info
  echo ok "Auth note suffix has been changed."

  sed -i -e '/auth_create=/d' config.info
  sed -i -e '$ a\
    auth_create=""' config.info

  sed -i -e '/auth_delete=/d' config.info
  sed -i -e '$ a\
    auth_delete=""' config.info

  echo ok "Auth tokens to create and delete have been emptied."

  # Re-run
  bash install.sh
}

# Check for config.info file
if [ ! -f config.info ]; then
  echoex er "config.info file does not exist, creating..."
  touch config.info
  echo -e "# Github Login\nuser=\"\"\npswd=\"\"\n\n# Github repository (must be non-existing)\nrepo=\"\"\n\n# DO NOT EDIT BELOW\nauth_create=\"\"\nauth_delete=\"\"\nauth_note_suffix=\"0\"" > config.info
  echoex ok "config.info file has been created"
  echoex er "Please supply information in the config.info file."
  exit
fi

# Include config.info file
source config.info

# Check config.info file vars if set
# Only for github login and repository
# Authorization tokens will be generated automatically
if [ -z "$user" ] || [ -z "$pswd" ] || [ -z "$repo" ]; then
  echoex er "Please edit your config.info file and supply info for user, pswd, and repo variables."
  exit
fi

# Generate auth token to create repository
if [ -z "$auth_create" ]; then
  auth_create=$(curl -u $user:$pswd -d '{"scopes":["repo"], "note":"create_'"$auth_note_suffix"'"}' -X POST https://api.github.com/authorizations | jq -r ".token")
  sed -i -e "s/auth_create=\"\"/auth_create=\"$auth_create\"/g" config.info

  if [ ! $auth_create = "null" ]; then
    echoex ok "Auth token to create has been set in config.info file."
  else
    echoex er "Auth token to create returns \"null\"."
    echoex ok "Changing auth_note_suffix..."
    reset_auth_tokens create
  fi
fi

# Generate auth token to delete repository
if [ -z "$auth_delete" ]; then
  auth_delete=$(curl -u $user:$pswd -d '{"scopes":["delete_repo"], "note":"delete_'"$auth_note_suffix"'"}' -X POST https://api.github.com/authorizations | jq -r ".token")
  sed -i -e "s/auth_delete=\"\"/auth_delete=\"$auth_delete\"/g" config.info

  if [ ! $auth_delete = "null" ]; then
    echoex ok "Auth token to delete has been set in config.info file."
  else
    echoex er "Auth token to delete returns \"null\"."
    echoex ok "Changing auth_note_suffix..."
    reset_auth_tokens delete
  fi
fi

exit
# Delete repository if it exists
if curl -u $user:$pswd -X GET https://api.github.com/repos/$user/$repo | grep -q "full_name"; then
  curl -H "Authorization: token $auth_delete" -X DELETE https://api.github.com/repos/$user/$repo
  echo "Your github repository $repo has been deleted."
fi

echo "Finished: DEL"

# Create repository in github
if curl -H "Authorization: token $auth_create" -d '{"name":"'"$repo"'"}' -X POST https://api.github.com/user/repos | grep "full_name"; then
  echo "Your github repository $repo has been created."
else
  echo "Cannot create repository."
  exit
fi

echo "Finished: CREATE"

exit

# Require first argument
if [ -z "$1" ]; then
  echo "Please supply the first parameter as your "text"."
  exit
fi

# Set/clean text from first argument
text=`echo "$1" | sed "s: :%20:g"`

# Generate commits using 3rd party service
curl "http://pokrovsky.herokuapp.com/$user/.repo/$text" | sed -e "/git pull/d" | sed -e "s/.repo.git/$repo.git/g" | bash

# Delete .repo dir
rm -rf .repo

echo "Done."
echo "Please check your public github profile: https://github.com/$user"
