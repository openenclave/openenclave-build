ARG BASE_IMAGE="ubuntu@sha256:31dfb10d52ce76c5ca0aa19d10b3e6424b830729e32a89a7c6eee2cda2be67a5"
FROM $BASE_IMAGE

# The way to get a trusted build is to start with a trusted build. If we don't have one,
# we need to use untrusted components to perform the build, then rebuild with the provisionally trusted components, 
# then compare. If we get different contents, we don't know where the problem is, but we would know there is a problem.

# this can't come from a URL because it won't get unpacked. 
# We need a tight secure CDN to hold golden images. 
#
# Check the signature.

RUN apt-get update \
        && apt-get install -y curl python3 perl git \
        && mkdir -p /nix /etc/nix \
        && chmod a+rwx /nix \
        && echo 'sandbox = false' > /etc/nix/nix.conf \
        && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /output
#add a user for Nix
RUN adduser user --home /home/user --disabled-password --gecos "" --shell /bin/bash
CMD /bin/bash -l
USER user
ENV USER user
WORKDIR /home/user
# 
#create the shell config
RUN echo "{ pkgs ? import <nixpkgs> {} }: \n\
with pkgs; \n\
\n\
stdenvNoCC.mkDerivation { \n\
\tname = \"oe-build-nix\"; \n\
\tbuildInputs = [ \n\
\t\t/nix/store/idj0yrdlk8x49f3gyl4sb8divwhfgjvp-libtool-2.4.6 \n\
\t\t/nix/store/68yb6ams241kf5pjyxiwd7a98xxcbx0r-ocaml-4.06.1 \n\
\t\t/nix/store/ncqmw9iybd6iwxd4yk1x57gvs76k1sq4-ocamlbuild-0.12.0 \n\
\t\t/nix/store/9dkhfaw1qsmvw4rv1z1fqgwhfpbdqrn0-file-5.35 \n\
\t\t/nix/store/vs700jsqx2465qr0x78zcmgiii0890n3-cmake-3.15.5 \n\
\t\t/nix/store/d0fv0g4vcv4s0ysa81pn9sf6fy4zzjcv-gnum4-1.4.18 \n\
\t\t/nix/store/ljvpvjh36h9x2aaqzaby5clclq4mgdmc-openssl-1.1.1b \n\
\t\t/nix/store/0klr6d4k2g0kabkamfivg185wpx8biqv-openssl-1.1.1b-dev \n\
\t\t/nix/store/yg76yir7rkxkfz6p77w4vjasi3cgc0q6-gnumake-4.2.1 \n\
\t\t/nix/store/1kl6ms8x56iyhylb2r83lq7j3jbnix7w-binutils-2.31.1 \n\
\t\t/nix/store/dmxxhhl5yr92pbl17q1szvx34jcbzsy8-texinfo-6.5 \n\
\t\t/nix/store/g6c80c9s2hmrk7jmkp9przi83jpcs8c6-bison-3.5.4 \n\
\t\t/nix/store/qh2ppjlz4yq65cl0vs0m2h57x2cjlwm4-flex-2.6.4 \n\
\t\t/nix/store/6a6ilqysgz1gwfs0ahriw94q35vj84sy-vim-8.2.1123 \n\
\t\t/nix/store/z2709nq2dfbmq710dyf8ykjwsj3zk3ld-libffi-3.3 \n\
\t\t/nix/store/86832i5kfv4yyzj9y442ryl4l1s4wrwj-libpfm-4.10.1 \n\
\t\t/nix/store/fhsjz6advdlwa9lki291ra7s5aays9f9-libxml2-2.9.10 \n\
\t\t/nix/store/ki8k1a2pkpf862pxa0pms0j9mwjcb2xd-zlib-1.2.11-dev \n\
\t\t/nix/store/rcn31jcz3ppnv28hjyq7m2hwy4dqc2jb-clang-7.1.0-lib \n\
\t\t/nix/store/sc35z1gh4y58n2p0rz9psi33scwh4nv2-llvm-7.1.0 \n\
\t\t/nix/store/8inh7bv9hnyjdmrviimmwcw4vr8c6pji-llvm-binutils-7.1.0 \n\
\t\t/nix/store/jzgz21bgily2g8j8nnx04zv5y69rld6f-clang-7.1.0 \n\
\t\t/nix/store/0iz74aawxl3gfyqkxygy43bw9zzl0jkb-musl-1.2.0-dev \n\
\t\t/nix/store/pvr7va4221w3fyya7lm6cxh5601fbdsa-valgrind-3.16.1-dev \n\
\t\t/nix/store/q13zmpbw9pmx32pcxjc9wr7c6qsk1nkl-valgrind-3.16.1-doc \n\
\t\t/nix/store/sn9i6iigyp58r4w7556c8p36xlm6hr2m-valgrind-3.16.1 \n\
\t\t/nix/store/spah9k7ald89hwhngg3zmvx6kqlbq218-doxygen-1.8.19 \n\
\t]; \n\
\n\
\tshellHook = '' \n\
\techo \"OpenEnclave build enviroment\" \n\
\t''; \n\
} \n\
" > /home/user/shell.nix

#install the required software
RUN touch .bash_profile \
&& curl https://nixos.org/releases/nix/nix-2.2.1/install | sh \
&& . /home/user/.nix-profile/etc/profile.d/nix.sh \
&& nix-env -i /nix/store/idj0yrdlk8x49f3gyl4sb8divwhfgjvp-libtool-2.4.6 \
&& nix-env -i /nix/store/68yb6ams241kf5pjyxiwd7a98xxcbx0r-ocaml-4.06.1 \
&& nix-env -i /nix/store/ncqmw9iybd6iwxd4yk1x57gvs76k1sq4-ocamlbuild-0.12.0 \
&& nix-env -i /nix/store/9dkhfaw1qsmvw4rv1z1fqgwhfpbdqrn0-file-5.35 \
&& nix-env -i /nix/store/vs700jsqx2465qr0x78zcmgiii0890n3-cmake-3.15.5 \
&& nix-env -i /nix/store/d0fv0g4vcv4s0ysa81pn9sf6fy4zzjcv-gnum4-1.4.18 \
&& nix-env -i /nix/store/ljvpvjh36h9x2aaqzaby5clclq4mgdmc-openssl-1.1.1b \
&& nix-env -i /nix/store/0klr6d4k2g0kabkamfivg185wpx8biqv-openssl-1.1.1b-dev \
&& nix-env -i /nix/store/yg76yir7rkxkfz6p77w4vjasi3cgc0q6-gnumake-4.2.1 \
&& nix-env -i /nix/store/1kl6ms8x56iyhylb2r83lq7j3jbnix7w-binutils-2.31.1 \
&& nix-env --set-flag priority 10 binutils-2.31.1 \
&& nix-env -i /nix/store/dmxxhhl5yr92pbl17q1szvx34jcbzsy8-texinfo-6.5 \
&& nix-env -i /nix/store/g6c80c9s2hmrk7jmkp9przi83jpcs8c6-bison-3.5.4 \
&& nix-env -i /nix/store/qh2ppjlz4yq65cl0vs0m2h57x2cjlwm4-flex-2.6.4 \
&& nix-env -i /nix/store/6a6ilqysgz1gwfs0ahriw94q35vj84sy-vim-8.2.1123 \
&& nix-env -i /nix/store/z2709nq2dfbmq710dyf8ykjwsj3zk3ld-libffi-3.3 \
&& nix-env -i /nix/store/86832i5kfv4yyzj9y442ryl4l1s4wrwj-libpfm-4.10.1 \
&& nix-env -i /nix/store/fhsjz6advdlwa9lki291ra7s5aays9f9-libxml2-2.9.10 \
&& nix-env -i /nix/store/ki8k1a2pkpf862pxa0pms0j9mwjcb2xd-zlib-1.2.11-dev \
&& nix-env -i /nix/store/rcn31jcz3ppnv28hjyq7m2hwy4dqc2jb-clang-7.1.0-lib \
&& nix-env -i /nix/store/sc35z1gh4y58n2p0rz9psi33scwh4nv2-llvm-7.1.0 \
&& nix-env --set-flag priority 10 llvm-7.1.0  \
&& nix-env -i /nix/store/8inh7bv9hnyjdmrviimmwcw4vr8c6pji-llvm-binutils-7.1.0 \
&& nix-env -i /nix/store/0iz74aawxl3gfyqkxygy43bw9zzl0jkb-musl-1.2.0-dev \
&& nix-env -i /nix/store/jzgz21bgily2g8j8nnx04zv5y69rld6f-clang-7.1.0 \
&& nix-env -i  /nix/store/pvr7va4221w3fyya7lm6cxh5601fbdsa-valgrind-3.16.1-dev \
&& nix-env -i  /nix/store/q13zmpbw9pmx32pcxjc9wr7c6qsk1nkl-valgrind-3.16.1-doc \
&& nix-env -i  /nix/store/sn9i6iigyp58r4w7556c8p36xlm6hr2m-valgrind-3.16.1 \
&& nix-env -i  /nix/store/g4ihsbcnxgsdy4h05s7iiwxcjjydpsyj-python3-3.9.0b5 \
&& nix-env -i /nix/store/spah9k7ald89hwhngg3zmvx6kqlbq218-doxygen-1.8.19



#config nix-shell
RUN . /home/user/.nix-profile/etc/profile.d/nix.sh \
&& nix-shell
