#!/usr/bin/env bash

set -e

focusSpaceOnCurrentDisplayNext() {
    currDisplay=$(yabai -m query --displays --display | jq .index)

    # Focus the next space, and failing that, focus the first space
    yabai -m space --focus next || yabai -m space --focus first

    # If we have selected a space representing the default "desktop" space on a
    # different display, we continue on and select the next space before this
    # "desktop" space is tight to particular display.
    # isFullScreenApp=$(yabai -m query --spaces --space | jq '."native-fullscreen"')
    # echo "isFullScreenApp $isFullScreenApp"
    # newDisplay=$(yabai -m query --displays --display | jq .index)
    # if [[ !$isFullScreenApp && ($newDisplay -ne $currDisplay) ]]; then
    #     yabai -m space --focus next
    # fi

    # Move the space to the current display
    newDisplay=$(yabai -m query --displays --display | jq .index)
    if [[ $newDisplay -ne $currDisplay ]]; then
        yabai -m space --display $currDisplay
    fi
}

focusSpaceOnCurrentDisplayPrev() {
    currDisplay=$(yabai -m query --displays --display | jq .index)

    # Focus the next space, and failing that, focus the first space
    yabai -m space --focus prev || yabai -m space --focus last

    # If we have selected a space representing the default "desktop" space on a
    # different display, we continue on and select the next space before this
    # "desktop" space is tight to particular display.
    # isFullScreenApp=$(yabai -m query --spaces --space | jq '."native-fullscreen"')
    # echo "isFullScreenApp $isFullScreenApp"
    # newDisplay=$(yabai -m query --displays --display | jq .index)
    # if [[ !$isFullScreenApp && ($newDisplay -ne $currDisplay) ]]; then
    #     yabai -m space --focus prev
    # fi

    # Move the space to the current display
    newDisplay=$(yabai -m query --displays --display | jq .index)
    if [[ $newDisplay -ne $currDisplay ]]; then
        yabai -m space --display $currDisplay
    fi
}

if [[ $1 == "next" ]]; then
    focusSpaceOnCurrentDisplayNext
elif [[ $1 == "prev"  ]]; then
    focusSpaceOnCurrentDisplayPrev
else
    echo "Unknown command: $1"
fi

