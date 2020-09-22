#!/bin/sh



function get_ip_from_mpd_conf {
	LINE=`grep "bind_to_address" "/etc/mpd.conf" | grep -v "^#" | head -n 1`
	
	echo -n \"
	echo -n $LINE | awk '{print $2}' | sed -e "s/\"//g"
	echo \"
}


function get_ip_from_net_iface {
	ip addr show wlp5s0 | grep "inet " | awk '{ print $2; }' | cut -d '/' -f 1
}

get_ip_from_net_iface
