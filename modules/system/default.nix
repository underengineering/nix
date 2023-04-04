{ pkgs, config, lib, ... }:
{
  imports = [
    ./boot
    ./kernel
    ./ssh
    ./packages
    ./greetd
    ./unbound
    ./wayland
    ./pipewire
    ./zram
    ./bluetooth
    ./tlp
    ./chrony
  ];
}
