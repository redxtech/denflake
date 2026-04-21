{ inputs, self, ... }:

{
  den.aspects.autostart = {
    homeManager =
      { pkgs, ... }:
      {
        xdg.autostart = {
          enable = true;
          entries = with pkgs; [
            "${vesktop}/share/applications/vesktop.desktop"
            # "${spotify}/share/applications/spotify.desktop"
          ];
        };
      };
  };
}
