{ inputs, pkgs, lib, ... }:
with lib;
{
  overlays = [
    inputs.neovim-nightly-overlay.overlay
    inputs.hyprland.overlays.default
    inputs.hyprpaper.overlays.default
    (final: prev: {
      hyprland-lto = prev.pkgs.hyprland.overrideAttrs (old: {
        NIX_CFLAGS_COMPILE = toString (old.NIX_CFLAGS_COMPILE or "") + " -pipe -march=native -O3 -fipa-pta";
        NIX_CXXFLAGS_COMPILE = toString (old.NIX_CXXFLAGS_COMPILE or "") + " -pipe -march=native -O3 -fipa-pta";
        NIX_LDFLAGS = toString (old.NIX_LDFLAGS or "") + " -flto=15";
      });
    })
  ];
}
