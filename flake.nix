{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.haskell-flake.flakeModule ];

      perSystem = { self', pkgs, ... }: {
        haskellProjects.default = {
          basePackages = pkgs.haskell.packages.ghc945;

          packages = {
            # ansi-terminal.source = "1.0";
          };
          settings = {
            vector = {
              check = false;
            };
            # cabal = {
            #   haddock = false;
            # };
            # elm = pkgs.haskell.lib.justStaticExecutables self'.packages.elm;
          };

          # overrides = self: super: {
          #   elm = pkgs.haskell.lib.justStaticExecutables super.elm;
          # };
        };

        packages.default = pkgs.haskell.lib.justStaticExecutables self'.packages.elm;
      };
    };
}
