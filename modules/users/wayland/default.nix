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
    # TODO: Mount /tmp as zram
    home.file.Downloads.source = config.lib.file.mkOutOfStoreSymlink "/tmp/Downloads";
    home.packages = with pkgs; [
      rofi-wayland
      wireshark
      qbittorrent
      virt-manager
      looking-glass-client

      wl-clipboard
      xdg-utils
      grim
      slurp
      swappy

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
