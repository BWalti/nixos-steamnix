
# flake.nix
{
  description = "My configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; # IMPORTANT
  };

  outputs = { nixpkgs, chaotic, ... }: {
    nixosConfigurations = {
      gtr7pro01 = nixpkgs.lib.nixosSystem { # Replace "hostname" with your system's hostname
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          chaotic.nixosModules.default # IMPORTANT
        ];
      };
    };
  };
}

