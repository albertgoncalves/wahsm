with import <nixpkgs> {};
mkShell {
    buildInputs = [
        clang-tools
        htmlTidy
        python38
        shellcheck
        wabt
    ];
    shellHook = ''
        . .shellhook
    '';
}
