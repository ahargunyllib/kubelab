{
  description = "kubelab's nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = import nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };
  in
  {
    devShells."aarch64-darwin".default = pkgs.mkShell {
      packages = [
        pkgs.terraform
        pkgs.ansible
        pkgs.awscli2
      ];
    };
  };
}
