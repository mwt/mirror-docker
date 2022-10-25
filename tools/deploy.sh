#!/bin/sh

rsync -avxHAX --delete "$1" "mirror-lu-p:$1"
