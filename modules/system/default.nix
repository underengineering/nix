{ pkgs, config, lib, ... }:
{
  imports = [
    ./boot
    ./kernel
    ./ssh
    ./packages
    ./greetd
    ./unbound
  ];
}
