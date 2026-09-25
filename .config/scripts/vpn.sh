#!/usr/bin/env bash
# VPN toggle for openfortivpn@<name> (default vodafone), used by the
# Quickshell network menu and the bar VPN icon.
# Usage: vpn.sh [toggle] [name]  (name = /etc/openfortivpn/<name>.conf)
# Passwordless start/stop relies on the polkit rule in
# /etc/polkit-1/rules.d/50-openfortivpn.rules.

NAME="${2:-vodafone}"
UNIT="openfortivpn@$NAME.service"

case "$1" in
toggle)
	if systemctl is-active --quiet "$UNIT"; then
		systemctl stop "$UNIT"
		notify-send -a "VPN" "󰖂 VPN: $NAME" "Disconnected"
	else
		# start blocks until the tunnel is up (Type=notify) or the unit fails
		if systemctl start "$UNIT" 2>/dev/null && systemctl is-active --quiet "$UNIT"; then
			notify-send -a "VPN" "󰖂 VPN: $NAME" "Connected"
		else
			notify-send -u critical -a "VPN" "󰖂 VPN: $NAME" \
				"Failed to connect — check: journalctl -u $UNIT"
		fi
	fi
	;;
*)
	echo "usage: vpn.sh toggle [name]" >&2
	exit 1
	;;
esac
