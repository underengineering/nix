{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce mkOption mkIf types;
  cfg = config.modules.applications;
in {
  options.modules.applications = {
    enable = mkOption {
      description = "Enable common applications";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.enable) {
    services.keyd.enable = true;
    programs.zsh.enable = true;
    programs.wireshark.enable = true;
    programs.dconf.enable = true;

    virtualisation.libvirtd.enable = true;

    # Prevent libvirtd from starting automatically
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
      config.boot.kernelPackages.cpupower
      fzf
      nmap
      podman-compose
    ];
  };
  imports = [
    ./bluetooth
    ./chrony
    ./flatpak
    ./greetd
    ./pipewire
    ./ssh
    ./tlp
    ./unbound
  ];
}
