import BuildInfo
import hashlib
import os
import platform

info = BuildInfo.BuildInfo()

def get_deb_packages():
    rslt = os.popen('dpkg -l').read()
    slist = rslt.split('\n')
    return slist[5:]

def checksum_file(filename):
    sha256_hash = hashlib.sha256()
    file_bytes = 0
    f = open(filename,"rb")
    # Read and update hash string value in blocks of 4K
    for byte_block in iter(lambda: f.read(4096),b""):
        sha256_hash.update(byte_block)
        file_bytes += len(byte_block)
    return BuildInfo.Checksum(os.path.basename(filename), file_bytes, sha256_hash.hexdigest())

def __init__(filename, src, binary, contains_files=[]):
    #
    info.src    = src
    info.binary = binary
    info.build_arch = platform.machine()
    for f in contains_files:
        info.checksums.append(checksum_file(f))
    #
    pkg_str_list = get_deb_packages()
    pkg_list = []
    for pkg in pkg_str_list:
        pkg = pkg.split(None, 4) 
        #
        if len(pkg) > 3:
            pkg_list.append(BuildInfo.Package(pkg[1], pkg[2], pkg[3], pkg[4],  ".deb"))
        info.build_env = pkg_list
    bi_str = str(info)
    f = open(filename, "w+")
    f.write(bi_str)
    f.close()

