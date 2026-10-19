{
  description = "flake for https://github.com/facebookincubator/metaroce";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    metaroce = {
      url = "github:facebookincubator/metaroce";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      metaroce,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      buildInputs = with pkgs; [
        folly
        rdma-core
        gflags
        glog
        fmt
        boost
        fbthrift
        re2
        wangle
      ];
      nativeBuildInputs = with pkgs; [
        cmake
        ninja
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        inherit buildInputs;
        inherit nativeBuildInputs;
      };
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "rdma_gen";
        version = "0.0";
        src = metaroce.outPath;

        inherit buildInputs;
        inherit nativeBuildInputs;
        env = {
          VERBOSE = "1";
        };
        patches = [
          ./fix-stuff.patch
        ];
        preConfigure = ''
            cmakeFlagsArray+=(
              "-DCMAKE_CXX_FLAGS=\"-Wno-sign-compare\""
          )
        '';
      };
    };
}
