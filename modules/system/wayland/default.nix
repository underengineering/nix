{
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
    services.dbus = {
      enable = true;
      implementation = "broker";
    };
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      config = {
        common.default = ["gtk" "hyprland"];
      };
    };
    programs.light.enable = true;
    services.xserver.gdk-pixbuf.modulePackages = with pkgs; [librsvg];
    environment.systemPackages = with pkgs; [
      libva-utils
      vdpauinfo
      glxinfo
    ];
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
  imports = [
    ./greetd
  ];
}
