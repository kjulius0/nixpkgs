{ lib, stdenv
, fetchFromGitHub
, pkg-config
, curl
, mpv
, yajl
}:

stdenv.mkDerivation rec {
  pname = "jftui";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "Aanok";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-4j0ypzszNWjHbb4RkMIoqvgz624zoKCKiIpidQUPIF4=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    curl
    mpv
    yajl
  ];

  installPhase = ''
    install -Dm555 build/jftui $out/bin/jftui
  '';

  meta = with lib; {
    description = "Jellyfin Terminal User Interface ";
    homepage = "https://github.com/Aanok/jftui";
    license = licenses.unlicense;
    maintainers = [ maintainers.nyanloutre ];
    platforms = platforms.linux;
  };
}
