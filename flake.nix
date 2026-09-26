{
  inputs = {
    nixpkgs.follows = "lean4-nix/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    lean4-nix.url = "github:lenianiva/lean4-nix";
  };
  nixConfig = {
    trusted-substituters = [
      "https://cache.garnix.io"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = {system, ...}: let
        readBinaryToolchain = manifest @ {overlay ? final: prev: {}, ...}: final: prev:
          (overlay final prev)
          // {
            lean = (final.callPackage "${inputs.lean4-nix}/lib/toolchain.nix" {}).fetchBinaryLean manifest;
          };
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            (readBinaryToolchain {
              tag = "v4.34.1";
              toolchain = {
                "${system}" = {
                  url = "https://github.com/leanprover/lean4/releases/download/v4.34.1/lean-4.34.1-linux.tar.zst";
                  hash = "sha256-R79LvXj3DC6WcFmKtxJNkrbvtzMP8z5fu0Aw9v1y5OQ=";
                };
              };
            })
          ];
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            lean
            python3
          ];
        };
      };
    };
}
