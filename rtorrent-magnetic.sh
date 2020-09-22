#!/bin/bash
watch_folder=/home/totycro/.rtorrent-watch-dir

[[ "$1" =~ xt=urn:btih:([^&/]+) ]] || exit;
echo "d10:magnet-uri${#1}:${1}e" > "/tmp/meta-${BASH_REMATCH[1]}.torrent"

scp "/tmp/meta-${BASH_REMATCH[1]}.torrent" 192.168.0.100:${watch_folder}/meta-${BASH_REMATCH[1]}.torrent

echo "wrote torrent to `pwd`/meta-${BASH_REMATCH[1]}.torrent"

