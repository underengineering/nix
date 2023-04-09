{ pkgs, config, lib, ... }:
{
  imports = [
    ./dunst
    ./hyprland
    ./kitty
    ./swaylock
  ];
}
