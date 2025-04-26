{
  description = "Stig's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixos.url = "github:NixOS/nixos-hardware/master";
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;                                                         
      pkgs = nixpkgs.legacyPackages.${system};
    in 
    {
      nixosConfigurations = {
        iso = nixpkgs.lib.nixosSystem {
          inherit system;
		  specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            home-manager.nixosModules.home-manager {
              home-manager = {
                backupFileExtension = "/tmp/${toString self.lastModified}.bak";
                useGlobalPkgs = true;
                useUserPackages = true;
                # users.stig = {
                #  home.stateVersion = "25.05";
                # };
              };
            }
          ];
        };
        
        homeConfigurations.stig = home-manager.lib.homeManagerConfiguration  {
          modules = [ 
            ./home.nix 
          ];
        };
      };
    };
}
