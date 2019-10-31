#!/bin/bash

killall  conky

# wenn conky -o dann durch transparentes fenster sichtbar
#/usr/bin/conky -o &
#conky -c ~/.conkyrc3 -x $((1280/2-150)) &
#/usr/bin/conky -o -c ~/.conkyrc3  &

UPDATE_INTERVAL=2

if acpi --ac-adapter | grep -q "off-lin" ; then
	# higher update interval if on battery
	UPDATE_INTERVAL=4
fi
nice -n 19 ionice -c 3 /usr/bin/conky -q -c ~/.conkyrc-cur -u ${UPDATE_INTERVAL}

#nice -n15 /usr/bin/fbpager &
