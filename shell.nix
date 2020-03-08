with import <nixpkgs> {};
mkShell {
    buildInputs = [
        clang-tools
        htmlTidy
        shellcheck
        wabt
    ];
    shellHook = ''
        . .shellhook
    '';
}
