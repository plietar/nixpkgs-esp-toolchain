{ sources
, target
, lib
, stdenv
, fetchFromGitHub
, texinfo
, bison
, perl
, zlib
, gettext
, flex
}:
stdenv.mkDerivation {
  pname = "${target}-binutils";
  inherit (sources.binutils-gdb) version;

  src = fetchFromGitHub {
    inherit (sources.binutils-gdb) owner repo rev hash;
  };

  configureFlags = [
    "--target=${target}"
    "--enable-multilib"
    "--program-prefix=${target}-"
    "--disable-werror"
    "--with-system-zlib"
    "--disable-gdb"
    "--disable-sim"
  ];

  nativeBuildInputs = [
    texinfo
    flex
    bison
    perl
  ];
  buildInputs = [ zlib gettext ];
}
