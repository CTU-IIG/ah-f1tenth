{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    docker-compose
    mysql57

    # keep this line if you use bash
    bashInteractive
  ];
}
