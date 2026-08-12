#FASTFETCH
if command -v fastfetch &> /dev/null; then
  # fastfetch's kitty-icat logo QUERIES the terminal and reads the reply from
  # the tty -- that read swallows anything already buffered on stdin. In herdr
  # panes that buffer can hold the injected `claude --resume <id>` from agent
  # restore. If input is pending, skip fastfetch entirely (claude's TUI is
  # about to cover the pane anyway); otherwise run it normally with the PNG.
  zmodload zsh/zselect 2>/dev/null
  if [ -n "$HERDR_PANE_ID" ] && zselect -t 0 -r 0 2>/dev/null; then
    : # pending input (herdr injection) -- don't let anything touch the tty
  else
    fastfetch
  fi
  # kitty graphics under tmux: `kitten icat` detects tmux and uses Unicode
  # placeholders (--passthrough=detect implies --unicode-placeholder). The
  # placeholder cells go into tmux's grid as text, but kitty won't composite
  # the image over them until tmux repaints those cells -- so in a fresh pane
  # the image stays invisible until the pane loses focus. Force the repaint.
  [ -n "$TMUX" ] && tmux refresh-client
fi

#STARSHIP INI
eval "$(starship init zsh)"

#ZOXIDE INIT
function z () {
    __zoxide_z "$@"
}

eval "$(zoxide init --cmd cd zsh)"



function y() {
	tmp="$(mktemp -t "yazi-cwd.XXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Autoload zsh shell functions defined in the function path
fpath=( ~/.config/zsh/autoload "${fpath[@]}" )
autoload -Uz load_anthropic
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH=$PATH:$HOME/.maestro/bin
