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

