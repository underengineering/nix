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
    (import ./crabshell {inherit inputs;})
    ./hyprpaper
    ./vscodium
    (import ./firefox {inherit inputs;})
  ];
}
