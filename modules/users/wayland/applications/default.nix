{inputs}: {
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./dunst
    (import ./hyprland {inherit inputs;})
    ./kitty
    ./swaylock
    ./wezterm
    (import ./eww {inherit inputs;})
    ./hyprpaper
    ./vscodium
    (import ./firefox {inherit inputs;})
  ];
}
