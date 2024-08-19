{
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
    services.dbus = {
      enable = true;
      implementation = "broker";
    };
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        # Hyprland module does this automatically
        # xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      config = {
        common.default = ["gtk" "hyprland"];
      };
    };

    programs.gdk-pixbuf.modulePackages = with pkgs; [librsvg];
    programs.light.enable = true;
    environment.systemPackages = with pkgs; [
      libva-utils
      vdpauinfo
      glxinfo
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
  imports = [
    ./applications
  ];
}
