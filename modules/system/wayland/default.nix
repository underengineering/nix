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
