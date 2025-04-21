{
  inputs,
  pkgs,
  lib,
  ...
}: {
  overlays = [
    inputs.fzf-runner.overlays.default
    inputs.crabbar.overlays.default
    inputs.neovim-nightly-overlay.overlays.default
    (final: prev: {
      hyprland = inputs.hyprland.packages.${pkgs.system}.default;
      hyprpaper = inputs.hyprpaper.packages.${pkgs.system}.default;
      xdg-desktop-portal-hyprland = inputs.xdph.packages.${pkgs.system}.default;

      # ????????????????????????????????????????????
      # https://github.com/nix-community/neovim-nightly-overlay/blob/4be99133c03920579de8c3fe7c05ff1de60a7fbe/flake/packages/neovim.nix#L91C7-L91C21
      # ERROR: pattern @NVIM_VERSION_PRERELEASE@ doesn't match anything in file 'cmake.config/versiondef.h.in'
      neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (old: {
        preConfigure = ''
          ${(builtins.replaceStrings ["substituteInPlace"] ["echo"]
            old.preConfigure)}
        '';
      });

      qt6Packages = prev.qt6Packages.overrideScope (_: kprev: {
        qt6gtk2 = kprev.qt6gtk2.overrideAttrs (_: {
          version = "0.5-unstable-2025-03-04";
          src = final.fetchFromGitLab {
            domain = "opencode.net";
            owner = "trialuser";
            repo = "qt6gtk2";
            rev = "d7c14bec2c7a3d2a37cde60ec059fc0ed4efee67";
            hash = "sha256-6xD0lBiGWC3PXFyM2JW16/sDwicw4kWSCnjnNwUT4PI=";
          };
        });
      });

      tmux = prev.tmux.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "tmux";
          repo = "tmux";
          rev = "f0a85d04695bcdc84d6dfbf5f9d3f9757a148365";
          hash = "sha256-rzZwWD1GgYv7vb4SLMp7nk8+Xtz0gw0g1MgigMaGUqY=";
        };
      });

      # Cursor names must be without spaces to be parsed correctly
      capitaine-cursors-themed = prev.capitaine-cursors-themed.overrideAttrs ({preInstall ? "", ...}: {
        preInstall =
          preInstall
          + ''
            for src in *; do
              dst=$(echo "$src" | tr " " "-")
              mv "./$src" "$dst"
            done
          '';
      });

      orchis-theme-gruvbox = prev.orchis-theme.overrideAttrs (old: {
        tweaks = ["black" "primary"];
        patches = [../patches/nixpkgs/orchis-theme.patch];
      });

      linux_custom_lenowo =
        pkgs.linuxPackagesFor
        ((pkgs.linux_latest.override {
            stdenv = pkgs.fastStdenv;
            structuredExtraConfig = with lib;
            with lib.kernel; {
              # Google's BBRv3 TCP congestion Control
              TCP_CONG_BBR = yes;
              DEFAULT_BBR = yes;

              # WineSync driver for fast kernel-backed Wine
              WINESYNC = module;

              # Preemptive Full Tickless Kernel at 1000Hz
              HZ = freeform "1000";
              HZ_250 = no;
              HZ_1000 = yes;

              # Lazy preemption
              PREEMPT_DYNAMIC = no;
              PREEMPT_VOLUNTARY = mkForce no;
              PREEMPT_LAZY = yes;

              # Disable AMDGPU CIK support
              CONFIG_DRM_AMDGPU_CIK = no;

              # Disable radeon drivers
              CONFIG_DRM_RADEON = no;
              CONFIG_FB_RADEON = no;
              CONFIG_FB_RADEON_I2C = no;
              CONFIG_FB_RADEON_BACKLIGHT = no;

              # Disable ngreedia drivers
              CONFIG_NET_VENDOR_NVIDIA = no;
              CONFIG_I2C_NVIDIA_GPU = no;
              CONFIG_FB_NVIDIA = no;
              CONFIG_FB_NVIDIA_I2C = no;
              CONFIG_FB_NVIDIA_BACKLIGHT = no;
              CONFIG_HID_NVIDIA_SHIELD = no;
              CONFIG_TYPEC_NVIDIA_ALTMODE = no;
              CONFIG_NVIDIA_WMI_EC_BACKLIGHT = no;

              # Disable mitigations
              SPECULATION_MITIGATIONS = no;
              STACKPROTECTOR_STRONG = no;

              # NOTE: Required by bpf-restrict-fs
              # # Reduce debug info
              # DEBUG_INFO_REDUCED = mkForce yes;

              # Disable ms surface HID
              CONFIG_SURFACE_AGGREGATOR = no;

              # Disable unused wlan vendors
              WLAN_VENDOR_ADMTEK = no;
              WLAN_VENDOR_ATH = no;
              WLAN_VENDOR_ATMEL = no;
              WLAN_VENDOR_BROADCOM = no;
              WLAN_VENDOR_CISCO = no;
              WLAN_VENDOR_INTEL = no;
              WLAN_VENDOR_INTERSIL = no;
              WLAN_VENDOR_MARVELL = no;
              WLAN_VENDOR_MEDIATEK = yes;
              WLAN_VENDOR_MICROCHIP = no;
              WLAN_VENDOR_PURELIFI = no;
              WLAN_VENDOR_RALINK = no;
              WLAN_VENDOR_REALTEK = no;
              WLAN_VENDOR_RSI = no;
              WLAN_VENDOR_SILABS = no;
              WLAN_VENDOR_ST = no;
              WLAN_VENDOR_TI = no;
              WLAN_VENDOR_ZYDAS = no;
              WLAN_VENDOR_QUANTENNA = no;

              # Disable unused SOC modules
              SND_SOC_CHV3_I2S = no;
              SND_SOC_ADI = no;
              SND_SOC_APPLE_MCA = no;
              SND_ATMEL_SOC = no;
              SND_DESIGNWARE_I2S = no;
              SND_SOC_FSL_ASRC = no;
              SND_SOC_FSL_SAI = no;
              SND_SOC_FSL_MQS = no;
              SND_SOC_FSL_AUDMIX = no;
              SND_SOC_FSL_SSI = no;
              SND_SOC_FSL_SPDIF = no;
              SND_SOC_FSL_ESAI = no;
              SND_SOC_FSL_MICFIL = no;
              SND_SOC_FSL_EASRC = no;
              SND_SOC_FSL_XCVR = no;
              SND_SOC_FSL_UTILS = no;
              SND_SOC_FSL_RPMSG = no;
              SND_I2S_HI6210_I2S = no;
              SND_SOC_IMG = no;
              SND_SOC_STI = no;
              SND_SOC_XILINX_I2S = no;
              SND_SOC_XILINX_AUDIO_FORMATTER = no;
              SND_SOC_XILINX_SPDIF = no;
              SND_XEN_FRONTEND = no;
            };
            ignoreConfigErrors = true;
          })
          .overrideAttrs (old: {
            NIX_ENFORCE_NO_NATIVE = false;

            preferLocalBuild = true;
            allowSubstitutes = false;
          }));
    })
  ];
}
