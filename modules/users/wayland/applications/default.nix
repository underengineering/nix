{inputs}: {
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    (import ./firefox {inherit inputs;})
    ./crabbar
    ./dunst
    ./hyprland
    ./hyprpaper
    ./kitty
    ./swaylock
    ./vscodium
  ];
}
