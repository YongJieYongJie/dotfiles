#!/usr/bin/env bash

set -e

showDebugNotification() {
    currSpaceIdx=$(yabai -m query --spaces --space | jq .index)
    recentSpaceIdx=$(yabai -m query --spaces --space recent | jq .index)
    currSpaceDisplay=$(yabai -m query --displays --space | jq .index)
    recentSpaceDisplay=$(yabai -m query --displays --space recent | jq .index)

    /usr/bin/env osascript <<EOF
display notification "\
Curr {SID: $currSpaceIdx DID: $currSpaceDisplay} \
Prev {SID: $recentSpaceIdx DID: $recentSpaceDisplay}\
" \
with title "yabai debug"
EOF
}

showDebugNotification
