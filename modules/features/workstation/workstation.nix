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
      den.aspects.bar
    ];
  };
}
