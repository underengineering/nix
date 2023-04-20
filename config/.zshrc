
export -U PATH=$HOME/.cargo/bin:$PATH
export -U PATH=$HOME/.local/bin:$PATH

export WORDCHARS=${WORDCHARS/\/}

####[ OPTIONS ]####
autoload -U compinit && compinit

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

# Kitty blur (KDE/X11)
# if [[ $(ps --no-header -p $PPID -o comm) =~ '^yakuake|kitty$' ]]; then
#     for wid in $(xdotool search --pid $PPID); do
#         xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id $wid; done
# fi

####[ ALIASES ]####
local expected_aliases=('doas' 'exa' 'delta' 'dust' 'duf' 'rg' 'sshfs' 'progress')
local enabled_aliases=()

if command -v doas &> /dev/null
then
    alias sudo='doas'
    enabled_aliases+='doas'
fi

if command -v exa &> /dev/null
then
    alias ls='exa'
    alias ll='exa -lh'
    alias la='exa -lah'
    enabled_aliases+='exa'
else
    alias ls='ls --color=auto'
    alias ll='ls -lh --color=auto'
    alias la='ls -la --color=auto'
fi

if command -v delta &> /dev/null
then
    alias diff='delta'
    enabled_aliases+='delta'
else
    alias diff='diff --color=auto'
fi

if command -v dust &> /dev/null
then
    alias du='dust'
    enabled_aliases+='dust'
fi

if command -v duf &> /dev/null
then
    alias df='duf'
    enabled_aliases+='duf'
fi

if command -v rg &> /dev/null
then
    alias grep='rg'
    enabled_aliases+='rg'
else
    alias grep='grep --color=auto'
fi

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

if command -v progress &> /dev/null
then
    function track {
        if [ ! -t 1 ]
        then
            $1 "${@:2}"
            return $?
        fi

        setopt local_options localtraps no_notify no_monitor

        function on-interrupt {
            kill $watchdog 2>/dev/null
            kill $cmd 2>/dev/null
        }

        trap on-interrupt INT

        (sleep 1) &
        watchdog=$!

        ($1 "${@:2}"; ; kill $watchdog 2>/dev/null) &
        cmd=$!

        wait $watchdog

        while ps -p $cmd > /dev/null
        do
            pid=$(pgrep -P $cmd)
            progress -w -p $pid | sed -n 2p | sed 's/^[[:space:]]/\r/g'
        done
    }

    # alias cp='track cp'
    # alias mv='track mv'
    alias dd='track dd'
    alias tar='track tar'
    # alias cat='track cat'
    alias grep='track grep'
    alias sort='track sort'
    alias gzip='track gzip'
    alias gunzip='track gunzip'
    alias bzip2='track bzip2'
    alias bunzip2='track bunzip2'
    alias xz='track xz'
    alias unxz='track unxz'
    alias lzma='track lzma'
    alias unlzma='track unlzma'
    alias 7z='track 7z'
    alias 7za='track 7za'
    alias zcat='track zcat'
    alias bzcat='track bzcat'
    alias lzcat='track lzcat'

    enabled_aliases+='progress'
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

# alias vpnsh='sudo ip netns exec ${1:-protected} sudo -u $USER -i'
alias wine="WINEARCH=win64 WINEPREFIX=${HOME}/.wine /usr/bin/wine"

function rust-musl-builder {
    sudo docker run --rm -it \
        -v $(pwd):/volume    \
        -v cargo-cache:/root/.cargo/registry \
        clux/muslrust:nightly "$@"
}

# Health check
function health-check {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local RESET='\033[0m'

    function enabled {
        local found=1
        for enabled in $enabled_aliases; do
            if [[ $enabled = $1 ]]; then
                found=0
                break
            fi
        done

        return found
    }

    echo 'Aliases:'
    for expected in $expected_aliases; do
        if enabled $expected; then
            echo "${GREEN}[]$RESET $expected"
        else
            echo "${RED}[]$RESET $expected"
        fi
    done
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

