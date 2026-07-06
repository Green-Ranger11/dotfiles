#SET DEFAULT EDITORS
export EDITOR=nvim
export VISUAL=nvim
# Set default browser (cross-platform)
if [[ -x "/Applications/Firefox.app/Contents/MacOS/firefox" ]]; then
    export BROWSER='/Applications/Firefox.app/Contents/MacOS/firefox'
elif [[ -x "/usr/bin/firefox" ]]; then
    export BROWSER='/usr/bin/firefox'
fi
export KITTY_LISTEN_ON=unix:/tmp/kitty
gradle() { JAVA_TOOL_OPTIONS="-Xmx512m" command gradle "$@"; }

#NVM
if [[ "$OSTYPE" == "darwin"* ]]; then
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    source /usr/share/nvm/init-nvm.sh
fi
#SIGN COMMITS
export GPG_TTY=$(tty)
