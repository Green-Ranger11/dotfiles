#!/usr/bin/env bash
# VPN status blocklet + toggle for openfortivpn@vodafone (waybar + hyprland).
# Passwordless start/stop relies on the polkit rule in
# /etc/polkit-1/rules.d/50-openfortivpn.rules.

UNIT="openfortivpn@vodafone.service"

case "$1" in
toggle)
	if systemctl is-active --quiet "$UNIT"; then
		systemctl stop "$UNIT"
		notify-send -a "VPN" "󰖂 Vodafone VPN" "Disconnected"
	else
		# start blocks until the tunnel is up (Type=notify) or the unit fails
		if systemctl start "$UNIT" 2>/dev/null && systemctl is-active --quiet "$UNIT"; then
			notify-send -a "VPN" "󰖂 Vodafone VPN" "Connected"
		else
			notify-send -u critical -a "VPN" "󰖂 Vodafone VPN" \
				"Failed to connect — check: journalctl -u $UNIT"
		fi
	fi
	pkill -RTMIN+8 waybar
	;;
*)
	if systemctl is-active --quiet "$UNIT"; then
		printf '{"text":"󰖂 VPN","class":"connected","tooltip":"Vodafone VPN: connected (click to disconnect)"}\n'
	else
		printf '{"text":"󰖂","class":"disconnected","tooltip":"Vodafone VPN: disconnected (click to connect)"}\n'
	fi
	;;
esac
