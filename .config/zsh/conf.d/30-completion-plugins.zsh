#GIT STUFF
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

#ANTIGEN
if [[ "$OSTYPE" == "darwin"* ]]; then
    source "$HOME"/antigen.zsh
else
    source /usr/share/zsh/share/antigen.zsh
fi
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
