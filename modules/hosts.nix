# defines all hosts + users + homes.
# then config their aspects in as many files you want
{
  # gabe user at neobastion host.
  den.hosts.x86_64-linux.neobastion.users.gabe = { };

  # define an standalone home-manager for gabe
  # den.homes.x86_64-linux.gabe = { };

  # be sure to add nix-darwin input for this:
  # den.hosts.aarch64-darwin.apple.users.alice = { };

  # other hosts can also have user gabe.
  # den.hosts.x86_64-linux.south = {
  #   wsl = { }; # add nixos-wsl input for this.
  #   users.gabe = { };
  #   users.orca = { };
  # };
}
