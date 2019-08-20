#!/usr/bin/env bash
# pass pwned - Password Store Extension (https://www.passwordstore.org/)
# uses Troy Hunt's ';--have i been pwned? API https://haveibeenpwned.com/API/v3

#set -o verbose
#set -o xtrace

shopt -s globstar
shopt -s nullglob

VERSION="v0.1.1"
USER_AGENT="Password-Store-bash-extension-pass-pwned $VERSION"

format_result () {
  pass_name="$1"
  pass_name="${pass_name#"$PREFIX/"}"
  pass_name="${pass_name%".gpg"}"
  result="$2"
  echo "$pass_name:$result"
}

cmd_pwned() {

  if [ ! -f "$1" ]; then
    format_result "$1" "error"
    die "Password is not in the password store"
  fi

  contents=$($GPG -d "${GPG_OPTS[@]}" "$1" | head -n +1 | tr -d '\r\n')
  if [ -z "$contents" ]; then
    format_result "$1" "error"
    die "Failed to read password"
  fi

  sha1=$(head -c -1 <<<"$contents" | sha1sum | cut -d ' ' -f 1 | tr -d '\r\n')
  if [ -z "$sha1" ]; then
    format_result "$1" "error"
    die "Failed to generate sha1"
  fi

  sha1prefix="${sha1:0:5}"
  if [ -z "$sha1prefix" ]; then
    format_result "$1" "error"
    die "Failed to get sha1 prefix"
  fi

  sha1suffix="${sha1:5}"
  if [ -z "$sha1suffix" ]; then
    format_result "$1" "error"
    die "Failed to get sha1 suffix"
  fi

  result=$(curl --fail --silent -A "$USER_AGENT" "https://api.pwnedpasswords.com/range/$sha1prefix")
  if [ -z "$result" ]; then
    format_result "$1" "error"
    die "Failed to read from API"
  fi

  invalid=$(grep -v -E "^[0-9A-F]{35}[:][0-9]+" <<<"$result")
  if [ -n "$invalid" ]; then
    format_result "$1" "error"
    die "API return result format not valid."
  fi

  match=$(head -c -1 <<<"$result" | grep -i -f <(head -c -1 <<<"$sha1suffix") | tr -d '\r\n')
  if [ -z "$match" ]; then
    format_result "$1" "0"
    return 0
  fi

  count=$(head -c -1 <<<"$match" | cut -s -d ':' -f 2 | tr -d '\r\n')
  if [ -z "$count" ]; then
    format_result "$1" "error"
    die "Cannot parse output from API"
  fi

  format_result "$1" "$count"
  return 0
}

if [ ${#@} == 0 ]; then
  die "Usage: $PROGRAM $COMMAND pass-name"
fi

paths=( "$PREFIX"/$1.gpg )

for path in "${paths[@]}"; do
  check_sneaky_paths "$path"
  cmd_pwned "$path"
  sleep 1
done
