{ lib
, stdenv
, fetchzip
, firefox-bin
, suffix
, revision
, system
, throwSystem
}:
let
  suffix' = if lib.hasPrefix "linux" suffix
            then "ubuntu-22.04" + (lib.removePrefix "linux" suffix)
            else suffix;
in
stdenv.mkDerivation {
  name = "firefox";
  src = fetchzip {
    url = "https://playwright.azureedge.net/builds/firefox/${revision}/firefox-${suffix'}.zip";
    sha256 = {
      x86_64-linux = "1yqbq2g7g2cka934rpz75z9kb1m2445i44cmsx8v7j8kz9cryvnq";
      aarch64-linux = "179agr7s20kpq6064gjvlh6b28zikph3vv7zni66lj4gk4rcsm6h";
    }.${system} or throwSystem;
  };

  inherit (firefox-bin.unwrapped)
    nativeBuildInputs
    buildInputs
    runtimeDependencies
    appendRunpaths
    patchelfFlags
  ;

  buildPhase = ''
    mkdir -p $out/firefox
    cp -R . $out/firefox
  '';
}
