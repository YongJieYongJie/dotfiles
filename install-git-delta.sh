#!/usr/bin/env sh

command -v git-delta > /dev/null && exit 0

if [ "$os" = "Linux"]; then
    deltaUrl=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest \
                   | grep -E 'browser_download_url.*amd64\.deb' \
                   | grep -v musl \
                   | cut -d\" -f4)
    curl -LO $deltaUrl
    deltaFilename=${deltaUrl##*/}
    sudo dpkg -i $deltaFilename
    rm $deltaFilename
elif [ "$os" = "Darwin" ]; then
    brew install git-delta
fi
