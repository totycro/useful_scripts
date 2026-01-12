#!/usr/bin/env bash

# settings
DEBUG=true

set -eu -o pipefail
$DEBUG && set -x
KODI_IP=`jq --raw-output ".ip" < /home/osmc/cli_remote.conf`
KODI_PORT=`jq --raw-output ".port" < /home/osmc/cli_remote.conf`
KODI="${KODI_IP}:${KODI_PORT}"
# NFS_SERVER=$(ip a s wlp5s0 | grep "inet " | awk '{ print $2 }' | cut -d'/' -f 1 | head -n 1 )

CURL_ARGS="-s"
$DEBUG && CURL_ARGS="-v"


# this produces sane behavior for "main $@"
IFS=$(echo $IFS | tr -d ' ')



function debug () {
  $DEBUG && echo "Debug: $@"
}

function error () {
  echo "Error: $@" >&2
}


function execute_cmd () {
  debug "Executing $1 with $2"
  _do_call_api $1 $2
}

function _do_call_api () {
  action=$1
  params=${2:-"{}"}
  curl $CURL_ARGS -u kodi:kodi --show-error --header "Content-Type: application/json" --data-binary '{"jsonrpc": "2.0", "method": "'"$action"'", "params": '"$params"',  "id": 1}' http://${KODI}/jsonrpc
}

function get_player_id () {
  # returns first player id, which seems to be the only one in my usage
  _do_call_api "Player.GetActivePlayers" | jq '.result[0].playerid'
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
  arg1=${2:-""}
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
      if [ ${2} = "-" ] ; then
          SIGN="-"
      else
          SIGN=""
      fi
      execute_cmd "Player.Seek" "{\"value\": {\"seconds\": ${SIGN}${3}}, \"playerid\": $(get_player_id)}"
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
    is_playing)
      player_id=$(get_player_id)
      if [ "${player_id}" = "null" ] ; then
        echo "false"
	exit 0
      fi
      result=$(_do_call_api "Player.GetProperties" '{"playerid": '$(get_player_id)', "properties": ["speed"]}')
      speed=$(echo $result | jq '.result.speed')
      if [ "${speed}" = "0" ] || [ "${speed}" = "null" ] ; then
        echo "false"
      else
	echo "true"
      fi
      ;;
    *)
      echo "Here, you should be able to see the usage"
      ;;
  esac
}

main $@
