{ pkgs ? import <nixpkgs> {} }: 


pkgs.mkShell { 
	name = "oe-build-nix"; 
	buildInputs = with pkgs;  [ 
		pkgs.openssl
		pkgs.cmake
		pkgs.llvm
		pkgs.clang
                pkgs.python3
	]; 


        shellHook = ''
         export CC=clang;
         export CXX=clang++;
         export LD=ld.lld;
         export CFLAGS="-Wno-unused-command-line-argument"
         export CXXFLAGS="-Wno-unused-command-line-argument"
         rm -rf build/*
         rm -rf openenclave
         git clone --recurse-submodules https://github.com/openenclave/openenclave.git
         mkdir /output/build
         cd /output/build
         cmake -G "Unix Makefiles" ~/openenclave -DCMAKE_BUILD_TYPE=RelWithDebInfo 
        '';
} 

