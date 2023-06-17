{ lib
, buildGoModule
, fetchFromGitHub
, testers
, gtree
}:

buildGoModule rec {
  pname = "gtree";
  version = "1.7.46";

  src = fetchFromGitHub {
    owner = "ddddddO";
    repo = "gtree";
    rev = "v${version}";
    hash = "sha256-oh3xYTZb3WAaX2diBjLp6IZ+KKnUhlbITV2R3Yk3ins=";
  };

  vendorHash = "sha256-YrqJljKoYpsgVW4PPNYGMUB5uDQF0YTt9s7KxjQHkTw=";

  subPackages = [
    "cmd/gtree"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=${version}"
    "-X=main.Revision=${src.rev}"
  ];

  passthru.tests = {
    version = testers.testVersion {
      package = gtree;
      command = "gtree version";
    };
  };

  meta = with lib; {
    description = "Generate directory trees and directories using Markdown or programmatically";
    homepage = "https://github.com/ddddddO/gtree";
    changelog = "https://github.com/ddddddO/gtree/releases/tag/${src.rev}";
    license = licenses.bsd2;
    maintainers = with maintainers; [ figsoda ];
  };
}
