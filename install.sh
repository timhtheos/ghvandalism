#!/bin/bash

# Include vars, functions
source required.sh

# Check for config.info file
if [ ! -f config.info ]; then
  echoex er "config.info file does not exist, creating..."
  touch config.info
  echo -e "# Github Login\nuser=\"\"\npswd=\"\"\n\n# Github repository (must be non-existing)\nrepo=\"\"\n\n# DO NOT EDIT BELOW" > config.info
  echoex ok "config.info file has been created"
  echoex er "Please supply information in the config.info file."
  exit
fi

# Include config.info file
source config.info

# Check config.info file vars if set
# Only for github login and repository
# Auth token will be generated automatically
if [ -z "$user" ] || [ -z "$pswd" ] || [ -z "$repo" ]; then
  echoex er "Please edit your config.info file and supply info for user, pswd, and repo variables."
  exit
fi

# Check for var $auth_note_suffix
if [ -z "$auth_note_suffix" ]; then
  sed -i -e '/auth_note_suffix=/d' config.info
  sed -i -e '$ a\
    auth_note_suffix="0"' config.info
fi

# Generate auth token to create and delete repository
if [ -z "$auth_token" ]; then
  auth_token=$(curl -u $user:$pswd -d '{"scopes":["repo","delete_repo"], "note":"gitfiti_'"$auth_note_suffix"'"}' -X POST https://api.github.com/authorizations | jq -r ".token")
  sed -i -e '/auth_token=/d' config.info
  sed -i -e '$ a\
    auth_token="'"$auth_token"'"' config.info

  if [ ! $auth_token = "null" ]; then
    echoex ok "Auth token has been set in config.info file."
  else
    echoex er "Auth token returns \"null\"."
    echoex ok "Changing auth_note_suffix..."
    reset_auth_token
  fi
fi

# Delete repository if it exists
if curl -u $user:$pswd -X GET https://api.github.com/repos/$user/$repo | grep -q "full_name"; then
  echoex er "Repository $repo exists, deleting..."
  curl -H "Authorization: token $auth_token" -X DELETE https://api.github.com/repos/$user/$repo
  echoex ok "Repository $repo has been deleted, re-creating..."
else
  echoex ok "Repository $repo does not exist, creating..."
fi

# Create repository in github
if curl -H "Authorization: token $auth_token" -d '{"name":"'"$repo"'"}' -X POST https://api.github.com/user/repos | grep "full_name"; then
  echoex ok "Repository $repo has been created."
else
  echoex er "Cannot create repository."
  exit
fi

# Require first argument
if [ -z "$1" ]; then
  echoex er "Please supply the first parameter as your \"text\"."
  exit
fi

# Set/clean text from first argument
text=`echo "$1" | sed "s: :%20:g"`

# Generate commits using 3rd party service
curl "http://pokrovsky.herokuapp.com/$user/.repo/$text" | sed -e "s/git init .repo/echo \"\"; echo \"\"; echo -e \"Generating commits using service from pokrovsky.herokuapp.com.\"; echo \"\"; git init .repo; echo \"\";/g" | sed -e "/git pull/d" | sed -e "s/.repo.git/$repo.git/g" | bash

# Delete .repo dir
rm -rf .repo

echoex ok "Done."
echoex ok "Please check your public github profile: https://github.com/$user"
echoex ok "To view your profile the way public can see it, view it in an incognito browser."
echo
