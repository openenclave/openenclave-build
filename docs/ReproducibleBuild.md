#  OpenEnclave Reproducible Build

## Motivation

OpenEnclave guarantees the protection of the confidential application from host inspection and interference. This makes 
it important that the confidential application represent the intention of the developer, and not contain malware 
introduced during the build process.

Malware can be introduced during the build process by:
- compilers and linkers that add malware code or gadgets into the object.
- libraries that contain malware code or gadgets.
- package systems that add malware packages as dependencies.
- the replacement of the target package in package and container repositories or content distribution nodes.

Defense against these threats involves the ability to verify binaries against a known sha256sum. To do this
we need a build process which produces bit-identical results each time the build is run against given source.

While apparently simple, existing toolchains do not automatically provide reproducibility.  In particular, 
- No compile time or date stamps
- No build paths imbedded in the binary. Note gnu ld automatically adds RPATH to binaries.
- All included libraries must be identical in each build. They must themselves 

These constraints dictate that builds should be performed in a container.

Using a docker container to do the build represents an additional threat. Since container images are fetched 
from network based repositories, those repositories can be penetrated or spoofed.  When containers are built,
a base image is specified in the "FROM" line:
```
from ubuntu:18.04
```
which specifies the image name and tag.  When this is all that is used, an infected repo will download a base image
into the image cache containing malware which producea result which propagates the malware into the secure application. 

To defend against this, later version of docker support specifying the container via a sha256 digest. This uniquely 
identifies the container by content so ensures a unique container. Even if the container repo has been corrupted, 
changing the contents of the container would result in a different sha256 digest.
```
from cdpxlinux.azurecr.io/global/ubuntu-1804-base@sha256:8ba2af654abb3290c92f6890591e4d8adee2a81dbf72f8eefc72f7a720ec3089
```
produces a safe fetch or will fail.

Once the container has been fetched, packages must be added to perform the build.  Ubuntu's aptitude package manager is 
designed to transparently add package dependencies from package repositories on the public network.  These repositories
can be spoofed or penetrated. Since the package dependencies are defined in a control file in the .deb file, the
package binaries need not be modified to introduce malware, as a dependency could be added to an otherwise untouched 
package which would run install scripts at root privilege. 

Even if the package is correct, it is not reproducible in that aptitude will install dependent packages that meet the 
requirements of the package, usually greater than or equal to a version, not a given version. So each package install
will produce a different set of packages as different packages are updated.

Once the build is completed, there is a customer requirement to be able to audit the build in terms of inputs, process,
and environment.  Aptitude defeats all of these, as well as reproducibility.

This gives the following set of threats and possible mitigatons.

Threat  | Mitigation
-------------------------------------------------
 Malware introduced by development tools  | Binary-exact reproducible build of new binaries
 Replacement of packages   |  Use only reproducible package system
 Spoofing or penetration of package repositories | Always compile in a container which is prebuilt and audited


## Requirements



## User Experience
---------------

What will the use of this look like?

Specification
-------------

What are the design details?

Alternatives
----------

What other designs were considered?

Why were they discarded in favor of this design?

Authors
-------

Who are you and how can we contact you in the future?
