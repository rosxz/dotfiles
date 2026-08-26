{...}: self: super: {
  xarchiver = super.xarchiver.overrideAttrs (old: {
    postInstall = ''
      rm -rf $out/libexec
    '';
  });

  thunar-archive-plugin = super.thunar-archive-plugin.overrideAttrs (old: {
    postInstall = ''
      cp ${super.xarchiver}/libexec/thunar-archive-plugin/* $out/libexec/thunar-archive-plugin/
    '';
  });
}
