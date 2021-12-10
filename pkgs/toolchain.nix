{ callPackage
, target
, target-cflags ? [ ]
, xtensa-dynconfig ? null
, sources
}: rec {
  binutils = callPackage ./binutils.nix {
    inherit sources target;
  };
  gcc-static = callPackage ./gcc.nix {
    inherit sources target target-cflags xtensa-dynconfig;
    target-binutils = binutils;
    langCC = false;
  };
  newlib = callPackage ./newlib.nix {
    inherit sources target target-cflags xtensa-dynconfig;
    target-gcc = gcc-static;
    target-binutils = binutils;
  };
  gcc = callPackage ./gcc.nix {
    inherit sources target target-cflags xtensa-dynconfig;
    target-binutils = binutils;
    target-newlib = newlib;
  };
  gdb = callPackage ./gdb.nix {
    inherit target;
  };
}
