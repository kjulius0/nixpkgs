{ lib
, black
, buildPythonPackage
, fetchPypi
, setuptools-scm
, cachecontrol
, lockfile
, mistune
, rdflib
, ruamel-yaml
, pytestCheckHook
, pythonOlder
}:

buildPythonPackage rec {
  pname = "schema-salad";
  version = "8.4.20230127112827";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-nptZTNveutV9bGSkDPWLfiBusZblVqd/5m7DN4HwGJY=";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    cachecontrol
    lockfile
    mistune
    rdflib
    ruamel-yaml
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ] ++ passthru.optional-dependencies.pycodegen;

  preCheck = ''
    rm tox.ini
  '';

  disabledTests = [
    # Setup for these tests requires network access
    "test_secondaryFiles"
    "test_outputBinding"
    # Test requires network
    "test_yaml_tab_error"
  ];

  pythonImportsCheck = [
    "schema_salad"
  ];

  passthru.optional-dependencies = {
    pycodegen = [
      black
    ];
  };

  meta = with lib; {
    description = "Semantic Annotations for Linked Avro Data";
    homepage = "https://github.com/common-workflow-language/schema_salad";
    changelog = "https://github.com/common-workflow-language/schema_salad/releases/tag/${version}";
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ veprbl ];
  };
}
