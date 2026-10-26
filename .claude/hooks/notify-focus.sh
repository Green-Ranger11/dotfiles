#!/bin/sh
# Claude Code `Notification` + `Stop` hook: desktop toast when Claude needs
# attention (permission prompt, waiting for input) or finishes a turn.
# Clicking the toast jumps to this session: Hyprland focuses the kitty window
# (and its workspace), then herdr focuses the pane, which switches herdr's
# own workspace/tab as needed.
#
# Hook input (JSON on stdin): hook_event_name, session_id, cwd, and for
# Notification: message, title, notification_type.
# HERDR_PANE_ID / KITTY_PID come from the session's environment.

set -u
input=$(cat 2>/dev/null || true)
event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty' 2>/dev/null)
msg=$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)
title=$(printf '%s' "$input" | jq -r '.title // empty' 2>/dev/null)
kind=$(printf '%s' "$input" | jq -r '.notification_type // empty' 2>/dev/null)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
dir="${cwd##*/}"; [ -n "$dir" ] || dir="Claude"
# fire-time log line (diagnosing double toasts): one line per hook invocation
printf '%s FIRE event=%s kind=%s pid=%s ppid=%s pane=%s cwd=%s\n' "$(date +%T)" "$event" "$kind" "$$" "$PPID" "${HERDR_PANE_ID:-}" "$dir" >>"${XDG_CACHE_HOME:-$HOME/.cache}/claude-notify.log"

urgency=normal
case "$event" in
Stop)
    title="Done: $dir"
    [ -n "$msg" ] || msg="Claude finished its turn"
    urgency=low ;;
*)
    [ -n "$title" ] || title="Claude: $dir${HERDR_PANE_ID:+ (${HERDR_PANE_ID%%:*})}"
    [ -n "$msg" ] || msg="Claude needs attention"
    [ "$kind" = permission_prompt ] && urgency=critical ;;
esac

# macOS: plain Notification Center banner (no click-to-focus there).
if [ "$(uname)" = Darwin ]; then
    osascript -e 'on run {t, m}' -e 'display notification m with title t' -e 'end run' "$title" "$msg" >/dev/null 2>&1
    exit 0
fi

# notify-send --action blocks until the toast is clicked or closed, and the
# hook has a timeout: detach, then act on the printed action name.
setsid -f sh -c '
    # x-canonical-private-synchronous: one live toast per session; a new one
    # replaces the old card (critical permission toasts never expire on their own).
    act=$(notify-send -a "Claude Code" -u "$3" -h string:desktop-entry:kitty -h "string:x-canonical-private-synchronous:claude-${2:-$1}" -A default=Open -- "$4" "$5")
    log=${XDG_CACHE_HOME:-$HOME/.cache}/claude-notify.log
    printf "%s act=[%s] kitty=%s pane=%s\n" "$(date +%T)" "$act" "$1" "$2" >>"$log"
    [ "$act" = default ] || exit 0
    # Hyprland 0.56 dispatch is Lua; the old "focuswindow pid:N" form errors.
    [ -n "$1" ] && hyprctl dispatch "hl.dsp.focus({ window = hl.get_window(\"pid:$1\") })" >>"$log" 2>&1
    [ -n "$2" ] && herdr agent focus "$2" >/dev/null 2>>"$log"
' _ "${KITTY_PID:-}" "${HERDR_PANE_ID:-}" "$urgency" "$title" "$msg" >/dev/null 2>&1 </dev/null
exit 0
