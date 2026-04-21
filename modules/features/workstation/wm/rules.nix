{ inputs, self, ... }:

{
  den.aspects.window-manager-rules.homeManager = {
    programs.niri.settings = {
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

        # noctalia-shell settings
        {
          matches = [ { app-id = "dev.noctalia.noctalia-qs"; } ];
          open-floating = true;
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

      layer-rules = [
        {
          matches = [ { namespace = "^quickshell$"; } ];
          place-within-backdrop = true;
        }
      ];
    };
  };
}
