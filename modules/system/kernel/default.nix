{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.jd.kernel;
in {
  options.jd.kernel = {
    enablePatches = mkOption {
      description = "Whether to enable custom .config patches";
      type = types.bool;
      default = false;
    };
    cpuVendor = mkOption {
      description = "CPU vendor to optimize for";
      type = types.enum ["intel" "amd"];
    };
    disableMitigations = mkOption {
      description = "Whether to disable exploit mitigations";
      type = types.bool;
      default = true;
    };
    reducedDebugInfo = mkOption {
      description = "Reduces debugging information";
      type = types.bool;
      default = true;
    };
    disableSecurity = mkOption {
      description = "Disables security module support";
      type = types.bool;
      default = true;
    };
    patches = mkOption {
      description = "Kernel patches";
      type = with types; listOf attrs;
      default = [];
    };
  };
  config = mkIf (cfg.enablePatches) {
    boot.kernelPatches =
      [
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
            STACKPROTECTOR_STRONG = kernel.no;
          };
        })
        (mkIf (cfg.reducedDebugInfo) {
          name = "Reduce debugging information";
          patch = null;
          extraStructuredConfig = {
            DEBUG_INFO_REDUCED = mkForce kernel.yes;
          };
        })
        (mkIf (cfg.disableSecurity) {
          name = "Disable SELinux";
          patch = null;
          extraStructuredConfig = with kernel; {
            # SECURITY = no;
            SECURITY_APPARMOR = mkForce no;
            SECURITY_SELINUX = mkForce no;
            SECURITY_LANDLOCK = mkForce no;
            SECURITY_LOCKDOWN_LSM = mkForce no;
            DEFAULT_SECURITY_APPARMOR = mkForce (option no);
          };
        })
      ]
      ++ cfg.patches;
  };
}
