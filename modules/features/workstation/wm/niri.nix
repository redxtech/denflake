{ inputs, self, ... }:

{
  den.aspects.window-manager = {
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

            wayshot = lib.getExe pkgs.wayshot;
            path = config.xdg.userDirs.pictures + "/screenshots/$(date +%Y)/$(date +%Y-%m-%d_%H-%M-%S).png";
            toSatty = " | ${lib.getExe pkgs.satty} -f -";
            mkScreenshot =
              {
                edit ? false,
                select ? true,
              }:
              let
                primaryMonitor = lib.head (lib.filter (m: m.primary) host.settings.monitors.monitors);
                region = if select then "--geometry" else "--output ${primaryMonitor.name}";
              in
              pkgs.writeShellScriptBin "screenshot-region" ''
                mkdir -p ${config.xdg.userDirs.pictures}/screenshots/$(date +%Y)
                ${wayshot} ${region} --clipboard ${path} ${lib.optionalString edit toSatty}
              '';

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
              # overview.backdrop-color = config.lib.stylix.colors.base00;

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

              binds =
                let
                  playerctl = player: action: {
                    action.spawn = [
                      (lib.getExe pkgs.playerctl)
                    ]
                    ++ lib.optional (player != null) "--player=${player}"
                    ++ [ action ];
                    allow-when-locked = true;
                  };

                  footclient = "${config.programs.foot.package}/bin/footclient";
                  kitty = [
                    (lib.getExe config.programs.kitty.package)
                    "--single-instance"
                  ];
                in
                {
                  "Mod+Shift+Slash".action.show-hotkey-overlay = { };

                  "Mod+Q".action.close-window = { };

                  # launchers
                  "Mod+Return".action.spawn = footclient;
                  "Mod+Shift+Return".action.spawn = [
                    "${footclient}"
                    "--app-id=footclient_float"
                  ];
                  "Mod+Ctrl+Return".action.spawn = kitty;
                  "Mod+Ctrl+Shift+Return".action.spawn = kitty ++ [
                    "--class"
                    "kitty_float"
                  ];

                  "Mod+W".action.spawn = lib.getExe config.programs.firefox.package;
                  "Mod+G".action.spawn = lib.getExe pkgs.nemo-with-extensions;
                  "Mod+N".action.spawn = lib.getExe pkgs.obsidian;

                  "Mod+F".action.fullscreen-window = { };
                  "Mod+Shift+F".action.toggle-windowed-fullscreen = { };
                  "Mod+M".action.maximize-column = { };
                  "Mod+Shift+M".action.maximize-window-to-edges = { };
                  "Mod+R".action.switch-preset-column-width = { };
                  "Mod+Shift+R".action.switch-preset-window-height = { };

                  "Mod+S".action.toggle-window-floating = { };
                  "Mod+T".action.toggle-column-tabbed-display = { };
                  "Mod+Comma".action.consume-window-into-column = { };
                  "Mod+Period".action.expel-window-from-column = { };

                  "Mod+Space".action.spawn = noctalia "launcher toggle";
                  "Mod+Backspace".action.spawn = noctalia "sessionMenu toggle";
                  "Mod+c".action.spawn = noctalia "launcher clipboard";

                  "Mod+grave".action.toggle-overview = { };

                  "Mod+H".action.focus-column-or-monitor-left = { };
                  "Mod+J".action.focus-window-or-workspace-down = { };
                  "Mod+K".action.focus-window-or-workspace-up = { };
                  "Mod+L".action.focus-column-or-monitor-right = { };
                  "Mod+Left".action.focus-column-left = { };
                  "Mod+Down".action.focus-window-down = { };
                  "Mod+Up".action.focus-window-up = { };
                  "Mod+Right".action.focus-column-right = { };

                  "Mod+Shift+H".action.move-column-left = { };
                  "Mod+Shift+J".action.move-window-down-or-to-workspace-down = { };
                  "Mod+Shift+K".action.move-window-up-or-to-workspace-up = { };
                  "Mod+Shift+L".action.move-column-right = { };
                  "Mod+Shift+Left".action.move-column-left = { };
                  "Mod+Shift+Down".action.move-window-down = { };
                  "Mod+Shift+Up".action.move-window-up = { };
                  "Mod+Shift+Right".action.move-column-right = { };

                  "Mod+Home".action.focus-column-first = { };
                  "Mod+End".action.focus-column-last = { };
                  "Mod+Shift+Home".action.move-column-to-first = { };
                  "Mod+Shift+End".action.move-column-to-last = { };

                  # "Mod+Ctrl+H".action.focus-monitor-left = { };
                  # "Mod+Ctrl+J".action.focus-monitor-down = { };
                  # "Mod+Ctrl+K".action.focus-monitor-up = { };
                  # "Mod+Ctrl+L".action.focus-monitor-right = { };
                  "Mod+Ctrl+Left".action.focus-monitor-left = { };
                  "Mod+Ctrl+Down".action.focus-monitor-down = { };
                  "Mod+Ctrl+Up".action.focus-monitor-up = { };
                  "Mod+Ctrl+Right".action.focus-monitor-right = { };

                  # "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = { };
                  # "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = { };
                  # "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = { };
                  # "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = { };
                  "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = { };
                  "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = { };
                  "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = { };
                  "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = { };

                  "Mod+Page_Down".action.focus-workspace-down = { };
                  "Mod+Page_Up".action.focus-workspace-up = { };
                  "Mod+U".action.focus-workspace-down = { };
                  "Mod+I".action.focus-workspace-up = { };
                  "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = { };
                  "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = { };
                  "Mod+Ctrl+U".action.move-column-to-workspace-down = { };
                  "Mod+Ctrl+I".action.move-column-to-workspace-up = { };

                  "Mod+Shift+Page_Down".action.move-workspace-down = { };
                  "Mod+Shift+Page_Up".action.move-workspace-up = { };
                  "Mod+Shift+U".action.move-workspace-down = { };
                  "Mod+Shift+I".action.move-workspace-up = { };

                  # You can bind mouse wheel scroll ticks using the following syntax.
                  # These binds will change direction based on the natural-scroll setting.
                  #
                  # To avoid scrolling through workspaces really fast, you can use
                  # the cooldown-ms property. The bind will be rate-limited to this value.
                  # You can set a cooldown on any bind, but it's most useful for the wheel.
                  "Mod+WheelScrollDown" = {
                    cooldown-ms = 150;
                    action.focus-workspace-down = { };
                  };
                  "Mod+WheelScrollUp" = {
                    cooldown-ms = 150;
                    action.focus-workspace-up = { };
                  };
                  "Mod+Ctrl+WheelScrollDown" = {
                    cooldown-ms = 150;
                    action.move-column-to-workspace-down = { };
                  };
                  "Mod+Ctrl+WheelScrollUp" = {
                    cooldown-ms = 150;
                    action.move-column-to-workspace-up = { };
                  };

                  # You can refer to workspaces by index. However, keep in mind that
                  # niri is a dynamic workspace system, so these commands are kind of
                  # "best effort". Trying to refer to a workspace index bigger than
                  # the current workspace count will instead refer to the bottommost
                  # (empty) workspace.
                  #
                  # For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
                  # will all refer to the 3rd workspace.
                  "Mod+1".action.focus-workspace = 1;
                  "Mod+2".action.focus-workspace = 2;
                  "Mod+3".action.focus-workspace = 3;
                  "Mod+4".action.focus-workspace = 4;
                  "Mod+5".action.focus-workspace = 5;
                  "Mod+6".action.focus-workspace = 6;
                  "Mod+7".action.focus-workspace = 7;
                  "Mod+8".action.focus-workspace = 8;
                  "Mod+9".action.focus-workspace = 9;
                  "Mod+Shift+1".action.move-column-to-workspace = 1;
                  "Mod+Shift+2".action.move-column-to-workspace = 2;
                  "Mod+Shift+3".action.move-column-to-workspace = 3;
                  "Mod+Shift+4".action.move-column-to-workspace = 4;
                  "Mod+Shift+5".action.move-column-to-workspace = 5;
                  "Mod+Shift+6".action.move-column-to-workspace = 6;
                  "Mod+Shift+7".action.move-column-to-workspace = 7;
                  "Mod+Shift+8".action.move-column-to-workspace = 8;
                  "Mod+Shift+9".action.move-column-to-workspace = 9;

                  "Mod+WheelScrollRight".action.focus-column-right = { };
                  "Mod+WheelScrollLeft".action.focus-column-left = { };
                  "Mod+Ctrl+WheelScrollRight".action.move-column-right = { };
                  "Mod+Ctrl+WheelScrollLeft".action.move-column-left = { };

                  # Finer width adjustments.
                  # This command can also:
                  # * set width in pixels: "1000"
                  # * adjust width in pixels: "-5" or "+5"
                  # * set width as a percentage of screen width: "25%"
                  # * adjust width as a percentage of screen width: "-10%" or "+10%"
                  # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
                  # set-column-width "100" will make the column occupy 200 physical screen pixels.
                  "Mod+Minus".action.set-column-width = "-10%";
                  "Mod+Equal".action.set-column-width = "+10%";

                  # Finer height adjustments when in column with other windows.
                  "Mod+Shift+Minus".action.set-window-height = "-10%";
                  "Mod+Shift+Equal".action.set-window-height = "+10%";

                  # lock screen
                  "Mod+Ctrl+L".action.spawn = noctalia "lockScreen lock";

                  "Print".action.spawn-sh = lib.getExe (mkScreenshot { });
                  "Mod+Print".action.spawn-sh = lib.getExe (mkScreenshot {
                    edit = true;
                  });

                  "Shift+Print".action.spawn-sh = lib.getExe (mkScreenshot {
                    select = false;
                  });
                  "Mod+Shift+Print".action.spawn-sh = lib.getExe (mkScreenshot {
                    select = false;
                    edit = true;
                  });

                  "Ctrl+Print".action.screenshot-screen = { };
                  "Alt+Print".action.screenshot-window = { };

                  # The quit action will show a confirmation dialog to avoid accidental exits.
                  "Mod+Shift+E".action.quit = { };

                  # Powers off the monitors. To turn them back on, do any input like
                  # moving the mouse or pressing any other key.
                  "Mod+Shift+P".action.power-off-monitors = { };

                  "XF86AudioRaiseVolume".action.spawn = noctalia "volume increase";
                  "XF86AudioLowerVolume".action.spawn = noctalia "volume decrease";
                  "XF86AudioMute".action.spawn = noctalia "volume muteOutput";
                  "XF86AudioMicMute".action.spawn = noctalia "microphone muteInput";
                  "XF86MonBrightnessUp".action.spawn = noctalia "brightness increase";
                  "XF86MonBrightnessDown".action.spawn = noctalia "brightness decrease";

                  "XF86AudioPlay" = playerctl "spotify" "play-pause";
                  "XF86AudioNext" = playerctl "spotify" "next";
                  "XF86AudioPrev" = playerctl "spotify" "previous";

                  "Shift+XF86AudioPlay" = playerctl "firefox" "play-pause";
                  "Shift+XF86AudioNext" = playerctl "firefox" "next";
                  "Shift+XF86AudioPrev" = playerctl "firefox" "previous";

                  "Alt+XF86AudioPlay" = playerctl "mpv" "play-pause";
                  "Alt+XF86AudioNext" = playerctl "mpv" "next";
                  "Alt+XF86AudioPrev" = playerctl "mpv" "previous";

                  "Ctrl+XF86AudioPlay" = playerctl null "play-pause";
                  "Ctrl+XF86AudioNext" = playerctl null "next";
                  "Ctrl+XF86AudioPrev" = playerctl null "previous";
                };

              window-rules = [
                {
                  matches = [ { app-id = "firefox-nightly"; } ];
                  open-on-workspace = "browser";
                  default-column-width.proportion = 1.0;
                  # open-maximized-to-edges = true;
                }
                {
                  matches = [
                    { app-id = "discord"; }
                    { app-id = "vesktop"; }
                  ];
                  open-on-workspace = "chat";
                  open-focused = false;
                  default-column-width.proportion = 1.0;
                  # open-maximized-to-edges = true;
                }
                {
                  matches = [ { app-id = "spotify"; } ];
                  open-on-workspace = "music";
                  open-focused = false;
                  default-column-width.proportion = 1.0;
                  # open-maximized-to-edges = true;
                }

                {
                  matches = [
                    {
                      app-id = "mpv";
                      title = "Webcam";
                    }
                  ];
                  open-floating = true;
                }

                # TODO: add rules for opacity & blur
                {
                  matches = [
                    { app-id = "nemo"; }
                    { app-id = "thunar"; }
                    { app-id = "nautilus"; }
                    { app-id = "dolphin"; }
                    { is-focused = false; }
                  ];
                  opacity = 0.9;
                  # background-effect.blur = true;
                }

                # steam stuff
                {
                  matches = [ { app-id = "gamescope"; } ];
                  open-fullscreen = true;
                }
                # steam notifications: https://niri-wm.github.io/niri/Application-Issues.html#steam
                {
                  matches = [
                    {
                      app-id = "steam";
                      title = "^notificationtoasts_\\d+_desktop$";
                    }
                  ];
                  default-floating-position = {
                    x = 10;
                    y = 10;
                    relative-to = "bottom-right";
                  };
                  open-focused = false;
                }
              ]
              ++ (map
                (app-id: {
                  matches = [ { inherit app-id; } ];
                  open-floating = true;
                  default-window-height.fixed = 700;
                  default-column-width.fixed = 1200;
                })
                [
                  "footclient_float"
                  "kitty_float"
                  "obsidian"
                  "org.pulseaudio.pavucontrol"
                  "pavucontrol"
                  "pwvucontrol"
                  ".piper-wrapped"
                  ".blueman-manager-wrapped"
                ]
              );

              spawn-at-startup = [
                {
                  argv = [
                    (lib.getExe pkgs.thunar)
                    "--daemon"
                  ];
                }
                {
                  argv = [
                    (lib.getExe pkgs.sftpman)
                    "mount_all"
                  ];
                }
              ];
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
