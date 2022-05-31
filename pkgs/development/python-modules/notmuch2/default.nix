{ stdenv
, lib

, buildPythonPackage
, notmuch
, python
, cffi
}:

buildPythonPackage {
  pname = "notmuch2";
  inherit (notmuch) version src;

  sourceRoot = "notmuch-${notmuch.version}/bindings/python-cffi";

  buildInputs = [ python notmuch cffi ];

  # since notmuch 0.35, this package expects _notmuch_config.py that is
  # generated by notmuch's configure script
  postPatch = ''
    cp ${notmuch.bindingconfig}/_notmuch_config.py .
  '';

  # no tests
  doCheck = false;
  pythonImportsCheck = [ "notmuch2" ];

  meta = with lib; {
    broken = stdenv.isDarwin;
    description = "Pythonic bindings for the notmuch mail database using CFFI";
    homepage = "https://notmuchmail.org/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ teto ];
  };
}
