{
  pkgs,
  stdenv,
  lib,
}: {
  fzf-runner = pkgs.rustPlatform.buildRustPackage {
    pname = "fzf-runner";
    version = "1.0.0";

    src = ./.;
    cargoHash = "sha256-Y8fCV2u61val5gW/Ta4FctZetSDJTxKcZUDFFjNvvk0=";
  };
}
