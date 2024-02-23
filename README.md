Reproducer for an unhelpful stack trace.

Nix 2.19.3 doesn't show the call site that contains the unexpected argument:

```
$ nix build .#myNamespace.gems --show-trace
error:
       … while calling the 'derivationStrict' builtin

         at /derivation-internal.nix:9:12:

            8|
            9|   strict = derivationStrict drvAttrs;
             |            ^
           10|

       … while evaluating derivation 'my-gems'
         whose name attribute is located at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/stdenv/generic/make-derivation.nix:353:7

       … while evaluating attribute 'passAsFile' of derivation 'my-gems'

         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/trivial-builders/default.nix:99:9:

           98|         inherit buildCommand name;
           99|         passAsFile = [ "buildCommand" ]
             |         ^
          100|           ++ (derivationArgs.passAsFile or [ ]);

       … from call site

         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/lib/trivial.nix:440:7:

          439|     { # TODO: Should we add call-time "type" checking like built in?
          440|       __functor = self: f;
             |       ^
          441|       __functionArgs = args;

       … while calling anonymous lambda

         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/lib/customisation.nix:104:34:

          103|       # Re-call the function but with different arguments
          104|       overrideArgs = mirrorArgs (newArgs: makeOverridable f (overrideWith newArgs));
             |                                  ^
          105|       # Change the result of the function call by applying g to it

       … from call site

         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/lib/trivial.nix:440:7:

          439|     { # TODO: Should we add call-time "type" checking like built in?
          440|       __functor = self: f;
             |       ^
          441|       __functionArgs = args;

       … while calling anonymous lambda

         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/lib/customisation.nix:96:17:

           95|     in
           96|     mirrorArgs (origArgs:
             |                 ^
           97|     let

       error: function 'anonymous lambda' called with unexpected argument 'ruby'

       at /nix/store/zpd0gmaic148sqyjn9f0ymsdk52ak9z9-source/packages/myNamespace/bundler.nix:1:1:

            1| {
             | ^
            2|   bundler,
```

With [my patch](https://github.com/NixOS/nix/pull/10066), we see the stack frame:

```
$ ~/nix/outputs/out/bin/nix build .#myNamespace.gems --show-trace
error:
       … while calling the 'derivationStrict' builtin
         at <nix/derivation-internal.nix>:9:12:
            8|
            9|   strict = derivationStrict drvAttrs;
             |            ^
           10|

       … while evaluating derivation 'my-gems'
         whose name attribute is located at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/stdenv/generic/make-derivation.nix:353:7

       … while evaluating attribute 'passAsFile' of derivation 'my-gems'
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/trivial-builders/default.nix:99:9:
           98|         inherit buildCommand name;
           99|         passAsFile = [ "buildCommand" ]
             |         ^
          100|           ++ (derivationArgs.passAsFile or [ ]);

       … while evaluating the attribute 'passAsFile'
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/buildenv/default.nix:76:5:
           75|     # XXX: The size is somewhat arbitrary
           76|     passAsFile = if builtins.stringLength pkgs >= 128*1024 then [ "pkgs" ] else [ ];
             |     ^
           77|   }

       … while evaluating a branch condition
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/buildenv/default.nix:76:18:
           75|     # XXX: The size is somewhat arbitrary
           76|     passAsFile = if builtins.stringLength pkgs >= 128*1024 then [ "pkgs" ] else [ ];
             |                  ^
           77|   }

       … in the argument of the not operator
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/buildenv/default.nix:76:48:
           75|     # XXX: The size is somewhat arbitrary
           76|     passAsFile = if builtins.stringLength pkgs >= 128*1024 then [ "pkgs" ] else [ ];
             |                                                ^
           77|   }

       … while calling the 'lessThan' builtin
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/buildenv/default.nix:76:48:
           75|     # XXX: The size is somewhat arbitrary
           76|     passAsFile = if builtins.stringLength pkgs >= 128*1024 then [ "pkgs" ] else [ ];
             |                                                ^
           77|   }

       … while calling the 'stringLength' builtin
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/buildenv/default.nix:76:21:
           75|     # XXX: The size is somewhat arbitrary
           76|     passAsFile = if builtins.stringLength pkgs >= 128*1024 then [ "pkgs" ] else [ ];
             |                     ^
           77|   }

       … while calling the 'toJSON' builtin
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/buildenv/default.nix:58:12:
           57|             nativeBuildInputs buildInputs;
           58|     pkgs = builtins.toJSON (map (drv: {
             |            ^
           59|       paths =

       … while evaluating list element at index 0

       … while evaluating attribute 'paths'
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/buildenv/default.nix:59:7:
           58|     pkgs = builtins.toJSON (map (drv: {
           59|       paths =
             |       ^
           60|         # First add the usual output(s): respect if user has chosen explicitly,

       … while evaluating a branch condition
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/buildenv/default.nix:64:10:
           63|         # aren't expected to have multiple outputs.
           64|         (if (! drv ? outputSpecified || ! drv.outputSpecified)
             |          ^
           65|             && drv.meta.outputsToInstall or null != null

       … in the left operand of the AND (&&) operator
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/buildenv/default.nix:65:13:
           64|         (if (! drv ? outputSpecified || ! drv.outputSpecified)
           65|             && drv.meta.outputsToInstall or null != null
             |             ^
           66|           then map (outName: drv.${outName}) drv.meta.outputsToInstall

       … in the left operand of the OR (||) operator
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/buildenv/default.nix:64:38:
           63|         # aren't expected to have multiple outputs.
           64|         (if (! drv ? outputSpecified || ! drv.outputSpecified)
             |                                      ^
           65|             && drv.meta.outputsToInstall or null != null

       … in the argument of the not operator
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/build-support/buildenv/default.nix:64:16:
           63|         # aren't expected to have multiple outputs.
           64|         (if (! drv ? outputSpecified || ! drv.outputSpecified)
             |                ^
           65|             && drv.meta.outputsToInstall or null != null

       … while calling a functor (an attribute set with a '__functor' attribute)
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/pkgs/development/ruby-modules/bundled-common/default.nix:50:10:
           49|     if hasBundler then gems.bundler
           50|     else defs.bundler.override (attrs: { inherit ruby; });
             |          ^
           51|

       … from call site
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/lib/trivial.nix:440:7:
          439|     { # TODO: Should we add call-time "type" checking like built in?
          440|       __functor = self: f;
             |       ^
          441|       __functionArgs = args;

       … while calling anonymous lambda
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/lib/customisation.nix:104:34:
          103|       # Re-call the function but with different arguments
          104|       overrideArgs = mirrorArgs (newArgs: makeOverridable f (overrideWith newArgs));
             |                                  ^
          105|       # Change the result of the function call by applying g to it

       … while calling a functor (an attribute set with a '__functor' attribute)
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/lib/customisation.nix:104:43:
          103|       # Re-call the function but with different arguments
          104|       overrideArgs = mirrorArgs (newArgs: makeOverridable f (overrideWith newArgs));
             |                                           ^
          105|       # Change the result of the function call by applying g to it

       … from call site
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/lib/trivial.nix:440:7:
          439|     { # TODO: Should we add call-time "type" checking like built in?
          440|       __functor = self: f;
             |       ^
          441|       __functionArgs = args;

       … while calling anonymous lambda
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/lib/customisation.nix:96:17:
           95|     in
           96|     mirrorArgs (origArgs:
             |                 ^
           97|     let

       … while evaluating a branch condition
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/lib/customisation.nix:108:7:
          107|     in
          108|       if isAttrs result then
             |       ^
          109|         result // {

       … while calling the 'isAttrs' builtin
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/lib/customisation.nix:108:10:
          107|     in
          108|       if isAttrs result then
             |          ^
          109|         result // {

       … from call site
         at /nix/store/mc6zz3405pw25x7h1xkhb2xx7a3a2kpm-source/lib/customisation.nix:98:16:
           97|     let
           98|       result = f origArgs;
             |                ^
           99|

       error: function 'anonymous lambda' called with unexpected argument 'ruby'
       at /nix/store/zpd0gmaic148sqyjn9f0ymsdk52ak9z9-source/packages/myNamespace/bundler.nix:1:1:
            1| {
             | ^
            2|   bundler,
```
