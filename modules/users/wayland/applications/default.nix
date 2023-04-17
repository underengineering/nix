{ inputs }:
{ pkgs, config, lib, ... }:
{
  imports = [
    ./dunst
    ./hyprland
    ./kitty
    ./swaylock
    ./wezterm
    (import ./eww { inherit inputs; })
  ];
}
