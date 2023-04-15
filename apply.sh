#!/usr/bin/env sh

set -e

TARGET=$1
case $TARGET in
    "system")
        HOST_NAME=$2
        ARGS="${@:3}"
        echo "Building system configuration for host '$HOST_NAME'"
        sudo nixos-rebuild switch --flake ".#$HOST_NAME" $ARGS
        ;;
    "user")
        ARGS="${@:2}"
        echo "Building user configuration for user '$USER'"
        nix build --impure ".#homeManagerConfigurations.$USER.activationPackage" $ARGS
        ./result/activate
        ;;
    *)
        echo 'Usage: build.sh (system/user) [host name]'
        ;;
esac
