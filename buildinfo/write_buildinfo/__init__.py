import BuildInfo
import os
import platform

import pdb

info = BuildInfo.BuildInfo()


#
# Returns all of the files in a directory tree that are executable files that are not an intermediate build product
#
def getfileslist(path):
    files = list()
    direntries = os.scandir(path)
    for entry in direntries:
        filepath = path+'/'+entry.name
        if entry.is_dir() and not entry.name.startswith('.'):
            newfiles = getfileslist(filepath)
            if len(newfiles) > 0:
                files.extend(newfiles)
        elif entry.is_file() and not entry.name.endswith('.bin') and not entry.name.startswith('a.out'):
            if os.access(filepath, os.X_OK):
                print( "filepath = "+filepath)
                files.append(filepath)
    return files



def get_deb_packages():
    rslt = os.popen('dpkg -l').read()
    slist = rslt.split('\n')
    return slist[5:]

def __init__(filename, src, binary, contains_files=[]):
    #
    info.src    = src
    info.binary = binary
    info.build_arch = platform.machine()

    if len(contains_files) == 0:
        contains_files = getfileslist(binary)

    for f in contains_files:
        info[-1] = BuildInfo.Checksum.checksum_file(f) # appends to the end of the checksums
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

