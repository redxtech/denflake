# aspect for the user "gabe"

{ den, ... }:

{
  den.aspects.gabe = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "fish")
      den.aspects.bar
    ];

    nixos =
      { config, ... }:
      {
        users.mutableUsers = false;
        users.users.gabe = {
          description = "Gabe Dunn";
          isNormalUser = true;
          hashedPasswordFile = config.sops.secrets.gabe-pw.path;
          openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];

          extraGroups =
            let
              inherit (builtins) filter hasAttr;
              ifTheyExist = groups: filter (group: hasAttr group config.users.groups) groups;
            in
            (
              [
                "video"
                "audio"
              ]
              ++ ifTheyExist [
                "data"
                "docker"
                "git"
                "hass"
                "input"
                "plugdev"
              ]
            );
        };

        sops.secrets.gabe-pw.neededForUsers = true;
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          btop
          git
          neovim

          alacritty
          fuzzel
          kitty
          kitty.terminfo
        ];
      };

    # user can provide NixOS configurations to any host it is included on
    provides.to-hosts.nixos =
      { pkgs, ... }:
      {
        # make gabe a trusted user in a couple of ways
        users.users.root.openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];
        nix.settings.trusted-users = [ "gabe" ];
      };
  };
}
