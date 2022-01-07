#!/usr/bin/env sh

command -v go > /dev/null && hasGo="true"
if [ -n "$hasGo" ]; then
    # Note: Not using exit 0 because this script may be sourced instead of
    # executed.

    : # no-op
else
    if [ "$os" = "Linux" ]; then

        # ------------------------------------------------ Downloading Go ------

        osLower=$(uname | tr '[:upper:]' '[:lower:]')
        printf "[*] Detected OS: $osLower\n"

        uname -m | grep 64 > /dev/null \
            && arch="amd64" \
                || arch="386"
        printf "[*] Detected architecture: $arch\n"

        goDownloadUrl='https://go.dev/dl/'
        tarballUrl=$(curl -L --silent $goDownloadUrl \
                         | grep --only-matching -E 'dl/go.*\.src\.tar\.gz' \
                         | sed -E "s#src#$osLower-$arch# ; s#(.*)#https://go.dev/\1#" \
                         | head -n 1)
        printf "[>] Downloading latest Go binaries from: $tarballUrl\n"
        (cd "${DOTFILES_INSTALLERS_DIR}" && curl -L -O $tarballUrl)

        # ------------------------------------------------- Installing Go ------

        tarballFilename="${DOTFILES_INSTALLERS_DIR}/${tarballUrl##*/}"
        sudo mkdir -p /usr/local
        sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $tarballFilename

        export GOROOT="/usr/local/go"
        export PATH="$GOROOT/bin:$PATH"
        export GOPATH="$HOME/go"
        export GOBIN="$GOPATH/bin"
        export PATH="$GOBIN:$PATH"

    elif [ "$os" = "Darwin" ]; then
        # TODO: Consider manual installation to get latest version.
        brew install go

        # TODO: Consider whether need to set up Go environment variables.
    fi
fi
