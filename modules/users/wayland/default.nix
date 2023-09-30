{inputs}: {
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.wayland;
in {
  options.jd.wayland = {
    enable = mkOption {
      description = "Enable wayland";
      type = types.bool;
      default = false;
    };
  };
  config = mkIf (cfg.enable) {
    services.syncthing.enable = true;
    systemd.user.services.syncthing.Install.WantedBy = mkForce [];
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
    # TODO: Mount /tmp as zram
    home.file.Downloads.source = config.lib.file.mkOutOfStoreSymlink "/tmp/Downloads";
    home.packages = with pkgs; [
      looking-glass-client
      qbittorrent
      rofi-wayland
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
