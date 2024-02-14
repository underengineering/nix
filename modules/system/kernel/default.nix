{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.kernel;
in {
  options.modules.kernel = {
    patches = mkOption {
      description = "Kernel patches";
      type = with types; listOf attrs;
      default = [];
    };
  };
  config = {
    boot.kernelPatches = cfg.patches;
  };
}
