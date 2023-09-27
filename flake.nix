{
  description = "Postgrest";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/4bbf5a2eb6046c54f7a29a0964c642ebfe912cbc";
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
            http2 = pkgs.haskell.lib.dontCheck prev.http2;
          };
          p = import ./. {
            inherit nixpkgs extraOverrides system;
          };
        in
        {
          packages."${system}".default =
            if pkgs.hostPlatform.isLinux
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
