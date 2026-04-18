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

      # include workstation-only sub-aspects
      den.aspects.editor._.for-workstation
    ];
  };
}
