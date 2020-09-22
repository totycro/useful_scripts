#!/bin/sh

TIT=`MPD_HOST=$(get_mpd_host.sh) mpc | head -n1`

F="$HOME/.lyrics/${TIT}.txt"
touch "$F"
echo "paste here, will direct to $F"
cat > "$F"
