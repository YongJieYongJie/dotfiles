#!/usr/bin/env sh

# Adapted from Homebrew installation script at
# https://github.com/Homebrew/install/blob/master/install.sh#L813.

printf "[!] arguments to $1"
scriptName="$0"
PASSWORD="$1"
if [ -z "$PASSWORD" ]; then
  printf "[!] $scriptName: password must be provided as argument to the script."
  exit 1
fi

printf "Searching online for the Command Line Tools\n"
# This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
clt_placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
touch $clt_placeholder

clt_label_command="/usr/sbin/softwareupdate -l |
  grep -B 1 -E 'Command Line Tools' |
  awk -F'*' '/^ *\\*/ {print \$2}' |
  sed -e 's/^ *Label: //' -e 's/^ *//' |
  sort -V |
  tail -n1"

clt_label="$(/bin/bash -c "${clt_label_command}")"

if [ -n "${clt_label}" ]; then
  printf "Installing ${clt_label}\n"
  echo "$PASSWORD" | sudo -S /usr/sbin/softwareupdate -i "${clt_label}"
  echo "$PASSWORD" | sudo -S /bin/rm -f ${clt_placeholder}
  echo "$PASSWORD" | sudo -S /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
fi

