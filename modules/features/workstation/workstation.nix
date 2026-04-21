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
      den.aspects.monitors
      den.aspects.portals
      den.aspects.screenshot

      # include workstation-only sub-aspects
      den.aspects.editor._.for-workstation
    ];

    # TODO: move to own aspect
    homeManager =
      { config, pkgs, ... }:
      {
        programs.kitty.enable = true;
        programs.foot.enable = true;
        programs.foot.server.enable = true;
        programs.foot.settings.main.font =
          let
            fonts = config.stylix.fonts;
            size = toString fonts.sizes.terminal;
          in
          lib.mkForce "${fonts.monospace.name}:size=${size}, Symbols Nerd Font:size=${size}";

        xdg.enable = true;

        home.packages = with pkgs; [
          nemo-with-extensions # file manager
          nautilus # file manager
          qimgv # image viewer
          satty # image editor
          spotify # music player
          thunar # file manager
          vesktop # discord client
        ];
      };
  };
}
