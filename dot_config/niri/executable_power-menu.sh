#!/bin/sh
choice=$(\
    printf "Lock\nSusped\nHibernate\nReboot\nShutdown" \
    | wofi --dmenu --hide-search \
    --width 200 --height 300 \
)

case "$choice" in
  Lock) swaylock ;;
  Suspend) systemctl suspend ;;
  Reboot) systemctl reboot ;;
  Hibernate) systemctl hibernate ;;
  Shutdown) systemctl poweroff ;;
esac

