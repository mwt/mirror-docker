#!/bin/sh

rsync -avxHAX --delete "$1/" "mirror-lu-p:$1"
rsync -avxHAX --delete "$1/" "second:$1"
ssh mirror-lu-p "rsync -avxHAX --delete \"$1/\" \"second:$1\""
