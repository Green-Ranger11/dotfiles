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
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export XCURSOR_PATH=/usr/share/icons:"$XDG_DATA_HOME"/icons
export MCFLY_KEY_SCHEME=vim
export MCFLY_HISTFILE="$XDG_STATE_HOME"/zsh/history
export ZDOTDIR="$XDG_CONFIG_HOME"/zsh
export ADOTDIR="$XDG_DATA_HOME/antigen"
export TERM="xterm-256color"
export GOPATH="$XDG_DATA_HOME"/go

#PLATFORM-SPECIFIC ENV VARIABLES
if [[ "$OSTYPE" == "darwin"* ]]; then
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    export JAVA_HOME="/usr/local/opt/openjdk@17"
    export PATH="$JAVA_HOME/bin:$PATH"
    export CAPACITOR_ANDROID_STUDIO_PATH="/Applications/Android Studio.app/Contents"
else
    export ANDROID_HOME="${HOME}/Android/Sdk"
    export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
    export PATH="$JAVA_HOME/bin:$PATH"
    export CAPACITOR_ANDROID_STUDIO_PATH="/usr/bin/android-studio"
fi

#ZSH HISTORY
export HISTSIZE=1000
export SAVEHIST=1000
export HISTFILE="$XDG_STATE_HOME"/zsh/history
