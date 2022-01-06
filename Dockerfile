FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y git sudo

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

WORKDIR dotfiles
COPY . .
RUN ./install.sh

ENTRYPOINT ["/bin/bash"]

