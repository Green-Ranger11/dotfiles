#XDG SPECIFICATION ENVIRONMENT VARIABLES
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

#ENV VARIABLES FOR CUSTOM XDG COMPLIANCE
export WINEPREFIX="$XDG_DATA_HOME"/wineprefixes/default
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME"/bundle                                                               
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME"/bundle                                                                 
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME"/bundle
export NVM_DIR="$XDG_DATA_HOME"/nvm
export KDEHOME="$XDG_CONFIG_HOME"/kde
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc
export VIMINIT="set nocp | source ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.lua"
export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/pythonrc
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export KDEHOME="$XDG_CONFIG_HOME"/kde
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages
export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/pythonrc
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc":"$XDG_CONFIG_HOME/gtk-2.0/gtkrc.mine"
export ANDROID_HOME=${HOME}/Android/Sdk
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
export MCFLY_KEY_SCHEME=vim
export MCFLY_HISTFILE="$XDG_STATE_HOME"/zsh/history
export ZDOTDIR="$XDG_CONFIG_DIR"/zsh
export ADOTDIR="$XDG_DATA_HOME/antigen"
export TERM="xterm-256color"
export GOPATH="$XDG_DATA_HOME"/go
export CAPACITOR_ANDROID_STUDIO_PATH="/usr/bin/android-studio"

#ZSH HISTORY
export HISTSIZE=1000
export SAVEHIST=1000
export HISTFILE="$XDG_STATE_HOME"/zsh/history

#PATHS:
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin/
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator/
export PATH=$HOME/.config/rofi/scripts:$PATH
export PATH="$PATH:`pwd`/flutter/bin"
export PATH=$PATH:/home/alesana/.local/bin
export PATH=$PATH:/home/alesana/.local/share/npm/bin
export PATH=$PATH:/root/.local/bin
# export JAVA_HOME=/opt/android-studio/jbr
# export PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH

#SET DEFAULT EDITORS
export EDITOR=nvim
export VISUAL=nvim
export BROWSER='/usr/bin/firefox'
export KITTY_LISTEN_ON=unix:/tmp/kitty
export JAVA_TOOL_OPTIONS="-Xmx512m"

#NVM
source /usr/share/nvm/init-nvm.sh

#SIGN COMMITS
export GPG_TTY=$(tty)

#GIT STUFF
autoload -Uz compinit && compinit
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

#ANTIGEN
source /usr/share/zsh/share/antigen.zsh
#PLUGINS
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zdharma-continuum/fast-syntax-highlighting
antigen bundle jeffreytse/zsh-vi-mode
antigen apply

zvm_after_init_commands+=(eval "$(mcfly init zsh)")
function mcfly_override() {
  mcfly search
}

function zvm_after_init() {
  zvm_define_widget mcfly_override 
  zvm_bindkey viins '^R' mcfly_override 
}

#ALIASES
#XDG SPECIFICATION ALIASES
alias nvidia-settings=nvidia-settings --config="$XDG_CONFIG_HOME"/nvidia/settings
alias yarn='yarn --use-yarnrc "$XDG_CONFIG_HOME/yarn/config"'

#SOURCING ZSH
alias srczsh='source ~/.config/zsh/.zshrc'

#APPLICATIONS
alias vim='nvim'

#LISTING FILES
alias ll='ls -1'
alias la='ls -1a'
alias lla='ls -lG --color --group-directories-first -A -v'
alias ..='cd ..'

#CONFIGS
alias dotzsh='nvim ~/.config/zsh/.zshrc'
alias doti3='nvim ~/.config/i3/config'
alias dothy='nvim ~/.config/hypr/'
alias dotgit='nvim ~/.config/git/config'
alias dotkitty='nvim ~/.config/kitty/kitty.conf'

#SSH WEB SERVERS
# removed
# removed
# removed
# removed
# removed
# removed
# removed
# removed
# removed

#SFTP WEB SERVERS
# removed
# removed
# removed
# removed
# removed
# removed
# removed
# removed

#VPN
alias vpnvoda='sudo openfortivpn -c ~/.config/openfortivpn/vodafone --pppd-accept-remote'

# GIT BARE REPO
alias config='/usr/bin/git --git-dir=/home/alesana/.dotfiles/ --work-tree=/home/alesana'
alias conf='/usr/bin/git --git-dir=/home/alesana/.dotfiles/ --work-tree=/home/alesana'

# GIT SPECIFIC
alias gitbc="git branch | grep -v "main" | xargs git branch -D"

alias ntc="nmtui-connect"
alias b="sudo bandwhich"
alias kc="kubectl"

if [ -z "$TMUX" ]
then
    tmux attach -t TMUX || tmux new -s TMUX
fi

#FASTFETCH
if [[ -f  /usr/bin/fastfetch ]]; then 
  fastfetch; 
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
