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
    ./wezterm
    (import ./crabshell {inherit inputs;})
    ./hyprpaper
    ./vscodium
    (import ./firefox {inherit inputs;})
  ];
}
