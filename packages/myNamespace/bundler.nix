{
  bundler,
  myNamespace,
}:
(bundler.override {
  inherit (myNamespace) ruby;
})
.overrideAttrs {
  dontBuild = false;
}
