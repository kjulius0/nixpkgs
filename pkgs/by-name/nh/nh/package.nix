{ stdenv
, lib
, rustPlatform
, installShellFiles
, makeBinaryWrapper
, darwin
, fetchFromGitHub
, nix-update-script
, nvd
, nix-output-monitor
}:
let
  version = "3.5.4";
  runtimeDeps = [ nvd nix-output-monitor ];
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "nh";

  src = fetchFromGitHub {
    owner = "viperML";
    repo = "nh";
    rev = "refs/tags/v${version}";
    hash = "sha256-fnuVQqdK48c66EC4mL8t7uLhwsY6JDyn7H5tjRpx9Sg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ];

  buildInputs = lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.SystemConfiguration ];

  preFixup = ''
    mkdir completions
    $out/bin/nh completions --shell bash > completions/nh.bash
    $out/bin/nh completions --shell zsh > completions/nh.zsh
    $out/bin/nh completions --shell fish > completions/nh.fish

    installShellCompletion completions/*
  '';

  postFixup = ''
    wrapProgram $out/bin/nh \
      --prefix PATH : ${lib.makeBinPath runtimeDeps}
  '';

  cargoHash = "sha256-njJdwaJtLB4S36mS8miwrk7jo5U7BzOIlXqh3qNyA5E=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Yet another nix cli helper";
    homepage = "https://github.com/viperML/nh";
    license = lib.licenses.eupl12;
    mainProgram = "nh";
    maintainers = with lib.maintainers; [ drupol viperML ];
  };
}
