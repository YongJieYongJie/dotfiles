#!/usr/bin/env sh

# Usage:
#    - Run "run-ci-darwin.sh setup" to start the docker container which starts
#    the macOS VM, and then run the dotfiles installation script.
#
#    - Run "run-ci-darwin.sh ssh" or "run-ci-darwin.sh gui" to enter the macOS
#    VM to check that the system has been set up properly.
#
#    - For details regarding the Docker/VM set-up, see
#    https://github.com/sickcodes/Docker-OSX for details.

# TODO: Actually make this into a CI script.

dotfilesRepoRoot=$(realpath $(dirname "$0"))

macOsHddImgAbsPath=""
if [ -z "macOsHddImgAbsPath" ]; then
  printf "[!] macOsHddImgAbsPath not provided. Please provide the path to\n"
  printf "    the macOS HDD image, or download one by running the command:\n"
  printf "        wget https://images2.sick.codes/mac_hdd_ng_auto.img\n"
  exit 1
fi

mode="$1"
if [ "$mode" = "setup" ]; then
  # Run sudo once so we get prompted for password now, and the next sudo command
  # will not prompt again.
  sudo -v

  # Note: To get a shell into the macOS system, simply remove the echo
  # immediately below.
  echo 'echo alpine | sudo -S mount_9p hostshare \
    && cd ~ && rm -rf dotfiles_repo && cp -R /Volumes/hostshare dotfiles_repo \
    && CI_PASSWORD=alpine ~/dotfiles_repo/install.sh' |\
    sudo docker run -i --rm \
    --name docker-osx-setup
    --device /dev/kvm \
    -p 50922:10022 \
    -v "${macOsHddImgAbsPath}/mac_hdd_ng_auto.img:/images" \
    -e IMAGE_PATH=/image \
    -v "${dotfilesRepoRoot}:/mnt/hostshare" \
    -e EXTRA="-virtfs local,path=/mnt/hostshare,mount_tag=hostshare,security_model=passthrough,id=hostshare" \
    -e "USERNAME=user" \
    -e "PASSWORD=alpine" \
    -e GENERATE_UNIQUE=true \
    -e MASTER_PLIST_URL=https://raw.githubusercontent.com/sickcodes/Docker-OSX/master/custom/config-nopicker-custom.plist \
    sickcodes/docker-osx:naked-auto

elif  [ "$mode" = "gui" ]; then
  sudo docker run \
    --name docker-osx-gui \
    --detach \
    --device /dev/kvm \
    -p 50922:10022 \
    -v "${macOsHddImgAbsPath}:/image" \
    -e IMAGE_PATH=/image \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e WIDTH=1280 \
    -e HEIGHT=768 \
    -e "DISPLAY=${DISPLAY:-:0.0}" \
    -e GENERATE_UNIQUE=true \
    -e MASTER_PLIST_URL=https://raw.githubusercontent.com/sickcodes/Docker-OSX/master/custom/config-nopicker-custom.plist \
    sickcodes/docker-osx:naked

else 
  # Default to shell access
  sudo docker run \
    --name docker-osx-ssh \
    --detach \
    --device /dev/kvm \
    -p 50922:10022 \
    -v "${macOsHddImgAbsPath}:/image" \
    -e IMAGE_PATH=/image \
    -e GENERATE_UNIQUE=true \
    -e MASTER_PLIST_URL=https://raw.githubusercontent.com/sickcodes/Docker-OSX/master/custom/config-nopicker-custom.plist \
    sickcodes/docker-osx:naked

  until ssh user@localhost -p 50922 ls; do
    printf "[*] Still trying to connect to macOS (password is alpine)...\n"
    sleep 10
  done

fi
