#!/bin/sh
#
# lied_merken.sh
#
# USAGE: lied_merken.sh [ -l | -e | -h ]
#
# Writes current mpd song to a file or
# displayes this file if "-l" is specified or
# lets you edit db file with "-e" or
# displays help with "-h"
#

export MPD_HOST=192.168.0.100

DB_FILE=~/.gemerkte_lieder

if [ "$1" = "-l" ] ; then
	cat $DB_FILE
elif [ "$1" = "-e" ] ; then
	$EDITOR $DB_FILE
elif [ "$1" = "-h" ] ; then
	head $0 | tail -n6
else
	SONG=`mpc | head -n1`
	if grep "$SONG" $DB_FILE >/dev/null; then
		echo "Current song is already in database -- $SONG"
	else
		echo "$SONG" >> $DB_FILE
		echo "Remembered: `tail -n1 $DB_FILE`"
	fi
fi
