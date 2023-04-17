{ inputs, nixpkgs, pkgs, hyprland, home-manager, system, lib, overlays, ... }:
rec {
  utils = import ./utils.nix { inherit lib; };
  user = import ./user.nix { inherit inputs nixpkgs pkgs home-manager hyprland lib system overlays; };
  host = import ./host.nix { inherit inputs user lib utils system pkgs; };
}
