{inputs}: {
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.wayland;
in {
  options.modules.wayland = {
    enable = mkOption {
      description = "Enable wayland";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    programs.mpv = {
      enable = true;
      config = {
        osd-font = "Lexend";

        sub-auto = "fuzzy";
        sub-bold = true;
        sub-font = "Noto Sans";

        hwdec = "auto";
        interpolation = true;
        profile = "gpu-hq";
        tscale = "oversample";
        video-sync = "display-resample";

        save-position-on-quit = true;
      };
    };

    # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
    systemd.user.tmpfiles.rules = ["d /tmp/Downloads 0700 - - - -"];
    home.file.Downloads.source = config.lib.file.mkOutOfStoreSymlink "/tmp/Downloads";

    home.packages = with pkgs; [
      looking-glass-client
      qbittorrent-qt5
      ungoogled-chromium
      virt-manager
      wireshark

      grim
      slurp
      swappy
      swaylock-effects
      wf-recorder
      wl-clipboard
      xdg-utils

      (pkgs.buildEnv {
        name = "custom-scripts";
        paths = [
          ../../../scripts
        ];
      })
    ];
  };
  imports = [
    (import ./applications {inherit inputs;})
    ./fonts
    ./themes
  ];
}
