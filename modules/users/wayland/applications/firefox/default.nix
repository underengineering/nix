{inputs}: {
  self,
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  cfg = config.modules.wayland.firefox;
in {
  options.modules.wayland.firefox = {
    enable = mkOption {
      description = "Enable firefox";
      type = types.bool;
      default = true;
    };
    package = mkOption {
      description = "Firefox package to use";
      type = types.package;
      default = pkgs.firefox;
    };
    extraConfig = mkOption {
      description = "Config that will be appended after arkenfox";
      type = types.str;
      default = "";
    };
    extraUserChrome = mkOption {
      description = "CSS code that will be appended after shyfox";
      type = types.str;
      default = "";
    };
  };
  config = let
    firefoxConfigPath = ".mozilla/firefox";
    mainProfileName = "main";
  in
    mkIf (cfg.enable) {
      programs.firefox = {
        enable = true;
        package = cfg.package;
        profiles = {
          ${mainProfileName} = {
            extraConfig = (builtins.readFile "${inputs.arkenfox}/user.js") + cfg.extraConfig;
          };
          clean = {
            id = 1;
            extraConfig = cfg.extraConfig;
          };
        };
      };
      # Link shyfox
      home.file."${firefoxConfigPath}/${mainProfileName}/chrome/userChrome.css".text = ''
        /* imports */
        @import url("ShyFox/shy-variables.css");
        @import url("ShyFox/shy-global.css");
        @import url("ShyFox/shy-sidebar.css");
        @import url("ShyFox/shy-toolbar.css");
        @import url("ShyFox/shy-navbar.css");
        @import url("ShyFox/shy-findbar.css");
        @import url("ShyFox/shy-controls.css");
        @import url("ShyFox/shy-compact.css");
        @import url("ShyFox/shy-icons.css");
        @import url("ShyFox/shy-floating-search.css");
        ${cfg.extraUserChrome}
      '';
      home.file."${firefoxConfigPath}/${mainProfileName}/chrome/userContent.css".source = inputs.shyfox + "/chrome/userContent.css";
      home.file."${firefoxConfigPath}/${mainProfileName}/chrome/ShyFox" = {
        executable = false;
        recursive = true;
        source = "${inputs.shyfox}/chrome/ShyFox";
      };
      home.file."${firefoxConfigPath}/${mainProfileName}/chrome/icons" = {
        executable = false;
        recursive = true;
        source = "${inputs.shyfox}/chrome/icons";
      };
    };
}
