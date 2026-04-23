{ inputs, self, ... }:

{
  den.aspects.portals = {
    nixos =
      { pkgs, ... }:
      {
        xdg.portal = {
          xdgOpenUsePortal = true;

          extraPortals = with pkgs; [
            xdg-desktop-portal-gnome
            xdg-desktop-portal-gtk
            gnome-keyring
          ];

          config = {
            common = {
              default = [
                "gtk"
                "gnome"
              ];
              "org.freedesktop.impl.portal.AppChooser" = [ "gtk" ];
              "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
              "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
              "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            };
          };
        };
      };

    services.gnome.gnome-keyring.enable = true;
  };
}
