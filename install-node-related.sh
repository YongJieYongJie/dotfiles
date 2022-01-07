#!/usr/bin/env sh

if [ -d ${HOME}/.nvm ]; then
    # Note: Not using exit 0 because this script may be sourced instead of
    # executed.

    : # no-op
else
    # ----------------------------------------- Install npm-related tools ------
    # Install nvm, as recommended by npm (at
    # https://docs.npmjs.com/downloading-and-installing-node-js-and-npm), and
    # following instructions from nvm (at
    # https://github.com/nvm-sh/nvm#manual-install)
    export NVM_DIR="${HOME}/.nvm" && (
        cd "${HOME}"
        git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
        cd "$NVM_DIR"
        git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" \
      $(git rev-list --tags --max-count=1)`
    ) && \. "$NVM_DIR/nvm.sh"

    command -v node > /dev/null || nvm install node && nvm use node
    command -v yarn > /dev/null || npm install -g yarn
fi
