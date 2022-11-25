#!/usr/bin/env sh

command -v pistol > /dev/null && exit 0

# Based on instructions at https://github.com/doronbehar/pistol#from-source.

if [ "$os" = "Linux" ]; then
    sudo apt-get install -y gcc libmagic-dev
elif [ "$os" = "Darwin" ]; then
    brew install libmagic
fi

env CGO_ENABLED=1 go install github.com/doronbehar/pistol/cmd/pistol@latest
