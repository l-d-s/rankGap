{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: let
    l = nixpkgs.lib // builtins;
    supportedSystems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    forAllSystems = f: l.genAttrs supportedSystems (system: f system (import nixpkgs { inherit system; }));

    # Define R packages used across devShell and build
    commonRPackages = pkgs: with pkgs.rPackages; [
      ggplot2
      cowplot
      colorspace
      forcats
      rlang
    ];

    vscodeRPackages = pkgs: with pkgs.rPackages; [
      languageserver
      httpgd
      jsonlite
      devtools
    ];

    additionalRPackages = pkgs: with pkgs.rPackages; [
      eulerr
      qvalue
      tidyverse
    ];

    rPackageList = pkgs: vscodeRPackages pkgs ++ additionalRPackages pkgs ++ commonRPackages pkgs;

    # Define R wrappers
    radianWrapper = pkgs: pkgs.radianWrapper.override {
      packages = rPackageList pkgs;
    };

    rWrapper = pkgs: pkgs.rWrapper.override {
      packages = rPackageList pkgs;
    };

  in {
    # Development shell
    devShell = forAllSystems (system: pkgs: pkgs.mkShell {
      shellHook = ''
        export RADIAN_BIN=${radianWrapper pkgs}/bin/radian
        export R_BIN=${rWrapper pkgs}/bin/R
        tmpfile=$(mktemp)

        # VSCode seems unable to properly read dev shell environment variables
        # => manually patch local settings
        cat .vscode/settings.json |
          jq '."r.rterm.linux" = env.RADIAN_BIN | ."r.rpath.linux" = env.R_BIN' > $tmpfile
        mv $tmpfile .vscode/settings.json
      '';
      buildInputs = [
        (rWrapper pkgs)
        (radianWrapper pkgs)
        pkgs.jq
      ];
    });

    # Package definition
    packages = forAllSystems (system: pkgs: {
      default = pkgs.rPackages.buildRPackage {
        name = "rankGap";
        src = ./.;
        propagatedBuildInputs = commonRPackages pkgs;
      };
    });
  };
}
