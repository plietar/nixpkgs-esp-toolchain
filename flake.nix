{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    perSystem = { pkgs, lib, self', ... }:
      let
        versions = [ "20240530" ];
        defaultVersion = "20240530";

        xtensa-dynconfig = pkgs.callPackage ./pkgs/xtensa-dynconfig.nix { };
        wrapXtensaToolchain = pkgs.callPackage ./pkgs/xtensa-make-wrapper.nix {
          inherit xtensa-dynconfig;
        };

        makeToolchain = version:
          let
            sources = lib.importJSON (./versions + "/${version}.json");
            riscv32-esp = pkgs.callPackage ./pkgs/toolchain.nix {
              inherit sources;
              target = "riscv32-esp-elf";
            };
            xtensa-esp = pkgs.callPackage ./pkgs/toolchain.nix {
              inherit sources;
              target = "xtensa-esp-elf";
              target-cflags = [ "-mlongjumps" ];
            };
          in
          {
            "riscv32-esp-binutils-${version}" = riscv32-esp.binutils;
            "riscv32-esp-gcc-${version}" = riscv32-esp.gcc;
            "riscv32-esp-gdb-${version}" = riscv32-esp.gdb;
            "xtensa-esp-binutils-${version}" = wrapXtensaToolchain "xtensa-esp-binutils" xtensa-esp.binutils;
            "xtensa-esp-gcc-${version}" = wrapXtensaToolchain "xtensa-esp-gcc" xtensa-esp.gcc;
          };
      in
      {
        packages = lib.attrsets.mergeAttrsList (map makeToolchain versions) // {
          "xtensa-esp-gcc" = self'.packages."xtensa-esp-gcc-${defaultVersion}";
          "riscv32-esp-gcc" = self'.packages."riscv32-esp-gcc-${defaultVersion}";
        };
        apps.update = {
          type = "app";
          program = builtins.toString (pkgs.writeShellScript "update" ''
            exec ${pkgs.python311}/bin/python3 ${./update.py} "$@"
          '');
        };
      };

    systems = [
      "x86_64-linux"
      "x86_64-darwin"
    ];
  };
}
