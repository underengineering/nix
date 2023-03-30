{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.jd.kernel;
in
{
  options.jd.kernel = {
    enablePatches = mkOption {
      description = "Whether to enable custom .config patches";
      type = types.bool;
      default = false;
    };
    cpuVendor = mkOption {
      description = "CPU vendor to optimize for";
      type = types.enum [ "intel" "amd" ];
    };
    disableMitigations = mkOption {
      description = "Whether to disable performance-killing mitigations";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.enablePatches) {
    boot.kernelPatches = [
      {
        name = "CPU-specific optimizations";
        patch = null;
        extraStructuredConfig = mkMerge [
          (mkIf (cfg.cpuVendor == "intel") {
            MNATIVE_INTEL = kernel.yes;
          })
          (mkIf (cfg.cpuVendor == "amd") {
            MNATIVE_AMD = kernel.yes;
          })
        ];
      }
      (mkIf (cfg.disableMitigations) {
        name = "Disable mitigations";
        patch = null;
        extraStructuredConfig = {
          SPECULATION_MITIGATIONS = kernel.no;
        };
      })
    ];
  };
}
