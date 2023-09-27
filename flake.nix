{
  description = "Postgrest";

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      extraOverrides = final: prev: {
        http2 = pkgs.haskell.lib.dontCheck prev.http2;
      };
      p = import ./. {
        inherit nixpkgs extraOverrides;
        inherit (pkgs) system;
      };
    in
    {
      packages.aarch64-darwin.default = lib.pipe p.postgrestPackage
        [ pkgs.haskell.lib.justStaticExecutables ];
      checks.aarch64-darwin.default = p.tests;
    };
}
