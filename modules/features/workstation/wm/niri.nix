{ inputs, den, ... }:

{
  den.aspects.window-manager = {
    includes = [
      den.aspects.window-manager-binds
      den.aspects.window-manager-rules
    ];

    nixos =
      { inputs', pkgs, ... }:
      {
        imports = [ inputs.niri.nixosModules.niri ];

        programs.niri = {
          enable = true;
          package = inputs'.niri.packages.niri-unstable;
        };

        # disable flake cache, since we have it already enabled in this flake's nixConfig
        niri-flake.cache.enable = false;

        # use nemo for file picker
        xdg.portal.config.niri = {
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        };

        # configure greetd to use niri
        services.greetd.settings.default_session.command =
          "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";

        # disable kde polkit agent, since we're using noctalia-shell's
        systemd.user.services.niri-flake-polkit.enable = false;

        environment = {
          sessionVariables = {
            ELECTRON_OZONE_PLATFORM_HINT = "auto";
            NIXOS_OZONE_WL = "1";
            QT_QPA_PLATFORM = "wayland";
          };
        };
      };

    homeManager =
      {
        inputs',
        config,
        host,
        pkgs,
        lib,
        ...
      }:
      {
        programs.niri =
          let
            noctalia =
              cmd:
              [
                "noctalia-shell"
                "ipc"
                "call"
              ]
              ++ (lib.splitString " " cmd);

            niriPkgs = inputs'.niri.packages;
          in
          {
            settings = {
              xwayland-satellite.path = lib.getExe niriPkgs.xwayland-satellite-unstable;

              prefer-no-csd = true; # prefer no client side decorations
              screenshot-path = "${config.xdg.userDirs.pictures}/screenshots/%Y/%Y-%m-%d_%H-%M-%S.png";
              hotkey-overlay.skip-at-startup = true;
              gestures.hot-corners.enable = false;

              input = {
                focus-follows-mouse.enable = true;
                workspace-auto-back-and-forth = true;

                keyboard = {
                  repeat-rate = 40;
                  repeat-delay = 240;
                };

                touchpad = {
                  tap = true;
                  dwt = true;
                  scroll-factor = 0.5;
                  middle-emulation = true;

                  natural-scroll = true;
                };

                # disable-power-key-handling = true;
              };

              animations.slowdown = 0.75;
              animations.screenshot-ui-open.enable = false;
              overview.backdrop-color = config.lib.stylix.colors.base00;

              # TODO: wait until PR is merged and flake options are updated (https://github.com/sodiboo/niri-flake/pull/1548)

              # blur = {
              #   passes = 3;
              #   offset = 3.0;
              #   noise = 0.02;
              #   saturation = 1.5;
              # };

              layout = {
                gaps = 10;
                background-color = config.lib.stylix.colors.base00;

                default-column-width.proportion = 2. / 3.;
                preset-column-widths = [
                  { proportion = 2. / 3.; }
                  { proportion = 1. / 3.; }
                ];
              };

              outputs =
                let
                  monitors = host.settings.monitors.monitors;

                  mkMonitor =
                    { name, primary, ... }@monitor:
                    {
                      inherit name;
                      value = {
                        inherit (monitor) enable scale;

                        focus-at-startup = primary;
                        variable-refresh-rate = monitor.vrr;

                        mode = {
                          inherit (monitor) width height;
                          refresh = monitor.rate;
                        };

                        position = {
                          inherit (monitor) x y;
                        };
                      };
                    };
                in
                builtins.listToAttrs (map mkMonitor monitors);

              workspaces =
                let
                  monitors = host.settings.monitors.monitors;

                  monitorsToWorkspaces =
                    monitors:
                    let
                      inherit (builtins) listToAttrs concatMap;
                      zeroPad =
                        n:
                        let
                          s = builtins.toString n;
                          padLength = 2 - builtins.stringLength s;
                          padding = builtins.concatStringsSep "" (builtins.genList (_: "0") padLength);
                        in
                        padding + s;
                    in
                    listToAttrs (
                      concatMap (
                        monitor:
                        map (workspace: {
                          name = "${zeroPad workspace.number}-${workspace.name}";
                          value = {
                            inherit (workspace) name;
                            open-on-output = monitor.name;
                          };
                        }) monitor.workspaces
                      ) monitors
                    );
                in
                monitorsToWorkspaces monitors;
            };
          };
      };
  };

  flake-file.inputs.niri = {
    url = "github:sodiboo/niri-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.nixConfig = {
    extra-substituters = [ "https://niri.cachix.org" ];
    extra-trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
  };
}
