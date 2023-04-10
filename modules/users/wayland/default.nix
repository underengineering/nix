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
    services.syncthing.enable = true;
    programs.mpv = {
      enable = true;
      config = {
        sub-auto = "fuzzy";
        sub-font = "Noto Sans";
        sub-bold = true;

        profile = "gpu-hq";
        hwdec = "auto";
        video-sync = "display-resample";
        interpolation = true;
        tscale = "oversample";

        save-position-on-quit = true;
      };
    };
    home.packages = with pkgs; [
      rofi-wayland
      firefox-bin
      krita

      wl-clipboard
      xdg-utils
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
  imports = [
    ./applications
    ./fonts
    ./themes
  ];
}
