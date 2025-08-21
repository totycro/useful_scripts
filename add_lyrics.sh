#!/bin/sh

TIT=`mpc | head -n1`

F="$HOME/.lyrics/${TIT}.txt"
touch "$F"
echo "paste here, will direct to $F"
cat > "$F"
