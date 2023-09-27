{
  description = "Postgrest";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/92d295f588631b0db2da509f381b4fb1e74173c5";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      foldMap = f:
        builtins.foldl' (acc: x: lib.recursiveUpdate acc (f x)) { };

      pgrst = system:
        let
          pkgs = nixpkgs.legacyPackages."${system}";
          p = import ./. {
            inherit nixpkgs system;
          };
        in
        {
          packages."${system}".default =
            if pkgs.hostPlatform.isLinux && pkgs.hostPlatform.isx86_64
            then p.postgrestStatic
            else
              lib.pipe p.postgrestPackage
                [ pkgs.haskell.lib.justStaticExecutables ];
        };
    in
    foldMap pgrst [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
}
