#!/usr/bin/env bash

set -e

toggleRecentSpaceOnCurrentDisplay() {
    # Index of the display that the current space is on.
    currSpaceDisplay=$(yabai -m query --displays --space | jq .index)

    # Index of the display that the recent space (i.e., the previous) is one.
    recentSpaceDisplay=$(yabai -m query --displays --space recent | jq .index)

    # If the previous space is on a different display, we bring it over first.
    if [[ $currSpaceDisplay -ne $recentSpaceDisplay ]]; then
        yabai -m space recent --display $currSpaceDisplay
    fi

    # Finally, we switch to the recent space.
    yabai -m space --focus recent
}

toggleRecentSpaceOnCurrentDisplay
