{ den, lib, ... }:

{
  den.aspects.workstation = {
    settings.isLaptop = lib.mkEnableOption "Whether the host is a laptop";

    includes = [
      den.aspects.base
      den.aspects.display-manager
      den.aspects.window-manager

      den.aspects.audio
      den.aspects.autostart
      den.aspects.bar
      den.aspects.default-apps
      den.aspects.flatpak
      den.aspects.monitors
      den.aspects.portals
      den.aspects.screenshot

      den.aspects.spotify
      den.aspects.terminal

      # include workstation-only sub-aspects
      den.aspects.editor._.for-workstation
    ];

    # TODO: add more apps

    # feh
    # mpv
    # nemo
    # rofi
    # spotify
    # thunar
    # thunderbird
    # zathura
    # playerctld

    # TODO: move to own aspect
    homeManager =
      { config, pkgs, ... }:
      {
        xdg.enable = true;

        home.packages = with pkgs; [
          # TODO: add more to here
          nemo-with-extensions # file manager
          nautilus # file manager
          qimgv # image viewer
          satty # image editor
          thunar # file manager
          vesktop # discord client
        ];
      };
  };
}
