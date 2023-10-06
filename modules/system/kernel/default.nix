{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.kernel;
in {
  options.jd.kernel = {
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
