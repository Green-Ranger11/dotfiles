# Modular zsh config - all settings live in conf.d/, sourced in numeric order:
#   00-env.zsh                 XDG dirs, env vars, platform-specific, history
#   10-path.zsh                PATH additions
#   20-tools.zsh               editors, browser, nvm, gpg
#   30-completion-plugins.zsh  compinit, antigen plugins, mcfly
#   40-aliases.zsh             aliases (+ untracked work.zsh)
#   90-startup.zsh             tmux autostart, fastfetch, starship, zoxide, functions

for conf in "${ZDOTDIR:-$HOME/.config/zsh}"/conf.d/*.zsh; do
  source "$conf"
done
unset conf
