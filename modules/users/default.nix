{ inputs }:
{ pkgs, config, lib, ... }:
{
  imports = [
    ./git
    (import ./wayland { inherit inputs; })
    ./applications
  ];
}
