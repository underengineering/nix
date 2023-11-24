source ~/.bashrc

if command -v ip &> /dev/null
then
    alias ip='ip -c'
fi

alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -la --color=auto'
alias diff='diff --color=auto'
alias grep='grep --color=auto'

PLUGIN_PATH=/tmp/.bash
mkdir -p "$PLUGIN_PATH" &> /dev/null

# function cleanup() {
#     rm -r "$PLUGIN_PATH"
# }
#
# trap cleanup EXIT

if [ ! -d "$PLUGIN_PATH/ble.sh" ]
then
    echo "Installing ble.sh"
    mkdir -p "$PLUGIN_PATH/ble.sh" &> /dev/null
    curl -L https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar xJf - -C "$PLUGIN_PATH/ble.sh"
fi

source "$PLUGIN_PATH/ble.sh/ble-nightly/ble.sh"

ble-face -s auto_complete             fg=gray

ble-face -s filename_directory        underline,fg=purple
ble-face -s syntax_error              fg=white,bg=red
