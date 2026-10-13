#!/usr/bin/env bash

PLAYER_CONFIG_FILE=~/.config/dispatch_to_some_player/player

player=$(cat "${PLAYER_CONFIG_FILE}")

if [ "$1" = "switch_player" ] ; then
    if [ "${player}" = "mcc" ] ; then
        player="kodi"
    else
        player="mcc"
    fi
    echo "${player}" > "${PLAYER_CONFIG_FILE}"
    player=""  # disable futher execution
fi


# NOTE: while we now solved the issue when we are in a differnet network,
#       it's still awkward to unpause kodi
kodi_is_playing=$(/home/totycro/bin/kodi-cmd.sh is_playing)

# if kodi is playing, assume commands should go to kodi
# to unpause, we do need the config file in any case though
if [ "${kodi_is_playing}" = "true" ] ; then
  player="kodi"
fi

case $player in
  kodi)
    /home/totycro/bin/kodi-cmd.sh $@
    ;;
  mcc)
    /usr/bin/mpc $@
    # no qt4 atm :/
    #/usr/local/bin/mcc.sh $@
    ;;
esac


notify-send \
  --expire-time=2000 \
  --icon=dialog-information \
  --urgency=low \
  "${player}" \
  "${*}" &


