# Attested Building

### Motivation

In Feb 2018, the Mint Cinnamon 17.3 build was attacked by replacing the binary with a modified version which installed 
a backdoor in all machines that updated using that image. The attack was detected within a few days, but it demonstrated
open source's vulnerability to this kind of attack. This is especially disturbing in the context of SGX and TrustZone enclaves 
in which the host CPU's ability to scan and remove any malware that makes it into the trusted execution environment is 
by design essentailly unreachable from the host OS.

Another avenue of attack can be the building tools themselves. If the build tools (compilers, linker, run time libraries )
are corrupted, they can insert malicious code into the build binaries. 

Awareness of vulnerabilities in turn has lead to the search for ways to improve the resiliency of the building processes
against attack, especially the ability to detect corrupted sources, binaries, or build process.  The organisation
[reproducible-builds.org](https://reproducible-builds.org/ ) is working to foster and awareness and pool resources
in the area of improved build process security. Its focus is providing tools and knowlege about reproducible building, where 
each build process produces a bit-exact set of binaries, which can then be checksummed and the checksum verified when the 
binary is downloaded.  If there is a difference between the reference checksum and the checksum produced from the binary, 
the data is corrupted. In the build processes, rebuilding a source package of known output similarly can verify the 
trustworthiness of the development tools.

### Trustworthy Building
A trustworthy build is 
#### Reproducible
Each iteration of the build produces the same bits, which can be checksumed usung sha256sum. Various building
habits can frustrate this, such as compiling date time stamps and build paths into the binary. In some cases this is
default behaviour for the 

#### Verifiable

Each build should verify the legitimacy of the toolchain, OS, 

#### Adaptable

The attested build process should be designed to apply to as wide a range of project builds as possible. 

#### Affordable

All of this needs to be done at reasonable cost in build time and engineering hours. 




