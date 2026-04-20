{ inputs, self, ... }:

{
  den.aspects.bar = {
    nixos =
      { pkgs, ... }:
      {
        # to make noctalia’s wifi, bluetooth, power-profile, and battery features available
        networking.networkmanager.enable = true;
        hardware.bluetooth.enable = true;
        services.power-profiles-daemon.enable = true;
        services.upower.enable = true;

        # TODO: enable gnome evolution data server for calendar support
      };

    homeManager =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        imports = [ inputs.noctalia.homeModules.default ];

        home.packages = with pkgs; [
          inputs.noctalia.packages.${stdenv.hostPlatform.system}.default

          fastfetch # for system information
          gpu-screen-recorder # for screen recorder plugin
          qt6.qtwebsockets # for home assistant plugin
        ];

        programs.noctalia-shell = {
          enable = true;

          plugins = {
            sources = [
              {
                enabled = true;
                name = "Official Noctalia Plugins";
                url = "https://github.com/noctalia-dev/noctalia-plugins";
              }
            ];

            states = {
              github-feed = {
                enabled = true;
                sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
              };
              hassio = {
                enabled = true;
                sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
              };
              kde-connect = {
                enabled = true;
                sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
              };
              polkit-agent = {
                enabled = true;
                sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
              };
              privacy-indicator = {
                enabled = true;
                sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
              };
              screen-recorder = {
                enabled = true;
                sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
              };
              tailscale = {
                enabled = true;
                sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
              };
              weather-indicator = {
                enabled = true;
                sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
              };
            };

            version = 2;
          };

          pluginSettings = {
            kde-connect.hideIfNoDeviceConnected = true;
            privacy-indicator = {
              hideInactive = true;
              enableToast = false;
            };
            screen-recorder = {
              directory = config.xdg.userDirs.videos + "/Recordings";
              frameRate = "60";
              copyToClipboard = true;
              replayEnabled = false;
              replayDuration = "30";
            };
            tailscale = {
              compactMode = true;
              terminalCommand = lib.getExe config.programs.kitty.package;
              defaultPeerAction = "ssh";
            };
          };

          settings =
            let
              exported = (builtins.fromJSON (builtins.readFile ./config.json)).settings;

              barWithoutStylix = builtins.removeAttrs exported.bar [
                "backgroundOpacity"
                "capsuleOpacity"
              ];
              uiWithoutStylix = builtins.removeAttrs exported.ui [
                "fontDefault"
                "fontFixed"
                "panelBackgroundOpacity"
              ];
              dockWithoutStylix = builtins.removeAttrs exported.dock [ "backgroundOpacity" ];
              osdWithoutStylix = builtins.removeAttrs exported.osd [ "backgroundOpacity" ];
              notifsWithoutStylix = builtins.removeAttrs exported.notifications [ "backgroundOpacity" ];
              wlPasteCmd = type: "${pkgs.wl-clipboard}/bin/wl-paste --type ${type} --watch cliphist store";
              kittyFloat = cmd: "${lib.getExe config.programs.kitty.package} --class kitty_float -e ${cmd}";
            in
            {
              bar = barWithoutStylix;
              general = exported.general;
              ui = uiWithoutStylix;
              location = exported.location;
              calendar = exported.calendar;
              wallpaper = exported.wallpaper;
              appLauncher = exported.appLauncher // {
                terminalCommand = (lib.getExe config.programs.kitty.package) + " -e";
                screenshotAnnotationTool = (lib.getExe pkgs.satty) + " -f";
                clipboardWatchTextCommand = wlPasteCmd "text";
                clipboardWatchImageCommand = wlPasteCmd "image";
              };
              controlCenter = exported.controlCenter;
              systemMonitor = exported.systemMonitor // {
                externalMonitor = kittyFloat "btop";
              };
              noctaliaPerformance = exported.noctaliaPerformance;
              dock = dockWithoutStylix;
              network = exported.network;
              sessionMenu = exported.sessionMenu;
              notifications = notifsWithoutStylix;
              osd = osdWithoutStylix;
              audio = exported.audio;
              brightness = exported.brightness;
              colorSchemes = exported.colorSchemes;
              templates = exported.templates;
              nightLight = exported.nightLight;
              hooks = exported.hooks;
              plugins = exported.plugins;
              idle = exported.idle;
              desktopWidgets = exported.desktopWidgets;
            };
        };

        programs.niri.settings.spawn-at-startup = [ { argv = [ "noctalia-shell" ]; } ];

        sops.secrets = {
          github-feed = {
            sopsFile = ../../../../secrets/users/gabe/noctalia.yaml;
            path = config.xdg.configHome + "/noctalia/plugins/github-feed/settings.json";
          };
          hassio = {
            sopsFile = ../../../../secrets/users/gabe/noctalia.yaml;
            path = config.xdg.configHome + "/noctalia/plugins/hassio/settings.json";
          };
        };
      };
  };

  # allow exporting noctalia config to a file
  perSystem =
    { pkgs, lib, ... }:
    {
      apps.write-noctalia = {
        type = "app";
        program = lib.getExe (
          pkgs.writeShellApplication {
            name = "write-noctalia";
            # runtimeInputs = [ inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default ];
            text = ''
              noctalia-shell ipc call state all
            '';
          }
        );
      };
    };

  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };
}
