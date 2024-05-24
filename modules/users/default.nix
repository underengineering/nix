{inputs}: {
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    (import ./wayland {inherit inputs;})
    ./applications
  ];
}
