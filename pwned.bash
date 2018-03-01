#!/usr/bin/env bash
# pass pwned - Password Store Extension (https://www.passwordstore.org/)
# uses Troy Hunt's ';--have i been pwned? API https://haveibeenpwned.com/API/v2

#set -o verbose
#set -o xtrace

local path="$1"
local passfile="$PREFIX/$path.gpg"
local useragent="Password-Store-bash-extension-pass-pwned"
local contents sha1 prefix suffix result match count
check_sneaky_paths "$path"

if [[ -f $passfile ]]; then
  contents=$($GPG -d "${GPG_OPTS[@]}" "$passfile" | head -n +1 | tr -d '\r')
  if [[ -z "$contents" ]]; then
    die "Failed to read password"
  fi

  sha1=$(echo -n "$contents" | sha1sum | cut -d ' ' -f 1 | tr -d '\r')
  if [[ -z "$sha1" ]]; then
    die "Failed to generate sha1"
  fi

  prefix="${sha1:0:5}"
  if [[ -z "$prefix" ]]; then
    die "Failed to get sha1 prefix"
  fi

  suffix="${sha1:5}"
  if [[ -z "$suffix" ]]; then
    die "Failed to get sha1 suffix"
  fi

  result=$(curl --fail --silent -A "$useragent" "https://api.pwnedpasswords.com/range/$prefix")
  if [[ -z "$result" ]]; then
    die "Failed to read from API"
  fi

  match=$(echo "$result" | grep -i "$suffix" | tr -d '\r')
  if [[ -z "$match" ]]; then
    echo "Password not found in haveibeenpwned"
    exit 0
  fi

  count=$(echo -n "$match" | cut -d ':' -f 2 | tr -d '\r')
  if [[ -z "$count" ]]; then
    echo "Password found in haveibeenpwned"
    exit -1
  fi
  echo "Password found in haveibeenpwned $count times"
  exit -1

elif [[ -z $path ]]; then
  die ""
else
  die "Error: $path is not in the password store."
fi
