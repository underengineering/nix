{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.packages;
in {
  config = {
    programs.zsh.enable = true;
    programs.wireshark.enable = true;
    programs.dconf.enable = true;

    virtualisation.libvirtd.enable = true;
    systemd.services.libvirtd.wantedBy = mkForce [];

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };

    environment.systemPackages = with pkgs; [
      virtiofsd

      # Text editors
      vim

      # Utils
      nmap
      fzf
      linuxKernel.packages.linux_6_6.cpupower
      podman-compose
    ];
  };
}
