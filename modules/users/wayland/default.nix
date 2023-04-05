{ inputs }:
{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.wayland;
in
{
  options.jd.wayland = {
    enable = mkOption {
      description = "Enable wayland";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      rofi-wayland
      kitty
      firefox-bin
      wireshark
      krita

      wl-clipboard
      grim
      slurp
      swappy
      inputs.eww.packages.${pkgs.hostPlatform.system}.eww-wayland

      (pkgs.buildEnv {
        name = "custom-scripts";
        paths = [
          ../../../scripts
        ];
      })
    ];
  };
}
