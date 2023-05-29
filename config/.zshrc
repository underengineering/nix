
export -U PATH=$HOME/.cargo/bin:$PATH
export -U PATH=$HOME/.local/bin:$PATH

export WORDCHARS=${WORDCHARS/\/}

####[ OPTIONS ]####
setopt autocd autopushd pushdignoredups
zstyle ':completion:*' menu select

setopt no_share_history hist_ignore_dups
unsetopt share_history

# History
HISTFILE=~/.zsh_history
HISTSIZE=8192
SAVEHIST=8192
####[ END OPTIONS ]####

####[ KEYBINDS ]####
bindkey -e "^A" vi-beginning-of-line
bindkey -e "^E" vi-end-of-line
bindkey -e ";5C" forward-word
bindkey -e ";5D" backward-word
####[ END KEYBINDS ]####

# Disable microsoft spyware
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Disable minimizing when unfocused
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

####[ ALIASES ]####
if command -v exa &> /dev/null
then
    alias ls='exa'
    alias ll='exa -lh'
    alias la='exa -lah'
else
    alias ls='ls --color=auto'
    alias ll='ls -lh --color=auto'
    alias la='ls -la --color=auto'
fi

alias diff='diff --color=auto'
alias grep='grep --color=auto'

if command -v sshfs &> /dev/null
then
    function _sshfs_wrapper() {
        local runtime_dir="$XDG_RUNTIME_DIR"
        local control_master="ssh-%C"
        local control_master_path="$runtime_dir/$control_master"

        \sshfs -C -o reconnect,kernel_cache,auto_cache,cache=yes,auto_unmount \
            -o ControlMaster=auto                   \
            -o ControlPath="${control_master_path}" \
            -o ControlPersist=yes                   \
            -o ServerAliveInterval=60               \
            -o ServerAliveCountMax=5                \
            -o TCPKeepAlive=no                      \
            "$@"
    }

    alias sshfs=_sshfs_wrapper

    enabled_aliases+='sshfs'
fi

function _ssh_wrapper() {
    local runtime_dir="$XDG_RUNTIME_DIR"
    local control_master="ssh-%C"
    local control_master_path="$runtime_dir/$control_master"

    \ssh -C \
        -o ControlMaster=auto                   \
        -o ControlPath="${control_master_path}" \
        -o ControlPersist=yes                   \
        -o ServerAliveInterval=60               \
        -o ServerAliveCountMax=5                \
        "$@"
}

alias ssh=_ssh_wrapper

function wezterm-setup {
    local HOST=$1

    echo "Connecting to root@$HOST"
    local SCRIPT='
    set -e
    if [ -f /usr/bin/wezterm ]; then
        echo "Wezterm is already set up - reinstalling"
        rm /usr/bin/wezterm
    fi

    apt install fuse -y
    curl -Lo /usr/bin/wezterm https://github.com/wez/wezterm/releases/download/20230408-112425-69ae8472/WezTerm-20230408-112425-69ae8472-Ubuntu20.04.AppImage
    chmod +x /usr/bin/wezterm
    '

    local SCRIPT_BASE64=$(base64 <<< $SCRIPT)
    \ssh root@$1 "base64 -d <<< '$SCRIPT_BASE64' | bash"
}

# alias vpnsh='sudo ip netns exec ${1:-protected} sudo -u $USER -i'
alias wine="WINEARCH=win64 WINEPREFIX=${HOME}/.wine /usr/bin/wine"

function rust-musl-builder {
    sudo docker run --rm -it \
        -v $(pwd):/volume    \
        -v cargo-cache:/root/.cargo/registry \
        clux/muslrust:nightly "$@"
}

function .. {
    local d=..
    repeat ${1-1} [[ -d ${d::=$d/..} ]] || break
    cd ${d%/..}
}

function nvim-remote-upload {
    local HOST=$1
    local LOCAL_IMAGE_PATH='/tmp/.nvim-image.tar.zst'
    local REMOTE_IMAGE_PATH='/root/.nvim-image.tar.zst'

    echo "Generating image archive..."
    \podman image save nvim --uncompressed | zstd > $LOCAL_IMAGE_PATH

    echo "Uploading image to: $HOST"
    \rsync -aP $LOCAL_IMAGE_PATH root@$HOST:$REMOTE_IMAGE_PATH

    rm $LOCAL_IMAGE_PATH

    echo "Loading image"
    \ssh root@$HOST "unzstd < $REMOTE_IMAGE_PATH | docker image load && rm $REMOTE_IMAGE_PATH"
}

function nvim-remote {
    local HOST=$1
    \ssh -Ct root@$HOST "docker run -it --rm --name nvim-remote -v /:/mnt -e TERM=$TERM localhost/nvim nvim"
}

alias nix-shell="\\nix-shell --command $SHELL"
####[ END ALIASES ]####

####[ PLUGINS ]####
# Settings
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_FZF_HISTORY_SEARCH_FZF_EXTRA_ARGS='+e'

# Clone if doesn't exist
if [ ! -d "$HOME/.zsh/fzf-tab" ]
then
    echo "Installing fzf-tab"
    git clone --depth 1 https://github.com/Aloxaf/fzf-tab ~/.zsh/fzf-tab
fi

if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]
then
    echo "Installing zsh-autosuggestions"
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

if [ ! -d "$HOME/.zsh/fast-syntax-highlighting" ]
then
    echo "Installing fast-syntax-highlighting"
    git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting ~/.zsh/fast-syntax-highlighting
fi

if [ ! -d "$HOME/.zsh/zsh-fzf-history-search" ]
then
    echo "Installing zsh-fzf-history-search"
    git clone --depth 1 https://github.com/joshskidmore/zsh-fzf-history-search ~/.zsh/zsh-fzf-history-search
fi

if [ ! -d "$HOME/.zsh/zsh-tab-title" ]
then
    echo "Installing zsh-tab-title"
    git clone --depth 1 https://github.com/trystan2k/zsh-tab-title ~/.zsh/zsh-tab-title
fi

source ~/.zsh/fzf-tab/fzf-tab.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source ~/.zsh/zsh-fzf-history-search/zsh-fzf-history-search.zsh
source ~/.zsh/zsh-tab-title/zsh-tab-title.plugin.zsh

####[ END PLUGINS ]####

# Start starship
eval "$(starship init zsh)"

