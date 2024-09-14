
export -U PATH=$HOME/.cargo/bin:$PATH
export -U PATH=$HOME/.local/bin:$PATH

export WORDCHARS=${WORDCHARS/\/}

####[ OPTIONS ]####
setopt autocd autopushd pushdignoredups
zstyle ':completion:*' menu select

# Disable stupid bell when hitting tab
unsetopt beep

# History
HISTFILE=~/.zsh_history
HISTSIZE=8192
SAVEHIST=8192
setopt no_share_history hist_ignore_dups inc_append_history
unsetopt share_history
####[ END OPTIONS ]####

####[ KEYBINDS ]####
bindkey -e '^A' vi-beginning-of-line
bindkey -e '^E' vi-end-of-line
bindkey -e '^[[1;5C' forward-word
bindkey -e '^[[1;5D' backward-word
####[ END KEYBINDS ]####

# Disable microsoft spyware
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Disable minimizing when unfocused
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

####[ ALIASES ]####
if command -v eza &> /dev/null
then
    alias ls='eza'
    alias ll='eza -lh'
    alias la='eza -lah'
else
    alias ls='ls --color=auto'
    alias ll='ls -lh --color=auto'
    alias la='ls -la --color=auto'
fi

if command -v ip &> /dev/null
then
    alias ip='ip -c'
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
    # if [ -z "$KITTY_PID" ]; then
    local control_master="ssh-%C"
    # else
    #     local control_master="kssh-$KITTY_PID-%C"
    # fi

    local control_master_path="$runtime_dir/$control_master"

    \ssh -C \
        -o ControlMaster=auto                   \
        -o ControlPath="${control_master_path}" \
        -o ControlPersist=yes                   \
        -o ServerAliveInterval=60               \
        -o ServerAliveCountMax=5                \
        "$@"
}

# FIXME: FileNotFoundError: [Errno 2] No such file or directory: 'kssh-575523-5DZ6FM5DOE6XO'

# if [ -z "$KITTY_PID" ]
# then
#     alias ssh=_ssh_wrapper
# else
#     alias ssh='kitten ssh'
# fi
alias ssh=_ssh_wrapper

# Use control master for rsync's ssh
alias rsync='rsync -e ssh-session'

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

alias gitl="git log --graph --pretty=format:'%C(yellow)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=short"
alias gitc='git commit -m'
alias gita='git add'
alias gitall='git add -A'
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

####[ END PLUGINS ]####

if [[ -z "$TMUX" && "$-" == *i* ]]; then
    tmux attach -t default || tmux new -s default && exit
elif [[ "$-" == *i* ]]; then
    # https://babushk.in/posts/renew-environment-tmux.html
    function tmux-refresh {
        export $(tmux show-environment | rg "^(KITTY_PID|KITTY_WINDOW_ID)")
    }

    # Start all plugins
    source ~/.zsh/fzf-tab/fzf-tab.zsh
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
    source ~/.zsh/zsh-fzf-history-search/zsh-fzf-history-search.zsh
    source ~/.zsh/zsh-tab-title/zsh-tab-title.plugin.zsh

    # Start direnv
    eval "$(direnv hook zsh)"

    # Start starship
    eval "$(starship init zsh)"
fi

