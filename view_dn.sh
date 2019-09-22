#!/bin/bash -x

last_dn_day_delta=1
if [[ $(date +%u) -eq 7 ]] ; then  # Sunday
    last_dn_day_delta=2
fi
if [[ $(date +%u) -eq 1 ]] ; then  # Monday
    last_dn_day_delta=3
fi

timestamp_now=$(date +%s)

timestamp_last_dn=$(($timestamp_now - ($last_dn_day_delta * 24 * 60 * 60) ))

last_dn_day=$(date --date=@${timestamp_last_dn} +%Y-%m%d)

url=https://publish.dvlabs.com/democracynow/360/dn${last_dn_day}.mp4

cd /home/totycro/downs
strm_file=dn.strm

echo $url > "$strm_file"

~/bin/kodi-cmd.sh "$strm_file"

