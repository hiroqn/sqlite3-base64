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
            sqlite
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
        packages.sqlite = pkgs.sqlite;
        defaultPackage = packages.default;
      });
}
