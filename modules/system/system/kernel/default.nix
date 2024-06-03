{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.modules.system.kernel;
in {
  options.modules.system.kernel = {
    patches = mkOption {
      description = "Kernel patches";
      type = with types; listOf (attrsOf (either str path));
      default = [];
    };
  };
  config = {
    boot.kernelPatches = cfg.patches;
  };
}
