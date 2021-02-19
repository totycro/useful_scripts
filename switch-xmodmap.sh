#!/usr/bin/env bash

set -eux -o pipefail

# check what o with modifier currently is
O_MOD=$(xmodmap -pk | grep 0x006f | awk '{ print $7 }')
case $O_MOD in
    "(oacute)")
        # is spanish, switch to german
        xmodmap ~/.Xmodmap
        echo "Switched to german"
        ;;
    "(odiaeresis)")
        # is german, switch to spanish
        xmodmap ~/.Xmodmap-es
        echo "Switched to spanish"
        ;;
    *)
        echo "Couldn't determine current layout, exiting"
        exit 1
        ;;
esac


