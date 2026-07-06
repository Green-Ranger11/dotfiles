#ALIASES
#XDG SPECIFICATION ALIASES
alias yarn='yarn --use-yarnrc "$XDG_CONFIG_HOME/yarn/config"'
alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'

#SOURCING ZSH
alias srczsh='source ~/.config/zsh/.zshrc'

#APPLICATIONS
alias vim='nvim'

#LISTING FILES
alias ll='ls -1'
alias la='ls -1a'
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias lla='ls -lGA'
else
    alias lla='ls -lG --color --group-directories-first -A -v'
fi
alias ..='cd ..'

#CONFIGS
alias dotzsh='nvim ~/.config/zsh/.zshrc'
alias dotgit='nvim ~/.config/git/config'
alias dotkitty='nvim ~/.config/kitty/kitty.conf'

if [[ "$OSTYPE" == "darwin"* ]]; then
    alias dotyabai='nvim ~/.config/yabai/yabairc'
    alias dotskhd='nvim ~/.config/skhd/skhdrc'
    alias dotbar='nvim ~/.config/sketchybar/'
else
    alias doti3='nvim ~/.config/i3/config'
    alias dothy='nvim ~/.config/hypr/'
    alias nvidia-settings='nvidia-settings --config="$XDG_CONFIG_HOME"/nvidia/settings'
    alias ntc="nmtui-connect"
    alias b="sudo bandwhich"
    alias vpnvoda='sudo openfortivpn -c ~/.config/openfortivpn/vodafone --pppd-accept-remote'
fi

# Work aliases (SSH/SFTP hosts) - kept out of the public repo
[ -f "$XDG_CONFIG_HOME/zsh/work.zsh" ] && source "$XDG_CONFIG_HOME/zsh/work.zsh"

# GIT BARE REPO
alias config="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias conf="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# GIT SPECIFIC
alias gitbc="git branch | grep -v 'main' | xargs git branch -D"

alias kc="kubectl"
