{
  description = "Open Cyber Threat Intelligence Platform";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/release-21.05";
    opencti-src = { url = "github:OpenCTI-Platform/opencti"; flake = false; };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, opencti-src }:
    (flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlay
            ];
          };
        in
        {
          defaultPackage = pkgs.opencti-front;
          packages = {
            inherit (pkgs)
              opencti-front
              opencti-graphql
              ;
          };
        }
      )
    ) // {
      overlay = final: prev: {
        opencti-graphql = prev.mkYarnPackage rec{
          name = "opencti-graphql";
          packageJSON = opencti-src + "/opencti-platform/opencti-graphql/package.json";
          src = opencti-src + "/opencti-platform/opencti-graphql";
          #yarnLock = opencti-src + "/opencti-platform/opencti-graphql/yarn.lock";
          yarnLock = ./opencti-graphql/yarn.lock;
        };

        opencti-front = prev.mkYarnPackage rec{
          name = "opencti-front";
          packageJSON = opencti-src + "/opencti-platform/opencti-front/package.json";
          src = opencti-src + "/opencti-platform/opencti-front";
          #yarnLock = opencti-src + "/opencti-platform/opencti-front/yarn.lock";
          yarnLock = ./opencti-front/yarn.lock;
        };
      };
    };
}
