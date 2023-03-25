let
  version = "7.0.1";
in
{ inputs, ... }: self: super: rec {
  realvnc-vnc-viewer = super.realvnc-vnc-viewer.overrideAttrs (old: {
    version = "7.0.1";
    src = super.fetchurl {
      url = "https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-${version}-Linux-x64.rpm";
      sha256 = "26d5745c8fd7dc93219ee150f4f812f66fe75f86db81c1ff15f49ac8e7c9f7ed";
    };
  });
}
