{ pkgs, config, lib, ... }:
{
  imports = [
    ./git
    ./hyprland
    ./wayland
    ./applications
    ./fonts
    ./dunst
    ./themes
  ];
}
