{
  mkDerivation, lib, kdepimTeam,
  extra-cmake-modules, kdoctools,
  akonadi, akonadi-mime, karchive, kcompletion, kconfig, kcoreaddons, ki18n,
  kmime, kxmlgui, libkdepim, pimcommon
}:

mkDerivation {
  pname = "mailimporter";
  meta = {
    license = with lib.licenses; [ gpl2Plus lgpl21Plus fdl12Plus ];
    maintainers = kdepimTeam;
  };
  nativeBuildInputs = [ extra-cmake-modules kdoctools ];
  buildInputs = [
    akonadi akonadi-mime karchive kcompletion kconfig kcoreaddons ki18n kmime
    kxmlgui libkdepim pimcommon
  ];
}
