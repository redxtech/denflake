{ inputs, self, ... }:

{
  den.aspects.portals = {
    nixos =
      { pkgs, ... }:
      {
        xdg.portal = {
          xdgOpenUsePortal = true;

          extraPortals = with pkgs; [
            gnome-keyring
            xdg-desktop-portal-gtk
            xdg-desktop-portal-luminous
          ];

          config.common = {
            preferred = [ "luminous" ];
            default = [
              "gtk"
              "gnome"
            ];
          };
        };
      };

    services.gnome.gnome-keyring.enable = true;
  };
}
