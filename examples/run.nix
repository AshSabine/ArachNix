# nix-instantiate --eval --strict --json --extra-experimental-features pipe-operators examples/run.nix
(import ../nix { lib = import <nixpkgs/lib>; }).evalHarness [ ./poe-link.nix ]
