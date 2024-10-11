{ fetchFromGitHub, stdenv }:
let
  xtensa-overlays = fetchFromGitHub {
    owner = "espressif";
    repo = "xtensa-overlays";
    rev = "dd1cf19f6eb327a9db51043439974a6de13f5c7f";
    hash = "sha256-guFWS6QAjJ1Z2u2YOIha97EaBGLThWRz6kjrPSf0y9M=";
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
