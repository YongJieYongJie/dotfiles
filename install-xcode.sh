#!/usr/bin/env sh

xcode-select --print-path > /dev/null && exit 0
[ "$os" = "Darwin" ] || exit 1

# Adapted from Homebrew installation script at
# https://github.com/Homebrew/install/blob/master/install.sh#L813.

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

    if [ -n "${CI_PASSWORD}" ]; then
        echo "$CI_PASSWORD" | sudo -S /usr/sbin/softwareupdate -i "${clt_label}"
        echo "$CI_PASSWORD" | sudo -S /bin/rm -f ${clt_placeholder}
        echo "$CI_PASSWORD" | sudo -S /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
    else
        sudo /usr/sbin/softwareupdate -i "${clt_label}"
        sudo /bin/rm -f ${clt_placeholder}
        sudo /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
    fi
fi

