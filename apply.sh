#!/usr/bin/env sh

set -e

TARGET=$1
HOST_NAME=$2
case $TARGET in
    "system")
        echo "Building system configuration for host '$HOST_NAME'"
        sudo nixos-rebuild switch --flake ".#$HOST_NAME"
        ;;
    "user")
        echo "Building user configuration for user '$USER'"
        nix build --impure ".#homeManagerConfigurations.$USER.activationPackage"
        ./result/activate
        ;;
    *)
        echo 'Usage: build.sh (system/user) [host name]'
        ;;
esac
