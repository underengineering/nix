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
    services.dbus.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = [
        inputs.xdph.packages.x86_64-linux.default
      ];
    };
    programs.light.enable = true;
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
}
