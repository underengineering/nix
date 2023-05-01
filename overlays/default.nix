{ inputs, pkgs, lib, ... }:
with lib;
{
  overlays = [
    inputs.neovim-nightly-overlay.overlay
    inputs.hyprland.overlays.default
    inputs.hyprpaper.overlays.default
    (final: prev: {
      hyprland-lto = inputs.hyprland.packages.${pkgs.system}.default.overrideAttrs (old: {
        NIX_CFLAGS_COMPILE = toString (old.NIX_CFLAGS_COMPILE or "") + " -pipe -march=native -O3 -fipa-pta";
        NIX_CXXFLAGS_COMPILE = toString (old.NIX_CXXFLAGS_COMPILE or "") + " -pipe -march=native -O3 -fipa-pta";
        NIX_LDFLAGS = toString (old.NIX_LDFLAGS or "") + " -flto=15";
      });

      # https://wiki.hyprland.org/Nix/XDG-Desktop-Portal-Hyprland/
      xdg-desktop-portal-hyprland = inputs.xdph.packages.${prev.system}.default.override {
        hyprland-share-picker = inputs.xdph.packages.${prev.system}.hyprland-share-picker.override { inherit hyprland-lto; };
      };

      # Cursor names must be without spaces to be parsed correctly
      capitaine-cursors-themed = prev.capitaine-cursors-themed.overrideAttrs ({ preInstall ? "", ... }: {
        preInstall = preInstall + ''
          for src in *; do
            dst=$(echo "$src" | tr " " "-")
            mv "./$src" "$dst"
          done
        '';
      });
    })
  ];
}
