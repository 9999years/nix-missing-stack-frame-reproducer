{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    forAllSystems = function:
      builtins.mapAttrs
      (system: pkgs: function pkgs)
      nixpkgs.legacyPackages;
  in {
    packages = forAllSystems (pkgs: let
      inherit (pkgs) lib newScope;
    in
      lib.makeScope newScope (
        self:
          lib.packagesFromDirectoryRecursive {
            inherit (self) callPackage;
            directory = ./packages;
          }
      ));
  };
}
