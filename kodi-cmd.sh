#!/usr/bin/env bash

KODI="10.0.0.10:80"


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
  curl -s --header "Content-Type: application/json" --data-binary '{"jsonrpc": "2.0", "method": "'"$action"'", "params": '"$params"',  "id": 1}' http://${KODI}/jsonrpc | jq
}


function get_player_id () {
  # returns first player id, which seems to be the only one in my usage
  curl -v --header "Content-Type: application/json" --data-binary '{"jsonrpc": "2.0", "method": "Player.GetActivePlayers", "id": 1}' http://10.0.0.10/jsonrpc | jq '.result[0].playerid'
}

function main () {
  case $1 in 
    toggle)
      execute_cmd "Player.PlayPause" '{"playerid": '$(get_player_id)'}'
      ;;
    next)
      execute_cmd "Player.GoTo" '{"playerid": '$(get_player_id)', "to": "next"}'
      ;;
    prev)
      execute_cmd "Player.GoTo" '{"playerid": '$(get_player_id)', "to": "previous"}'
      ;;
    vol)
      case $2 in
        +)
          execute_cmd "Application.SetVolume" '{"volume": "increment"}'
          ;;
        -)
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
