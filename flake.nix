{
  description = "Vtuberous NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hycov = {
      url = "github:DreamMaoMao/hycov";
      inputs.hyprland.follows = "hyprland";
    };
    hyprfocus = {
      url = "github:VortexCoyote/hyprfocus";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = {self, nixpkgs, unstable, home-manager, ... } @ inputs : {
    nixosConfigurations = {
      vtuberous = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
          inherit unstable;
          inherit inputs;
        };
        modules = [ 
          ./configuration.nix
          home-manager.nixosModules.home-manager {
            home-manager.useUserPackages = true;
            home-manager.useGlobalPkgs = true;
            home-manager.users.kaigyo = {
              home.file.".config/hypr" = {
                source = ./home/.config/hypr;
                recursive = true;
              };
              home.file.".config/swww" = {
                source = ./home/.config/swww;
                recursive = true;
              };
              home.stateVersion = "23.11"; # The state version is required and should stay at the version you originally installed.
            };
          }
        ];
      };
    };
  };
}