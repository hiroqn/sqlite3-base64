{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) stdenv sqlite libb64;
      in
      rec {
        devShell = pkgs.mkShell {
          buildInputs = [
            packages.sqlite
          ] ++ packages.default.buildInputs;
        };
        packages.default = stdenv.mkDerivation {
          name = "sqlite3-base64";
          src = self;
          buildInputs = [ sqlite.dev libb64 ];
          NIX_CFLAGS_COMPILE = "-isystem ${libb64}/include/b64 ";
          buildPhase = ''
            $CC -fPIC -shared sqlite3_base64.c -lsqlite3 -lb64 -o libbasesixtyfour.so
          '';
          installPhase = ''
            install -D libbasesixtyfour.so $out/lib/libbasesixtyfour.so
            ln -s $out/lib/libbasesixtyfour.so $out/lib/libbasesixtyfour.dylib
          '';
        };
        packages.sqlite3-base64 = packages.default;
        packages.sqlite = pkgs.sqlite.overrideAttrs (final: prev: {
          src = pkgs.fetchurl {
            url = "https://sqlite.org/snapshot/sqlite-snapshot-202302052029.tar.gz";
            sha256 = "sha256-MNjujQGJ/QlKs/3gUGna2G6Fmc/gAZ4qxmXflWH5DH0=";
          };
          buildInputs = prev.buildInputs ++ [ pkgs.libb64 ];
          NIX_CFLAGS_COMPILE = prev.NIX_CFLAGS_COMPILE + " -DSQLITE_CORE=1 -lb64 -isystem ${pkgs.libb64}/include/b64 -DSQLITE_SHELL_EXTSRC=${self}/sqlite3_base64.c -DSQLITE_SHELL_EXTFUNCS=BASESF";
        });
        defaultPackage = packages.default;
      });
}
