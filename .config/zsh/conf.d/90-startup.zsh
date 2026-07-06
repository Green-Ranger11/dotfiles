if [ -z "$TMUX" ] && [ -z "$NOAUTOATTACH" ]
then
    tmux attach -t TMUX || tmux new -s TMUX
fi

#FASTFETCH
if command -v fastfetch &> /dev/null; then
  fastfetch
fi

#STARSHIP INI
eval "$(starship init zsh)"

#ZOXIDE INIT
function z () {
    __zoxide_z "$@"
}

eval "$(zoxide init --cmd cd zsh)"

# eval "$(bw completion --shell zsh); compdef _bw bw;"


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
