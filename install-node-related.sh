#!/usr/bin/env sh

[ -d ${HOME}/.nvm ] && exit 0

# ------------------------------------------- Install npm-related tools ------
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

nvm install node && nvm use node
npm install -g yarn

