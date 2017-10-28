#!/bin/sh

RES_FOUR_K=3840x2160  
RES_HD=1920x1080


function get_res () {
	xrandr  | grep HDMI-0 | awk '{print $3}' | cut -d '+' -f 1
}

function set_res () {
	xrandr --output HDMI-0 --mode $1
}


if [ `get_res` = $RES_HD ] ; then
	set_res $RES_FOUR_K
elif [ `get_res` = $RES_FOUR_K ] ; then
	set_res $RES_HD
else
	echo "Unknown current resolution: $(get_res)" > 2
	exit 1
fi

/usr/local/bin/set_random_wallpaper.sh

exit 0
