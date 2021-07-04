#!/usr/bin/env bash

set -e

# ctrl + shift - right : prevLabel="label_$RANDOM" && \
#                       prevIdx=$(yabai -m query --spaces --space prev | jq .index) && \
#                       yabai -m space $prevIdx --label $prevLabel && \
#                       currLabel="label_$RANDOM" && \
#                       currIdx=$(yabai -m query --spaces --space | jq .index) && \
#                       yabai -m space $currIdx --label $currLabel && \
#                       (yabai -m space --display next || yabai -m space --display first) && \
#                       yabai -m space --focus $prevLabel && \
#                       yabai -m space --focus $currLabel


spaceIdToIndex() {
    id=$1
    index=$(yabai -m query --spaces | jq 'map(select( .id == '$id' )) | .[0].index')
    echo $index
}

moveSpaceRight() {
    currSpaceId=$(yabai -m query --spaces --space | jq .id)
    prevSpaceId=$(yabai -m query --spaces --space prev | jq .id)

    # Move the current space to the next display, failing that, move to first.
    yabai -m space --display next 2> /dev/null || yabai -m space --display first

    yabai -m space --focus $(spaceIdToIndex $prevSpaceId)
    yabai -m space --focus $(spaceIdToIndex $currSpaceId)
}

moveSpaceLeft() {
    currSpaceId=$(yabai -m query --spaces --space | jq .id)
    prevSpaceId=$(yabai -m query --spaces --space prev | jq .id)

    # Move the current space to the next display, failing that, move to first.
    yabai -m space --display prev 2> /dev/null || yabai -m space --display last

    yabai -m space --focus $(spaceIdToIndex $prevSpaceId)
    yabai -m space --focus $(spaceIdToIndex $currSpaceId)
}

if [[ $1 == "right" ]]; then
    moveSpaceRight
elif [[ $1 == "left" ]]; then
    moveSpaceLeft
else
    echo "Unknown command: $1"
fi

