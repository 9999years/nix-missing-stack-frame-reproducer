{
  bundlerEnv,
  myNamespace,
}:
bundlerEnv.override {
  inherit (myNamespace) ruby bundler;
}
