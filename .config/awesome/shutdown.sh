#!/bin/bash

WIN_IDs=$(wmctrl -l | awk '$3 != "N/A" {print $1}')

function terminate_applications
{
  for i in $WIN_IDs; do wmctrl -ic "$i"; done
  sleep 3
}

trap unlock EXIT

ACTION=$(zenity --width=90 --height=200 --list --radiolist \
  --text="Select logout action" --title="Logout" \
  --column "Choice" --column "Action" TRUE Shutdown \
  FALSE Reboot FALSE LockScreen FALSE Suspend)

if [ -n "${ACTION}" ];then
  case $ACTION in
  Shutdown)
    terminate_applications
    systemctl poweroff
    ;;
  Reboot)
    terminate_applications
    systemctl reboot
    ;;
  Suspend)
    systemctl suspend
    xautolock -locknow
    ;;
  LockScreen)
    xautolock -locknow
    ;;
  esac
fi

# vim: ft=sh ts=2 sw=2 sts=0 et
