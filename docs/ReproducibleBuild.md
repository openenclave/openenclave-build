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

## Requirements

- Bit exact reproducible build of all binaries and composite objects (.deb, .rpm)
- Build base container containing needed packages via auditable package system (ie nix) base on container specified
  with sh256digest.
- Auditability of source input, In-Container OS environment, package management and package inputs.
- Separation of build base container and build process. All artifact fetches occur in the build base container
  and that container can be audited.
- Build base container has all prerequisites. Complete separation between build process and network artifact fetches.
- Builds once performed should upload signature to known signature repositories. Need a verification tool to verify the signatures
  of builds performed.
- Can be applied to OpenEnclave without requiring internal modifications of its build system.
- Can be reused in building other OpenEnclave based builds with modifications.

## Non Requirements

- Build container update process should eventually be completely automated, but need not be. Notionally, the build
  base container would be update a few times per year unless there were specific high priority fixes required. Either
  way, the building of the base container.

- The Build base container need not be built under a specific build pipeline.

- Better to have a simple system that can be eventually expanded than a complex system that creates problems. No attempt to 
  produce a general "reproducible build engine".


## User Experience
---------------

### Build Base Image Construction

This is done once and only repeated if there are critical updates required to the build image. The bootstrap image will be loaded with all packages, for development toolchains, libraries and utilities required to build the project and then pushed to a 
private docker repository.
```
sudo ./build_bootstrap.sh /home/azureuser/tmp/output cdpxlinux.azurecr.io/global/openenclave-repro-build-base  "cdpxlinux.azurecr.io/global/ubuntu-1804-base@sha256:8ba2af654abb3290c92f6890591e4d8adee2a81dbf72f8eefc72f7a720ec3089"
```
Running the script will produce a filled build-base docker image which is then pushed to the repo specified 
via the second parameter and leave a script and dockerfile for performing the project build in the directory 
specified by the first parameter, so the contents of the output directory will be:
```
ls
project_build.sh
project.dockerfile
```
The third parameter specifies the sha digest of the base image used to construct the build base.

The script will perform a push to the desired local, private or secure repo,

```
sudo docker commit docker commit candidate:latest openenclave-repro-build-base
sudo docker push  cdpxlinux.azurecr.io/global/openenclave-repro-build-base
```

After the docker container is successfully pushed, the sha256 digest is visible via 
```
docker inspect 05eb7d9ba38b 
```
where the argumnent to docker inspect is the image id value given by 
```
docker images
```

`docker inspect` will return much data, but the interesting part is near the head of the output.
```
[
    {
        "Id": "sha256:05eb7d9ba38b76838b43a4778f0cb0f37a178f627dcea80f8e622a5209a6af1e",
        "RepoTags": [],
        "RepoDigests": [
            "cdpxlinux.azurecr.io/global/ubuntu-1804-base@sha256:8ba2af654abb3290c92f6890591e4d8adee2a81dbf72f8eefc72f7a720ec3089"
        ],
        "Parent": "",
        "Comment": "",
        "Created": "2018-05-10T23:33:29.814299323Z",
        "Container": "9033bd22993629783e9c8691d2307617fc85805d5c0e035d9a186754c939f62d",
        "ContainerConfig": {
            "Hostname": "",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "DEBIAN_FRONTEND=noninteractive"
            ],
            "Cmd": [
                "/bin/sh",
                "-c",
                "update-ca-certificates"
            ],
...
```

The generated project build script will use the repo digest to specify the image to use. This should be unique and 
unreplaceable even if the image repostory is pentrated.  If such an even occurs, the image will be rejected by 
docker (containerd) and it will be obvious there is an issue.

### Project Build

When the are built, the project build script and dockerfile are copied to the project build environment, for example 
to an ADO or CPDX pipeline repo or jenkins server.  The contents of project_build.sh will possibly need modification to 
fit the target environment.

### At Install of the built project

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
