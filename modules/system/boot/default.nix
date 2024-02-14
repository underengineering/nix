{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.boot;
in {
  options.modules.boot = {};

  config = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
      options = ["noatime" "nodiratime"];
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = ["noatime" "nodiratime"];
    };
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
      };
    };
  };
}
