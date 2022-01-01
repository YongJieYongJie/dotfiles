#!/usr/bin/env sh

set -e

command -v go > /dev/null && alreadyInstalled="true"
if [ "$alreadyInstalled" = "true" ]; then
  printf "[*] Go already installed at: $(command -v go)\n"
else

  # ------------------------------------------------------ Downloading Go ------

  os=$(uname | tr '[:upper:]' '[:lower:]')
  printf "[*] Detected OS: $os\n"

  uname -m | grep 64 > /dev/null \
    && arch="amd64" \
    || arch="386"
  printf "[*] Detected architecture: $arch\n"

  goDownloadUrl='https://go.dev/dl/'
  tarballUrl=$(curl -L --silent $goDownloadUrl |\
    grep --only-matching -E 'dl/go.*\.src\.tar\.gz' |\
    sed -E "s#src#$os-$arch# ; s#(.*)#https://go.dev/\1#" |\
    head -n 1)
  printf "[>] Downloading latest Go binaries from: $tarballUrl\n"
  curl -L -O $tarballUrl

  # ------------------------------------------------------- Installing Go ------

  tarballFilename=$(echo $tarballUrl | grep --only-matching -E "go.*\.tar\.gz")

  if [ "$os" != "linux" ]; then
    printf "[!] Unable to automatically install for unless OS is linux.\n\
    Please manually install from tarball at $(pwd)/$tarballFilename\n"
  else

    tarballFilename=$(echo $tarballUrl | grep --only-matching -E "go.*\.tar\.gz")
    if [ -z $tarballFilename ]; then
      printf "[!] Invalid filename for Go tarball: $tarballFilename\n"
    else
      printf "[*] Extracting Go from tarball: $(pwd)/$tarballFilename\n"
      sudo rm -rf /usr/local/go \
        && sudo tar -C /usr/local -xzf $tarballFilename
    fi

  fi

fi
