{ inputs, self, ... }:

{
  den.aspects.autostart = {
    homeManager =
      { pkgs, lib, ... }:
      {
        home.packages = with pkgs; [ dex ];

        xdg.autostart = {
          enable = true;
          entries = with pkgs; [
            "${vesktop}/share/applications/vesktop.desktop"
            # "${spotify}/share/applications/spotify.desktop"
          ];
        };

        # use niri to start these
        programs.niri.settings.spawn-at-startup = [
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
}
