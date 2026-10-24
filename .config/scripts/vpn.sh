#!/usr/bin/env bash
# VPN toggle for openfortivpn@<name> (default vodafone), used by the
# Quickshell network menu and the bar VPN icon.
# Usage: vpn.sh toggle|status [name]  (name = /etc/openfortivpn/<name>.conf)
# status prints a systemctl is-active state (active, activating, inactive...),
# or "missing" when there's no such config, so machines without one hide it.
#
# Linux: passwordless start/stop relies on the polkit rule in
# /etc/polkit-1/rules.d/50-openfortivpn.rules.
# macOS: there's no systemd, so macos/openfortivpn-ctl runs openfortivpn
# through sudo; set it up once with: sudo ~/.config/scripts/macos/install-vpn

NAME="${2:-vodafone}"
UNIT="openfortivpn@$NAME.service"
# Run from a terminal on macOS there may be no notify-send (Laumei provides
# one to the bar); the toggle still works without it.
notify() { command -v notify-send >/dev/null && notify-send "$@"; }

if [ "$(uname)" = Darwin ]; then
	vpn_status() {
		pid=$(cat "/var/run/openfortivpn/$NAME.pid" 2>/dev/null)
		# ps, not kill -0: openfortivpn runs as root.
		if [ -n "$pid" ] && ps -p "$pid" >/dev/null 2>&1; then
			if grep -q 'Tunnel is up and running' "/var/run/openfortivpn/$NAME.log" 2>/dev/null; then
				echo active
			else
				echo activating
			fi
		else
			echo inactive
		fi
	}
	vpn_start() { sudo -n /usr/local/libexec/openfortivpn-ctl start "$NAME" 2>/dev/null; }
	vpn_stop() { sudo -n /usr/local/libexec/openfortivpn-ctl stop "$NAME"; }
	LOGS="/var/run/openfortivpn/$NAME.log"
else
	vpn_status() { systemctl is-active "$UNIT"; }
	# start blocks until the tunnel is up (Type=notify) or the unit fails
	vpn_start() { systemctl start "$UNIT" 2>/dev/null; }
	vpn_stop() { systemctl stop "$UNIT"; }
	LOGS="journalctl -u $UNIT"
fi

case "$1" in
toggle)
	if [ "$(vpn_status)" = active ]; then
		vpn_stop
		notify -a "VPN" "󰖂 VPN: $NAME" "Disconnected"
	else
		if vpn_start && [ "$(vpn_status)" = active ]; then
			notify -a "VPN" "󰖂 VPN: $NAME" "Connected"
		else
			notify -u critical -a "VPN" "󰖂 VPN: $NAME" \
				"Failed to connect — check: $LOGS"
		fi
	fi
	;;
status)
	if [ -e "/etc/openfortivpn/$NAME.conf" ]; then vpn_status; else echo missing; fi
	;;
*)
	echo "usage: vpn.sh toggle|status [name]" >&2
	exit 1
	;;
esac
