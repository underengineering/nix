#!/usr/bin/env zsh

set -e

BLUE='\033[0;34m'
RESET='\033[0m'
SYMBOL="${BLUE}󰕹${RESET}"

TARGET=$1
case $TARGET in
    "system")
        HOST_NAME=$2
        ARGS="${@:3}"
        echo "$SYMBOL Building system configuration for host '$HOST_NAME' $SYMBOL"
        sudo nixos-rebuild switch --flake ".#$HOST_NAME" $ARGS
        ;;
    "user")
        ARGS="${@:2}"
        echo "$SYMBOL Building user configuration for user '$USER' $SYMBOL"
        nix build --impure ".#homeManagerConfigurations.$USER.activationPackage" $ARGS
        ./result/activate
        ;;
    *)
        echo 'Usage: build.sh (system/user) [host name]'
        ;;
esac
