{ fetchFromGitHub, stdenv }:
let
  xtensa-overlays = fetchFromGitHub {
    owner = "espressif";
    repo = "xtensa-overlays";
    rev = "esp-2021r1";
    hash = "sha256:0hqzgwrjxlkdyyqkdna72wqmxbl97wvn3rp6khn3szrla8gq3mh4";
  };
in
stdenv.mkDerivation {
  name = "xtensa-dynconfig";
  src = fetchFromGitHub {
    owner = "espressif";
    repo = "xtensa-dynconfig";
    rev = "905b913aa65638be53ac22029c379fa16dab31db";
    hash = "sha256-QCWSo3fmr0g/dDYz81i/fttlDgGCAwcBtIMWTVg1ufg=";
  };
  postUnpack = ''
    cp -r ${xtensa-overlays} source/config
  '';

  installPhase = ''
    make install PREFIX=$out 
  '';
}
