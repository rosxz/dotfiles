{ lib, pkgs, python3Packages, fetchPypi, ... }:
python3Packages.buildPythonApplication rec {
  pname = "manga_ocr";
  version = "0.1.11";
  format = "wheel";

  # whatmp3 seems abandoned anyway so I'm using my own fork for the setup.py
  src = fetchPypi {
    inherit pname version format;
    sha256 = "sha256-PpoDc94cnhtuWjQgb/58TBtYI/K6RWFDdU4+cixLh6k=";
    python = "py3";
    dist = "py3";
    platform = "any";
  };

  doCheck = false;
  propagatedBuildInputs = with python3Packages; [
    fire
    fugashi
    jaconv
    loguru
    numpy
    pillow
    pyperclip
    torch
    transformers
    unidic-lite
  ];
}
