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
    (import ./crabshell {inherit inputs;})
    ./hyprpaper
    ./vscodium
    (import ./firefox {inherit inputs;})
  ];
}
