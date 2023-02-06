{ lib
, buildGoModule
, go
, fetchFromGitHub
, makeWrapper
}:

buildGoModule rec {
  pname = "operator-sdk";
  version = "1.27.0";

  src = fetchFromGitHub {
    owner = "operator-framework";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-rvLWM6G2kOOuFU0JuwdIjSCFNyjBNL+fOoEj+tIR190=";
  };

  vendorHash = "sha256-L+Z1k+z/XNO9OeTQVzNJd1caRip6Ti8mPfNmXJx5D5c=";

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    go
  ];

  doCheck = false;

  subPackages = [
    "cmd/ansible-operator"
    "cmd/helm-operator"
    "cmd/operator-sdk"
  ];

  # operator-sdk uses the go compiler at runtime
  allowGoReference = true;

  postFixup = ''
    wrapProgram $out/bin/operator-sdk --prefix PATH : ${lib.makeBinPath [ go ]}
  '';

  meta = with lib; {
    description = "SDK for building Kubernetes applications. Provides high level APIs, useful abstractions, and project scaffolding";
    homepage = "https://github.com/operator-framework/operator-sdk";
    changelog = "https://github.com/operator-framework/operator-sdk/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ arnarg ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
