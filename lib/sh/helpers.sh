#/usr/bin/env sh

# This file contains sh-related helper functions, and may be "imported" by
# sourcing it.

# Creates a symbolic link at the location of the second argument pointing to the
# first argument, creating backup if the target location already has a file.
lnWithBackup()
{
    from=$(realpath "$1")
    to="$2"

    if [ -f "$to" ] || [ -L "$to" ]; then
        mv "$to" "$to.bak.$(date +%Y%m%d_%H%M)"
    fi

    targetDir=$(dirname "$to") # TODO: Get absolute directory if necessary.
    mkdir -p "$targetDir"

    ln -s "$from" "$to"
}
