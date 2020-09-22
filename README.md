# openenclave-build
Reproducible &amp; secure build resources for Open Enclave

## Overview

The software build process is vulnerable to attacks on the build os, toolchain and package dependencies used 
in the construction of a software product (for example, the openenclave SDK) .

An example of the attacks possible, 
- The OS distro install media itself can be compromised. This happened in 2016 with Linux mint. It took several 
  weeks to recognise the problem.
- Package repos can be compromised. This has happened with several distros and can be very difficult to detect.
- Package repos can be dns spoofed. allowing man in the middle attacks where compromised packages are introduced into
  the build host.
- Compilers and linkers can be modified to emit either malware directly, or insert known gadgets at known addresses 
  for later exploit.

To address these vulnerabilities, we propose the use of a secure build.

A secure build is:
- Reproducible, which is to say the bit-exact same binary is produced whenever a given source version
  is built. As a result, packages and files can be verified against known sha256sums to verify the build results.

- Auditable, which is to say that all of the dependencies of the build are identifiable within the build process.
  This allows those dependencies to be archived and the package to be rebuilt exactly and the package components
  audited for security vulnerabilities.

- Network hardened, which is to say that use of the network is avoided in favour of local resources, and that 
  any information passed over the network is built in such a way that it can be verified after receipt.

In every case, intrusion detection is very important. If an intrusion can be promptly observed, countermeasures
can be deployed before information is compromised. Promptly detecting intrusions is a powerful deterrent to 
further attempts, and deterrence is vital.  Ultimately it is not possible to have a system which is 
completely unbreakable. There are always holes, but if you can see the intrusion it can be mitigated.

## How to achieve a secure build?

The first level of security is reproducibility. To acheive this we must ensure the integrity of the package 
system, and it is here that both of the dominant flavours of linux (debian/ubuntu/mint and redhat/fedora/centos) 
package systems simply fail.

In order to acheive reproducibility, the component packages linked into the target binaries must also
be reproducible. Debian at least tried this by aiming to publish buildinfo files which characterised the 
binary signature of each of the debian packages, which were themselves reproducibly built. This effort lasted 
for about two years, and has seemed to become less of a priority recently.  At no point were buildinfo 
files consistently generated nor made available.  The high water mark appears to have been 90% of packages 
built reproducibly in 2018 with the number falling since.

Without 100% reproducibility of the components aptitude and yum will not allow a consistently reproducible 
result, since the automatically fetch dependencies of the installed packages, which in turn fetch 
their dependencies, etc.

This can be handled by using only the basic packaging tools (dpkg and rpm) building infrastructure to measure and 
detect dependencies in the base packages, but a better alternative has appeared in the form of the nix package 
manager.

### Nix
Nix.org is an organisation dedicated to reproducible building.  The nix offerings are a package system, and 
a set of packages which together implement a fairly complete linux distro referred to as NixOS. It is also entirely
practical to use the package manager and its associated packages in a more conventional build role.

Functionally, nix fulfills some of the functions of a container system  in that it enforces visibility during the build
to only those build inputs that have been declared in the derivation for the package to be built. It also overlaps
the functionality of procedural build systems like maven or gradle, but does not attempt to replace the basic build 
system such as cmake, ninja or make.

The infrastructure of the nix package system includes the package repository (nixpkgs) which is structured as a git repo.
Forking and cloning the repo provides a local repository of buildable derivations, nix terminology for package build 
instructions. The nix package repo either outright builds the packages or retrieves them from a designated cache, either
the global default (cache.nix.org) or any other cache location with an instance of nix-serve. The cache location is specified  
in a host-level configuration file. As a result, the package fetch repositories are able to be transparently localised
to trusted resources and networks, or completely isolated to no network at all.

The working state of the nix environment is kept in the global directory /nix/store. This store is unique per host, 
but may be shared using nix-serve as a proxy. /nix/store contains both the built working versions of the package dependencies
and the package under construction as well.

When the package has been built, it can be added to the nixpkgs repo fork, and pushed. It can then be added to the central nix
repo via a pull request. So package builts are themselves the basis for further package builds using the local, forked
repo.  Unlike aptitude or yum, it is straightforward to release a given package, which is permanently unique, and what 
the scope and visibility of that release will be.

All nix derivations are stored via a series of attributes (such as name "openenclave-sdk", version "1.6.7") and a sha256
digest based on the the package and all of its dependencies. As a result, changing any of the dependencies will change the
retrieval key of the package, and packages depending on the previous version will not be affected. When a given version of 
the package is retrieve it will always have the same contents. Nix package manager automatically verifies the sha256sum 
every time the package is used. If there is any change, the package will not be downloaded.

### Nix and Docker
Nix works well with docker containers if the necessary bind volumes are passed, or if the container copies the
build result to an external directory.  The most complete results 






