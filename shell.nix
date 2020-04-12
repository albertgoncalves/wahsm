with import <nixpkgs> {};
llvmPackages_10.stdenv.mkDerivation {
    name = "_";
    buildInputs = [
        htmlTidy
        python38
        shellcheck
        wabt
    ];
    shellHook = ''
        . .shellhook
    '';
}
