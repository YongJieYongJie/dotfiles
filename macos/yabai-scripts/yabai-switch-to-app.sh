#!/usr/bin/env bash

# TODO: Make this script run faster

# Usage:
#     yabai-switch-to-app.sh <app-name>

# Accepts a JSON array of windows and focuses the next window with index greater
# than the currently focus (looping around if the currently focused windows has
# the greatest index). Focuses the first window if none is focused.
#
# Logic:
# 1. If no windows with AppName, return
# 2. If only one window with AppName, just try to focus it
# 3. Else (there are multiple windows with AppName)
#    a. If already focused, focus next window with higher index (wrapping around)
#    b. Otherwise, focus first in windows list
focusNext() {
    appName=$(echo "$1" | tr '[:upper:]' '[:lower:]')

    # Select windows with the `app` field matching `appName` (after projecting
    # only the `app`, `id`, `space` and `focused` fields to make the JSON
    # smaller)
    windowsWithApp=$(yabai -m query --windows | tr '[:upper:]' '[:lower:]' | jq --compact-output \
        'map({app, id, space, focused} | select( .app | contains("'"$appName"'")))')
    # echo "[D] windowsWithApp: $windowsWithApp"
    # Check if the output is empty JSON array (i.e., "[]") by checking length
    if [[ ${#windowsWithApp} -le 2 ]]
    then
        # echo "[*] No window with $appName found."
        return 1
    fi

    numWindows=$(echo "$windowsWithApp" | jq 'length')
    # echo "[D] numWindows: $numWindows"
    if [[ $numWindows -eq 1 ]]
    then
        # echo "[*] Found one window with $appName, focusing..."
        yabai -m space --focus $(echo "$windowsWithApp" | jq ".[0].space")
        return 0
    fi

    # Check if any window is already focused, if not, we just focus the first
    # (assuming that is the last recently used)
    currentFocusedWindowIndex=$(echo "$windowsWithApp" | jq 'map(select( .focused == 1)) | .[0].id')
    # echo "[D] currentFocusedWindowIndex: $currentFocusedWindowIndex"
    if [[ $currentFocusedWindowIndex = "null" ]];
    then
        # echo "[*] Found $numWindows windows with $appName, focusing the last-recently-used..."
        yabai -m space --focus $(echo "$windowsWithApp" | jq ".[0].space")
        return 0
    fi

    # If we reach here, it means that a window with `appName` is alraedy
    # focused, we need to find the next window to focus, based on index

    windowsSorted=$(echo "$windowsWithApp" | jq --compact-output 'sort_by(.id)')
    # echo "[D] windowsSorted: $windowsSorted"
    nextGreater=$(echo "$windowsSorted" | jq --compact-output 'map(select( .id > '$currentFocusedWindowIndex'))')
    # echo "[D] nextGreater: $nextGreater"
    # Check if the output is empty JSON array (i.e., "[]") by checking length
    if [[ ${#nextGreater} -le 2 ]]
    then
        # echo "[*] Focusing the next window based ordered by index (looped around)..."
        yabai -m space --focus $(echo "$windowsSorted" | jq '.[0].space')
        return 0
    else
        # echo "[*] Focusing the next window based ordered by index..."
        yabai -m space --focus $(echo "$nextGreater" | jq '.[0].space')
        return 0
    fi
}


# echo "[*] Attempting to switch to next window with application \"$1\"..."
focusNext "$1"
# echo "[*] Done!"

# ----------------------------- Reference Commands -----------------------------

# command to get all visible spaces
# yabai -m query --spaces | jq 'map(select( .visible == 1 ))'

# command to get focused display
# yabai -m query --displays --display | jq '.index'

# command to focus display index 2
# yabai -m display --focus 2
