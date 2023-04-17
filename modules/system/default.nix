{ pkgs, config, lib, ... }:
{
  imports = [
    ./boot
    ./kernel
    ./ssh
    ./packages
    ./unbound
    ./wayland
    ./pipewire
    ./zram
    ./bluetooth
    ./tlp
    ./chrony
    ./flatpak
  ];
}
