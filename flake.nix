{
  description = "Postgrest";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/dbf5322e93bcc6cfc52268367a8ad21c09d76fea";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      foldMap = f:
        builtins.foldl' (acc: x: lib.recursiveUpdate acc (f x)) { };

      pgrst = system:
        let
          pkgs = nixpkgs.legacyPackages."${system}";
          extraOverrides = final: prev: {
            # http2 = pkgs.haskell.lib.dontCheck prev.http2;
          };
          p = import ./. {
            inherit nixpkgs extraOverrides system;
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
