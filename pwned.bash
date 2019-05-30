#!/usr/bin/env bash
# pass pwned - Password Store Extension (https://www.passwordstore.org/)
# uses Troy Hunt's ';--have i been pwned? API https://haveibeenpwned.com/API/v2

#set -o verbose
#set -o xtrace

USER_AGENT="Password-Store-bash-extension-pass-pwned"

cmd_pwned() {

  contents=$($GPG -d "${GPG_OPTS[@]}" "$passfile" | head -n +1 | tr -d '\r\n')
  if [ -z "$contents" ]; then
    die "Failed to read password"
  fi

  sha1=$(echo -n "$contents" | sha1sum | cut -d ' ' -f 1 | tr -d '\r')
  if [ -z "$sha1" ]; then
    die "Failed to generate sha1"
  fi

  sha1prefix="${sha1:0:5}"
  if [ -z "$sha1prefix" ]; then
    die "Failed to get sha1 prefix"
  fi

  sha1suffix="${sha1:5}"
  if [ -z "$sha1suffix" ]; then
    die "Failed to get sha1 suffix"
  fi

  result=$(curl --fail --silent -A "$USER_AGENT" "https://api.pwnedpasswords.com/range/$sha1prefix")
  if [ -z "$result" ]; then
    die "Failed to read from API"
  fi

  match=$(echo "$result" | grep -i "$sha1suffix" | tr -d '\r\n')
  if [ -z "$match" ]; then
    echo "Password not found in haveibeenpwned"
    exit 0
  fi

  count=$(echo -n "$match" | cut -s -d ':' -f 2 | tr -d '\r\n')
  if [ -z "$count" ]; then
    die "Cannot parse output from API"
  fi

  echo "Password found in haveibeenpwned $count times"
  exit 1
}

path="$1"
passfile="$PREFIX/$path.gpg"
check_sneaky_paths "$path"

if [ -f "$passfile" ]; then
  cmd_pwned "$@"
elif [ -n "$path" ]; then
  die "Usage: $PROGRAM $COMMAND pass-name"
else
  die "Error: $path is not in the password store."
fi
