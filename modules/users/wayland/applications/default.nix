{inputs}: {
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./dunst
    ./hyprland
    ./kitty
    ./swaylock
    ./hyprpaper
    ./vscodium
    (import ./firefox {inherit inputs;})
  ];
}
