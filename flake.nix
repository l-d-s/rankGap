{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inp:

  let
    l = nixpkgs.lib // builtins;
    supportedSystems = ["x86_64-linux" "aarch64-darwin"];
    forAllSystems = f:
      l.genAttrs supportedSystems
      (system: f system (import nixpkgs {inherit system;}));

  in

  {
    # enter this python environment by executing `nix shell .`
    devShell = forAllSystems (
      system: pkgs: let
        rPackages = pkgs.rPackages;
        
        vscodeRPackages = with rPackages; [
          languageserver
          httpgd
          rlang
          jsonlite
          # needed for knitr I think
          devtools
        ];
        additionalRPackages = with rPackages; [
          ggplot2
          cowplot
          colorspace
          # patchwork
          forcats

          # For building the readme
          eulerr
          qvalue

          # For development
          tidyverse
        ];
        rPackageList = vscodeRPackages ++ additionalRPackages;
        radianWrapper = pkgs.radianWrapper.override {
            packages = rPackageList;
            };
        rWrapper = pkgs.rWrapper.override {
          packages = rPackageList;
        };
      in
        pkgs.mkShell { 
          shellHook = ''
            export RADIAN_BIN=${radianWrapper.outPath}/bin/radian
            export R_BIN=${rWrapper.outPath}/bin/R
            tmpfile=$(mktemp)
            '' +
            # VSCode seems unable to properly read dev shell environment 
            # variables => manually patch local settings
            ''
            cat .vscode/settings.json |
              jq '."r.rterm.linux" = env.RADIAN_BIN | ."r.rpath.linux" = env.R_BIN' > \
              $tmpfile
            mv $tmpfile .vscode/settings.json
            '';
          buildInputs = [
              rWrapper
              radianWrapper
              pkgs.jq
              ]; }
    );
  };
}
