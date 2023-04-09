{ inputs }:
{ pkgs, config, lib, ... }:
{
  imports = [
    ./git
    ./hyprland
    (import ./wayland { inherit inputs; })
    ./applications
    ./fonts
    ./dunst
    ./themes
    ./swaylock
  ];
}
