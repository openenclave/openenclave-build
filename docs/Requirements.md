# openenclave-build
Reproducible &amp; secure build resources for Open Enclave

## Problem

### Software Supply Chain Safety
One of the possible avenues of attack in a software system is to add malware during the build process by hijacking the build and distribution process.
This can occur in several ways:
- The distro image can be compromised.
- The package system can be compromised
- The docker repo can be compromised
- The development toolchain can be compromised.

#### The distro image can be compromised.
This has happened when the .iso of linux mint was compromised in 2016. The distro was compromised with a backdoor,  
so anyone who installed from that iso would unwittingly set up a vulnerable system, even if the system had every security 
feature enabled, it would still be vulnerable, and that vulnerability woul be virtually undetectable..

#### The package system can be compromised
The aptitude (debian, ubuntu, mint), yum (redhat, fedora, centos), and other package systems can be penetrated at the repo, or 
man in the middle attacks which redirect requests to malware laden packages, depending on the system.  Detection of these problems
can be complicated by embedding malware packages into the dependencies of the target package rather than including malware 
in the binary as such.

#### The docker repo can be compromised
Dockerhub represents a high value target for attack, and has been penetrated in the recent past.. In such a case,
 a docker image for say, ubuntu can be set up with the desired malware, backdoors, etc. Then any docker image based
on that image for example:
```
    using ubuntu-18.04
```
will include the malware. This will be true even after the original malware is detected and removed unless all traces of the image are removed from the cache and the image is rebuilt.
This problem can be mitigated by including the container's sha256 digest but that digest isn't generated until the container image 
has been added to the repo.

#### The development toolchain can be compromised.
The toolchain itself can be modified to embed malware within the code.  In such a case, all software generated
by the toolchain will probably contain the malware.  Control of such trojan horses can occur be unconditional, or
controlled by system configuration or environment. 

## Requirements: secure build environment

##### Requirements:

#### Security Environment Security Guarantees:

#### Threat Environment:
- The Host OS should be viewed as always insecure.
- The open network should be viewed as always insecure. Artifacts Fetched from host files or private network 
  should only be trusted after measurement from two trusted measurement archives verifies their identity.
- A container should only be considered secure if it is fetched with the sha256digest. The assumption there is
  that the digest cannot be reproduced and guarantees the contents. A hacked repo will not be able to reproduce 
  the specified container.
- Since the open network is insecure, package systems that fetch packages and their dependents over the open network
  are insecure. Package systems can only be considered secure if packages can be fetched using a sha256 digest. Like
  containers, the assumption is the digest cannot be easily reproduced.
- Development tools (compilers, linkers, libraries) are a potential attack vector and should be checked before usei
  in the build. Once in the container, they are considdered secure.
- Project source from the github repo is not reliably fetched from the open network, but the only defense is to retain
  the code for future audit.

##### - Secure:
  The build should be based on docker containers, which allows operating system environmental factors to be isolated 
  even if the build machine has been compromised. All needed packages and other resources should be pre-added to 
  that container. Containers should always be referenced using the sha256 digest in the using clause.

  The container repo should be local to the build machine or build environment. The general network should be viewed as 
  insecure in all cases.  The build host should be viewed as insecure in all cases.
  
  The development tools should be built from source and checked for specfic output before inclusion.

##### - Reproducible:
  Each build should produce the exact same binaries as indicated by a sha256 sum. Any changes in the 
  result should come from external parameters or intentenoinal, logged changes.
##### - Auditable:  Every input to the build environment can be identified and verified back to the original source.
Every step in the build process is logged in a signle, central log which can be archived.
- Detectible: Penetration can be detected if it occurs.
- Adaptible:  The same infrastructure can be retargeted to multiple projects with minimal modification.

It need not be:
- Completely general. It should be possible to adapt the container


## Solution

#### Reproducibility

A reproducible build will produce the same binary result every time a given set of source is built. To achieve reproducibility 
it is necessary to have source that follows reproduciblble rules, like no embedded build paths or date-time stamps, 
and a toolchain that also produces consistent results, for example some linkers embed RPATH data into binaries while, 
for example, llvm does not do so by default.  In cases where tools can produce a reproducible build, the build process itslf,
(cmake files, makefiles, autogenerated build files) must also support the reproducibility.

Once you have a reproducible build, you can efficiently track changes in binaries by taking a sha256sum of each binary
and comparing against known results.  Even if you have no known results, you can use differing versions of the toolchain 
to verify that the source is being faithfully built. 

The most useful example of this is in using the toolchain to generate the toolchain.  Building the toolchain with another tool, 
then using that version to build the toolchain again will establish that no hidden code is being inserted into the build
by the toolchain.


#### Auditability

An auditable build enviornment onains nothing that cannot be explicitly accounted for.

Containers allow the host system environment and configuration to be isolated from the developement or build host OS,
packages and environment.  This benefit comes with a risk if the container is based on a parent image, but we can use 
```
    from scratch
```
images in order to greatly reduce that risk. from-scratch images have a zero-sized base layer which is not served by
the docker repo. The only data in the container is placed there in the process of building.  So, a tar file containing
a base OS image is required. If this file is signed and verified, the contents of the container can be considered 
trusted until the package system is brought into the picture.

In order to actually perform a build of the target system, including toolchain, a number of packages must be
installed into the base container image. Exactly which packages becomes difficult to ascertain because modern package
system install not only the packages explicily requested, but dependent packages. This behaviour makes audibility dfifficult, 
but it is possible to restore auditability by using the base package system (ie dpkg) to install packages individually. 

#### Detectability

Since the standard repos are viewed as insecure by the build, we get packages from content distribution nodes (CDN).
These nodes can themselves be penetrated, but the packages are measured (using sha256sum) and comparing sha256sums will 
detect whether the package downloaded is the package you want, or whether it has been substituted. Signatures 
and sha256sums are a normal feature of any download process, but the flaw in the usual implementation is the storage 
of the measurement on the same server as the data, so that an intruder can prevent detection by substituting a 
new measurement along with the new data.

To prevent this, the measurement should be stored in a different location from the data, possibly in multiple 
locations. In such a case, modified data will be immediately detected unless all of the measurment locations are also 
compromised.  So long as even one measurment avoids modification, at least the build will know that something is wrong.

In addition to helping mitiage intrusions, detectability also deters attacks. If there is a good chance a penetration
will be detected and reversed, there is far less incentive to commit the attack in the first place.


## Secure Build

### Base Image Considerations

A secure build can only be as secure as the OS image.  The trusted code base of a usable distro is sufficiently 
large to make a custom security audit of the code impractical. To mitigate this, the secure build is based on a 
minimmum version of ubuntu linux 18.04. Ubuntu is the most common and best supported version of linux, therefore 
the most likely to have vulnerabilities detected promptly. A set of packages is separately installed, which limits
code base to those packages and the base image. Currently we use packages from standard aptitude repos, but only at
base image contruction.  This image is held stable until a security problem is detected or the affected packages 
become obsolete.  While he distro packages are not an active part of the trusted toolchain it is important that 
all utilities be of secure provenence.

### The Trusted Toolchain

The toolchain chosen is LLVM7.1.0, which is built to use the llvm runtime, linker and archive tools built via 
the trusted troolchain. This toolchain is chosen because it clearly supports reproducible builds.

The trusted toolchain is built in three phases:
- Build the toolchain from trusted archived sources using the gcc toolchain as a bootstrap.
- Use that toolchain to build the trusted toolchain with the trusted runtime.
- Use that toolchain to rebuild the trusted toolchain with the trusted runtime.
- Compare the sha256sums for last two versions of the toolchain.  This will verify the toolchain is producing the 
  same code and is free of code insertions.

The process of building the llvm toolchain and runtime three times is fairly time consuming. In order to 
mitiage this the built image is saved as a tar file and uploaded.  We do not simply build a package because the 
entire trusted build environment container including utilities, installed packages, environment variables and configuration files
must be reproduced for a secure result. 


### Integration with cloud build platforms

#### Jenkins

TBD

#### Cloud Build Pipeline, Extended (CPDx)

TBD

### Workflow

##### Build the package tar.

Aptitude does automatic installation of dependent packages. In normal life this is highly desirable, since it allows us to ignore a 
very complex set of package dependencies. In a high security environment, aptitudes's automatic installation of unnamed
packages defeats auditability and creates a vulnerability. 

The vulerability created is that a package can be modified to change its dependencies, then uploaded. The binaries 
in the package will be unaffected, and the binaries sha256sum will be unaffected, but installing the modified package would also install 
additional code at superuser privelege. 

But the fact remains that the packages required to build a substantianal project have complex dependencies between hundreds
of packages. The secure-build approach to this problem is to use aptitude to load the required packages, then save those packages 
in a tar file, and use a package list to specify the order of installation to satisfy the dependency tree.  The packages_list
file is then added to the bootstrap image, as is the packages tar. 

In this way, we decouple the secure build from the aptitude package system and restore auditability, since the package list and the 
binary packages are clearly auditable.

##### Build the bootstrap image and toolchain

We assume that the docker repo is hackable.  As a result, any image that depends on another docker image ("from ubuntu:18.04"
in the dockerfile) is subject to unverifiable intrusions. So we use scratch containers and load the ubuntu base image from a
tar file.  We then load the package tar and use dpkg to install the package set. Finally we build a trusted toolchain, then build again 
and compare. This process is time consuming, and very much something we can do one only occasionally. If we had to do it with 
every project build the resulting overhead would be untenable, but if we do it once, then save it in docker cache or tar file, we 
can amortise that cost over many builds. 

Once we have a trusted bootstrap image, we can now use the trusted toolchain to build the project.

##### Build the project

A key feature of the project build is that it does not download anything but source. It may place files or install packages (via dpkg) 
but it does not download or build anything other than the target project source. The project build may do this because the bootstrap 
image has pre-placed the files to be installed. Secure build aims to be retargetable to many projects, but the requirements for packages
in the build environment is limited to a finite list. Currently, the package list for the base image is sufficient to build the 
openenclave SDK. We expect that additional packages required for additional target projects will need to be added over time, but 
the list will rapidly converge.

Each project requires a project Dockerfile, and script to do the docker build/run/commit, and a script to do the project
source download/build process. We are keeping the project build files in the openenclave-build repo.


#### Building the Package Tar

The package tar allows the efficient verification of .deb packages bypassing the standard package repos. The tar contains all 
packages required to be installed for building the bootstrap image and toolchain, plus others required for building openenclave.

The package tar is built using packages installed via the apt package system. This vulnerability is mitigated by occuring only at
one point in time. 


The package tar is used in the creation of the bootstrap image. It is served from a secure content distribution node 
protected by a secure access key.  The output of the package tar build is placed in the directory mounted on 
the containers /output directory. 
```
sudo ./build_ppackages.sh
```
Produces the files  secure-build.pkgs.tar.gz and secure-build.pkgs.tar.gz.sha256sum.  These are manually uploaded to the 
CDNs https://oedownload.blob.core.windows.net/oe-build (data) and https://oebuildinfo.blob.core.windows.net/buildinfo (sha256sum).


#### Building the bootstrap image and toolchain

The bootstrap image is built using 
- CDN-served ubuntu base image tar file
- package tar
- CDN served llvm source tar files.

Each piece is loaded using an access key from a secure CDN, along with its signature from a separate CDN. The tar files are 
validated and unpacked. Running image using the shell script /tmp/build_toolchain.sh with create the build. Then the image is commited 
and saved as a docker tar.gz file, measured and a sha256sum generated.

The bootstrap image is created using the script
```
sudo ./build_bootstrap.sh /home/azureuser/tmp/output
```
The generated bootstrap image is placed in the docker cache as the image "candidate:latest".

Depending on the level of trust in the docker repo you can retag the bootstrap image to secure-build-bootstrap:latest, or 
```
sudo docker save candidate -o /tmp/secure-build-bootstrap.tar
sudo gzip /tmp/secure-build-bootstrap.tar
```
and upload to a trusted CDN in order to integrate the bootstrap image into your project pipeline.

#### Building the project.




# Contributing

This project welcomes contributions and suggestions. Most contributions require you to
agree to a Contributor License Agreement (CLA) declaring that you have the right to,
and actually do, grant us the rights to use your contribution. For details, visit
https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need
to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the
instructions provided by the bot. You will only need to do this once across all repositories using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
