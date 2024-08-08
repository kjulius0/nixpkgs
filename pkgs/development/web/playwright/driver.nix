{ lib
, stdenv
, chromium
, ffmpeg
, git
, jq
, nodejs
, fetchFromGitHub
, fetchurl
, linkFarm
, callPackage
, makeFontsConf
, makeWrapper
, runCommand
, unzip
, cacert
}:
let
  inherit (stdenv.hostPlatform) system;

  throwSystem = throw "Unsupported system: ${system}";
  suffix = {
    x86_64-linux = "linux";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "mac";
    aarch64-darwin = "mac-arm64";
  }.${system} or throwSystem;

  driver = stdenv.mkDerivation (finalAttrs:
    let
      filename = "playwright-${finalAttrs.version}-${suffix}.zip";
    in
    {
    pname = "playwright-driver";
    # run ./pkgs/development/python-modules/playwright/update.sh to update
    version = "1.43.1";

    src = fetchurl {
      url = "https://playwright.azureedge.net/builds/driver/${filename}";
      sha256 = {
        x86_64-linux = "1cladmmrn4ymxhmr20jc75a64z7wcmwdbjvljawql0inaw4v2lw8";
        aarch64-linux = "1wacna8wvjxm6b0lyvsly3ksbm68jic2i1rrh5wqw5raw4z1fz44";
        x86_64-darwin = "1hl87z3cx2s9vkc1c3gwva352z3gi8vwd4aj3ia470yym6jns2xk";
        aarch64-darwin = "0d0gp1nvshflw7v1cmcpz6wwrpc53dm8c7yrpwa1mlrc8i1skpyd";
      }.${system} or throwSystem;
    };

    sourceRoot = ".";

    nativeBuildInputs = [ unzip ];

    postPatch = ''
      # Use Nix's NodeJS instead of the bundled one.
      substituteInPlace playwright.sh --replace '"$SCRIPT_PATH/node"' '"${nodejs}/bin/node"'
      rm node

      # Hard-code the script path to $out directory to avoid a dependency on coreutils
      substituteInPlace playwright.sh \
        --replace 'SCRIPT_PATH="$(cd "$(dirname "$0")" ; pwd -P)"' "SCRIPT_PATH=$out"

      patchShebangs playwright.sh package/bin/*.sh
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mv playwright.sh $out/bin/playwright
      mv package $out/

      runHook postInstall
    '';

    passthru = {
      inherit filename;
      browsersJSON = (lib.importJSON ./browsers.json).browsers;

      browsers = {
        x86_64-linux = browsers-linux { };
        aarch64-linux = browsers-linux { };
        x86_64-darwin = browsers-mac;
        aarch64-darwin = browsers-mac;
      }.${system} or throwSystem;
      browsers-chromium = browsers-linux {};
    };
    meta.mainProgram = "playwright";
  });

  browsers-mac = stdenv.mkDerivation {
    pname = "playwright-browsers";
    inherit (driver) version;

    dontUnpack = true;

    nativeBuildInputs = [
      cacert
    ];

    installPhase = ''
      runHook preInstall

      export PLAYWRIGHT_BROWSERS_PATH=$out
      ${driver}/bin/playwright install
      rm -r $out/.links

      runHook postInstall
    '';

    meta.platforms = lib.platforms.darwin;
  };

  browsers-linux = {
    withChromium ? true,
    withFirefox ? true,
    withWebkit ? true,
    withFfmpeg ? true
  }: let
    browsers =
      lib.optionals withChromium ["chromium"]
      ++ lib.optionals withFirefox ["firefox"]
      ++ lib.optionals withWebkit ["webkit"]
      ++ lib.optionals withFfmpeg ["ffmpeg"];
    inherit (stdenv.hostPlatform) system;
    throwSystem = throw "Unsupported system: ${system}";
  in
    linkFarm
      "playwright-browsers"
      (lib.listToAttrs
        (map
          (name: let
            value = driver.passthru.browsersJSON.${name};
          in lib.nameValuePair
            # TODO check platform for revisionOverrides
            "${name}-${value.revision}"
            (callPackage ./${name}.nix {
              inherit suffix system throwSystem;
              inherit (value) revision;
            })
          )
          browsers));
in
  driver
