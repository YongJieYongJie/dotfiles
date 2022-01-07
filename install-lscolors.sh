#!/usr/bin/env sh

[ -d ${HOME}/LS_COLORS ] && exit 0

# Install lscolors so different filetypes have different color in output of
# commands like ls and lf. Based on instructions at
# https://github.com/trapd00r/LS_COLORS#installation.
mkdir -p ${HOME}/LS_COLORS \
  && curl -L https://api.github.com/repos/trapd00r/LS_COLORS/tarball/master \
  | tar xzf - --directory=${HOME}/LS_COLORS --strip=1

if [ "$os" = "Darwin" ]; then
  gsed -i -e 's/\<dircolors\>/gdircolors/g ; s/\<mv\>/gmv/g' ${HOME}/LS_COLORS/install.sh
fi
(cd ${HOME} && ${HOME}/LS_COLORS/install.sh && rm -rf ${HOME}/LS_COLORS)
