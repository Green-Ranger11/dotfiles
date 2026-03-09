#!/bin/bash
# Remote server quick setup: bash vi-mode + tmux config
# Usage: curl -fsSL https://gist.githubusercontent.com/Green-Ranger11/deef5e149337d1054e657014ab3b7003/raw/remote-setup.sh | bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }

# --- Backup helpers ---
backup() {
    if [ -f "$1" ]; then
        cp "$1" "$1.bak.$(date +%s)"
        warn "Backed up $1"
    fi
}

# =====================
# 1. Bash vi-mode setup
# =====================
BASH_MARKER="# >>> remote-setup >>>"

if ! grep -qF "$BASH_MARKER" ~/.bashrc 2>/dev/null; then
    backup ~/.bashrc

    cat >> ~/.bashrc << 'BASHEOF'

# >>> remote-setup >>>
set -o vi

# Cursor shape: beam for insert, block for normal
bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string \1\e[5 q\2'
bind 'set vi-cmd-mode-string \1\e[1 q\2'
# <<< remote-setup <<<
BASHEOF

    info "Bash vi-mode + cursor switching appended to ~/.bashrc"
else
    warn "Bash vi-mode block already present in ~/.bashrc — skipped"
fi

# =====================
# 2. Tmux config
# =====================
backup ~/.tmux.conf

cat > ~/.tmux.conf << 'TMUXEOF'
# Terminal
set-option -sa terminal-overrides ",xterm*:Tc"
set -g mouse on

# Prefix (keep default C-b to avoid conflicts with local tmux)
set -g prefix C-b
bind C-b send-prefix

# Window navigation
bind -n M-H previous-window
bind -n M-L next-window

# Pane navigation (prefix + hjkl)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Indexing
set -g base-index 1
set -g pane-base-index 1
set-window-option -g pane-base-index 1
set-option -g renumber-windows on

# Vi copy mode
set-window-option -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

# Splits in current path
bind '"' split-window -v -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"

# Status bar
set-option -g status-position top
TMUXEOF

info "Wrote ~/.tmux.conf"

# =====================
# Summary
# =====================
echo ""
info "Done! Summary:"
echo "  ~/.bashrc  — vi-mode, cursor shape switching"
echo "  ~/.tmux.conf — C-b prefix, Alt+H/L windows, C-b+hjkl panes, mouse, vi copy"
echo ""
echo "  Run: source ~/.bashrc && tmux kill-server 2>/dev/null; tmux"
