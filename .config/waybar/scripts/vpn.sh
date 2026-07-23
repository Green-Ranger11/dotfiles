#!/usr/bin/env bash
# VPN status blocklet + toggle for openfortivpn@vodafone (waybar + hyprland).
# Passwordless start/stop relies on the polkit rule in
# /etc/polkit-1/rules.d/50-openfortivpn.rules.

UNIT="openfortivpn@vodafone.service"

case "$1" in
toggle)
	if systemctl is-active --quiet "$UNIT"; then
		systemctl stop "$UNIT"
	else
		systemctl start "$UNIT"
	fi
	pkill -RTMIN+8 waybar
	;;
*)
	if systemctl is-active --quiet "$UNIT"; then
		printf '{"text":"󰖂","class":"connected","tooltip":"Vodafone VPN: connected (click to disconnect)"}\n'
	else
		printf '{"text":"󰖂","class":"disconnected","tooltip":"Vodafone VPN: disconnected (click to connect)"}\n'
	fi
	;;
esac
