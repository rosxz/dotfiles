{...}: self: super: {
  xarchiver = super.xarchiver.overrideAttrs (old: {
    postInstall = ''
      rm -rf $out/libexec
    '';
  });

  xfce = super.xfce.overrideScope (xself: xsuper: {
    thunar-archive-plugin = xsuper.thunar-archive-plugin.overrideAttrs (old: {
      postInstall = ''
        cp ${super.xarchiver}/libexec/thunar-archive-plugin/* $out/libexec/thunar-archive-plugin/
      '';
    });
  });
}
