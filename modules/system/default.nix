{ inputs }:
{ pkgs, config, lib, ... }:
{
  imports = [
    ./boot
    ./kernel
    ./ssh
    ./packages
    ./unbound
    (import ./wayland { inherit inputs; })
    ./pipewire
    ./zram
    ./bluetooth
    ./tlp
    ./chrony
    ./flatpak
  ];
}
