FROM alpine:edge AS base
RUN apk add neovim ncurses bash

# Copy terminfo
COPY ./wezterm.terminfo /tmp/wezterm.terminfo
RUN tic -s /tmp/wezterm.terminfo

# Config deps
RUN apk add curl git build-base fd nodejs ruff ruff-lsp black \
    -X http://dl-cdn.alpinelinux.org/alpine/edge/testing

ENV XDG_CONFIG_DIRS="/root/.config"
ENV XDG_DATA_DIRS="/root/.local/share"
ENV USER="root"
ENV PNPM_HOME="${XDG_DATA_DIRS}/pnpm"
ENV PATH="${PATH}:${PNPM_HOME}"
RUN curl -L https://unpkg.com/@pnpm/self-installer | node
RUN pnpm i -g pyright typescript-language-server prettier \
    vscode-langservers-extracted svelte-language-server   \
    @tailwindcss/language-server

FROM base as build
COPY . /root/.config/nvim
RUN nvim --headless -c 'Lazy install | q!'

