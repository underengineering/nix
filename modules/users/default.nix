{ pkgs, config, lib, ... }:
{
  imports = [
    ./git
    ./hyprland
    ./wayland
    ./applications
  ];
}
