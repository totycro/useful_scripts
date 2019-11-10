#!/usr/bin/env bash

# settings
KODI="192.168.0.164:80"
NFS_SERVER=$(ip a s wlp5s0 | grep "inet " | awk '{ print $2 }' | cut -d'/' -f 1 | head -n 1 )


# this produces sane behavior for "main $@"
IFS=$(echo $IFS | tr -d ' ')


function debug () {
  echo "Debug: $@"
}

function error () {
  echo "Error: $@" >&2
}


function execute_cmd () {
  action=$1
  params=$2
  debug "Executing $action with $params"
  curl --silent --show-error --header "Content-Type: application/json" --data-binary '{"jsonrpc": "2.0", "method": "'"$action"'", "params": '"$params"',  "id": 1}' http://${KODI}/jsonrpc
}


function get_player_id () {
  # returns first player id, which seems to be the only one in my usage
  curl -s --header "Content-Type: application/json" --data-binary '{"jsonrpc": "2.0", "method": "Player.GetActivePlayers", "id": 1}' http://${KODI}/jsonrpc | jq '.result[0].playerid'
}


function get_seek_time() {
  seek_in_seconds=$1
  player_id=$(get_player_id)
  current_time=$(curl -s --header "Content-Type: application/json" --data-binary '{"jsonrpc": "2.0", "method": "Player.GetProperties",  "params": {"properties": ["time"], "playerid": '$player_id'}, "id": 1}' http://${KODI}/jsonrpc | jq '.result.time')
  python3 - <<END_OF_PYTHON
# yeah, not gonna do this in bash
import json
import datetime
data = $current_time
# this won't work with videos longer than 24 hours
current_time = datetime.datetime(1, 1, 1, data['hours'], data['minutes'], data['seconds'], data['milliseconds'] * 1000)
seek_time = current_time + datetime.timedelta(seconds=$seek_in_seconds)
print({
  "hours": seek_time.hour,
  "minutes": seek_time.minute,
  "seconds": seek_time.second,
  "milliseconds": int(seek_time.microsecond / 1000),
})
END_OF_PYTHON
}


function arg_or_clipboard_content () {
  if [ -z "$1" ] ; then
    xclip -o
  else
    echo $1
  fi
}


function main () {
  cmd=$1
  arg1=$2
  # TODO: use these instead of ${num} below

  if [ -f "$cmd" ] ; then
    arg1=$cmd
    cmd="play_file"
  fi

  case $cmd in
    toggle)
      execute_cmd "Player.PlayPause" '{"playerid": '$(get_player_id)'}'
      ;;
    next)
      execute_cmd "Player.GoTo" '{"playerid": '$(get_player_id)', "to": "next"}'
      ;;
    prev)
      execute_cmd "Player.GoTo" '{"playerid": '$(get_player_id)', "to": "previous"}'
      ;;
    seek)
      case $2 in
        +)
          seek_time=$(get_seek_time $3 | tr \' \")
          ;;
        -)
          seek_time=$(get_seek_time -$3 | tr \' \")
          ;;
        *)
          error "$2 is neither \"+\" nor \"-\""
          exit 1
          ;;
      esac
      execute_cmd "Player.Seek" "{\"value\": $seek_time, \"playerid\": $(get_player_id)}"
      ;;
    play_file)
      file=$(arg_or_clipboard_content "$arg1")
      path=$(realpath "$(pwd)/${file}")
      nfs_path="nfs://${NFS_SERVER}${path}"
      execute_cmd "Player.Open" "{\"item\": {\"file\": \"${nfs_path}\"}}"
      ;;
    play_youtube)
      youtube_url=$(arg_or_clipboard_content $2)
      regex="^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*"
      if [[ "$youtube_url" =~ $regex ]]; then
        id=${BASH_REMATCH[7]}
      else
        error "Failed to parse youtube url"
        exit 1
      fi
      debug "Playing video with id ${id}"
      youtube_plugin_path="plugin://plugin.video.youtube/play/?video_id=$id"
      execute_cmd "Player.Open" "{\"item\": {\"file\": \"${youtube_plugin_path}\"}}"
      ;;
    vol)
      # if parameter is "+4", ignore 4 for now since we have a custom increment/decrement here and want to be compatible to mcc
      case $2 in
        +*)
          execute_cmd "Application.SetVolume" '{"volume": "increment"}'
          ;;
        -*)
          execute_cmd "Application.SetVolume" '{"volume": "decrement"}'
          ;;
        *)
          error "$2 is neither \"+\" nor \"-\""
          ;;
      esac
      ;;
    *)
      echo "Here, you should be able to see the usage"
      ;;
  esac
}

main $@
