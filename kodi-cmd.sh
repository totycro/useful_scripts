#!/usr/bin/env bash

set -x

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
  /usr/bin/curl -s --header "Content-Type: application/json" --data-binary '{"jsonrpc": "2.0", "method": "'"$action"'", "params": '"$params"',  "id": 1}' http://10.0.0.10/jsonrpc | /usr/bin/jq
}


function main () {
  case $1 in 
    toggle)
      echo "Play/Pause"
      execute_cmd "Player.PlayPause" '{"playerid": 0}'
      ;;
    next)
      echo "Next"
      execute_cmd "Player.GoTo" '{"playerid": 0, "to": "next"}'
      ;;
    prev)
      echo "Prev"
      execute_cmd "Player.GoTo" '{"playerid": 0, "to": "previous"}'
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
