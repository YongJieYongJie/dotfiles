#!/usr/bin/env sh

if [ "$os" = "Linux" ]; then
    # Based on instructions at https://github.com/gokcehan/lf#installation.
    command -v lf > /dev/null ||\
        env CGO_ENABLED=0 go install -ldflags="-s -w" github.com/gokcehan/lf@latest
elif [ "$os" = "Darwin" ]; then
    command -v lf > /dev/null || brew install lf
fi

. "${DOTFILES_INSTALLERS_DIR}/lib/sh/helpers.sh"
lnWithBackup "${DOTFILES_INSTALLERS_DIR}/lfrc" "${HOME}/.config/lf/lfrc"
