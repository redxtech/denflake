{
  inputs,
  self,
  den,
  ...
}:

{
  den.aspects.workstation = {
    includes = [
      den.aspects.base
      den.aspects.display-manager
      den.aspects.window-manager
      den.aspects.monitors
      den.aspects.bar
      den.aspects.screenshot
      den.aspects.portals

      den.aspects.autostart

      # include workstation-only sub-aspects
      den.aspects.editor._.for-workstation
    ];

    # TODO: move to own aspect
    homeManager =
      { pkgs, ... }:
      {
        programs.kitty.enable = true;
        programs.foot.enable = true;
        programs.foot.server.enable = true;

        xdg.enable = true;

        home.packages = with pkgs; [
          nemo-with-extensions # file manager
          nautilus # file manager
          qimgv # image viewer
          satty # image editor
          spotify # music player
          vesktop # discord client
        ];
      };
  };
}
