{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.jd.packages;
in
{
  config = {
    programs.zsh.enable = true;
    programs.wireshark.enable = true;
    programs.dconf.enable = true;

    virtualisation.libvirtd.enable = true;
    systemd.services.libvirtd.enable = false;

    environment.systemPackages = with pkgs; [
      # Coreutils replacements
      exa
      delta
      du-dust
      duf
      ripgrep
      btop

      # Text editors
      vim
      neovim-nightly

      # Utils
      nmap
      fzf
      unzip
      zstd
      p7zip
      config.boot.kernelPackages.cpupower
    ];
  };
}
