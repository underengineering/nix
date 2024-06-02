{
  pkgs,
  lib,
}: let
  inherit (pkgs) stdenv;
in {
  overlay = final: prev: (builtins.foldl' (acc: elem: acc // elem) {} [
    (import ./fzf-runner {inherit pkgs stdenv lib;})
  ]);
}
