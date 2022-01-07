#!/usr/bin/env sh

command -v brew > /dev/null && exit 0
[ "$os" = "Darwin" ] || exit 1

if [ -n "$CI_PASSWORD" ]; then
    # If password for CI is provided, we create a script that'll echo this
    # password. This is required because the install.sh for installing Homebrew
    # uses sudo.
    echo "$CI_PASSWORD" | sudo -S touch ${HOME}/echo_ci_password
    echo "$CI_PASSWORD" | sudo -S \sh -c "echo '#!/usr/bin/env sh\necho $CI_PASSWORD' > ${HOME}/echo_ci_password"
    echo "$CI_PASSWORD" | sudo -S chown $(id -u):$(id -g) ${HOME}/echo_ci_password
    chmod +x ${HOME}/echo_ci_password
    export SUDO_ASKPASS=${HOME}/echo_ci_password
fi

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

rm -rf ${HOME}/echo_ci_password
