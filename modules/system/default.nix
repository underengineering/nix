{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./bluetooth
    ./boot
    ./chrony
    ./flatpak
    ./fprintd
    ./kernel
    ./packages
    ./pam
    ./pipewire
    ./ssh
    ./tlp
    ./unbound
    ./wayland
    ./zram
  ];
}
