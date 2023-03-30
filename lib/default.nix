{ inputs, nixpkgs, pkgs, home-manager, hyprland, system, lib, overlays, ... }:
rec {
  user = import ./user.nix { inherit nixpkgs pkgs home-manager hyprland lib system overlays; };
  host = import ./host.nix { inherit inputs user lib system pkgs; };
}
