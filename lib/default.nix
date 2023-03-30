{ inputs, nixpkgs, pkgs, home-manager, hyprland, system, lib, overlays, ... }:
rec {
  utils = import ./utils.nix { inherit lib; };
  user = import ./user.nix { inherit nixpkgs pkgs home-manager hyprland lib system overlays; };
  host = import ./host.nix { inherit inputs user lib utils system pkgs; };
}
