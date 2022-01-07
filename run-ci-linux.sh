#!/usr/bin/env sh

# Build the docker image, which includes running the dotfiles installation
# script.
sudo docker build -t dotfiles-ci-linux .

# Start the container and get a shell to check that the system is set up
# properly.
sudo docker run -it dotfiles-ci-linux

# TODO: Actually make this into a CI script.

