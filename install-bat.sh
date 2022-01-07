#!/usr/bin/env sh

command -v bat       > /dev/null || exit 0

if [ "$os" = "Linux"]; then
  batUrl=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest \
    | grep -E 'browser_download_url.*amd64\.deb' \
    | grep -v musl \
    | cut -d\" -f4)
  curl -LO $batUrl
  batFilename=${batUrl##*/}
  sudo dpkg -i $batFilename
  rm $batFilename
elif [ "$os" = "Darwin"]; then
    brew install bat
fi
