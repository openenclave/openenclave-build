#
# Class definition of buildinfo
import hashlib
import io
import os
import pdb

class BuildInfo:
    def __init__(self, 
                 file_format = 1.0,
                 build_arch = "x86_64",
                 source = "" ,
                 binary = "" ,
                 arch = [ "all" ],
                 vers = "",
                 changes_bin_only = [],
                 checksums = [],
                 build_path = "",
                 build_env = [], 
                 signature_version = "",
                 signature = ""):
        self.file_format = file_format
        self.build_arch = build_arch
        self.source = source
        self.binary = binary
        self.arch = arch
        self.vers = vers
        self.changes_bin_only = changes_bin_only
        if len(checksums) > 0 :
            if isinstance(checksums[0], str):
                checkstrs = checksums
                checksums = list()
                for thisstr in checkstrs:
                     checksums.expand(Checksum.from_str(thisstr))
    
            if not isinstance(checksums[0], Checksum):
                print("Invalid type passed to checksums")
                return None
        pdb.set_trace() 
        self.__checksums = checksums
        self.build_path = build_path
        self.build_env = build_env
        self.signature_version = signature_version
        self.signature = signature


    @classmethod
    def from_str(cls, s):
        file_format = 1.0
        build_arch = "x86_64"
        source = "" 
        binary = "" 
        arch = [ "all" ]
        vers = ""
        changes_bin_only = []
        checksums = []
        build_path = ""
        build_env = [] 
        signature_version = ""
        signature = ""
        # We have the entire buildinfo in a buffer. So we can parse it
        lines = s

        for lineidx in range(0, len(lines)):
            #if not isinstance(lines[lineidx], str):
            #    line = str(lines[lineidx], 'utf-8')
            #else:
            #    line = lines[lineidx]
            line = lines[lineidx]
            if line.startswith('\n'):
                # blank line. skip it
                pass
            if line.startswith('---'):
                # skip it
                pass
            elif line.startswith('Hash'):
                # skip it
                pass
            elif line.startswith('Format:'):
                toks = line.split(':')
                file_format = toks[1]
            elif line.startswith('Source:'):
                toks = line.split(':')
                source = toks[1]
            elif line.startswith('Binary:'):
                toks = line.split(':')
                binary = toks[1]
            elif line.startswith('Build-Architecture:'):
                toks = line.split(':')
                build_arch = toks[1]
            elif line.startswith('Architecture:'):
                toks = line.split(':')
                arch = toks[1]
            elif line.startswith('Version:'):
                toks = line.split(':')
                vers = toks[1]
            elif line.startswith('Binary-Only-Changes:'):
                toks = line.split(':')
                changes_bin_only = toks[1] # probably wrong. Need example
            elif line.startswith('Checksums-Sha256:'):
                for chkidx in range(lineidx+1, len(lines)):
                     lineidx = chkidx
                     chkstr = lines[chkidx]
                     if ':' in chkstr:
                          break

                     chksum = Checksum.from_str(chkstr)
                     if chksum is None:
                           break
                     checksums.append(chksum)
            elif line.startswith('Build-Path:'):
                toks = line.split(':')
                build_path = toks[1]
            elif line.startswith('Build-Environment:'):
                for envidx in range(lineidx+1, len(lines)):
                     lineidx = envidx
                     envstr = lines[envidx]
                     if ':' in envstr:
                          break
             
                     build_env.append(envstr)
            elif line.startswith('Version:'): # certainly wrong. Need example
                toks = line.split(':')
                ignature_version = toks[1]

        signature = ""
        return cls( file_format, build_arch, source, binary, 
                    arch, vers, changes_bin_only, checksums, build_path, build_env, signature_version, signature)

    def __repr__(self):
        ret = []
        ret.append("-----BEGIN PGP SIGNED MESSAGE-----\n")
        ret.append("Hash: SHA256\n")
        ret.append("\n")
        ret.append("Format: "+str(self.file_format)+"\n")
        ret.append("Source: "+self.source+"\n")
        ret.append("Binary: "+self.binary+"\n")
        ret.append("Architecture: "+str(self.arch)+"\n")
        ret.append("Binary-Only-Changes: "+str(self.changes_bin_only)+"\n")
        ret.append("Checksums-Sha256:\n")
        for checksum in self.__checksums:
            ret.append(" "+str(checksum)+"\n")
        #
        ret.append("Build-Path:"+self.build_path+"\n")
        ret.append("Build-Environment:\n")
        if self.build_env:
            for pkg in self.build_env:
                ret.append(str(pkg)+",\n")
        else:
            ret.append("nil\n")

        ret.append("-----BEGIN PGP SIGNATURE-----\n")
        ret.append("Version: "+self.signature_version+"\n")
        ret.append("\n")
        ret.append(self.signature+"\n")
        ret.append("-----END PGP SIGNATURE-----\n")
        ret.append("-----END PGP SIGNED MESSAGE-----\n")

        return str(ret)

    def __str__(self):
        ret = ""
        ret += ("-----BEGIN PGP SIGNED MESSAGE-----\n")
        ret += ("Hash: SHA256\n")
        ret += ("\n")
        ret += ("Format: "+str(self.file_format)+"\n")
        ret += ("Source: "+self.source+"\n")
        ret += ("Binary: "+self.binary+"\n")
        ret += ("Architecture: "+str(self.arch)+"\n")
        ret += ("Binary-Only-Changes: "+str(self.changes_bin_only)+"\n")
        ret += ("Checksums-Sha256:\n")
        for checksum in self.__checksums:
            ret += (" "+str(checksum)+"\n")
        #
        ret += ("Build-Path:"+self.build_path+"\n")
        ret += ("Build-Environment:\n")
        for pkg in self.build_env:
            ret += (" "+str(pkg)+",\n")
        ret += ("-----BEGIN PGP SIGNATURE-----\n")
        ret += ("Version: "+self.signature_version+"\n")
        ret += ("\n")
        ret += (self.signature+"\n")
        ret += ("-----END PGP SIGNATURE-----\n")
        ret += ("-----END PGP SIGNED MESSAGE-----\n")

        return ret

    @property
    def checksums(self):
        return self.__checksums

    @checksums.setter
    def checksums(self, newsums): 
        if isinstance(nuwsums[0], str):
            self.__checksums = List()
            for newsum in newsums:
                self.__checksums += Checksum.from_str(newsum)
        elif not isinstance(newsums[0], Checksum):
            print("Invalid type passed to checksums")
            return None
        else:
            self.__checksums = checksums
            

    def __getitem__(self, idx=0):
        return __checksums[idx]

    def __setitem__(self, idx, newsum):
        # insert -1 puts the object at the second to last position, which is not what we want
        # so we append in that case. For positive values it does the expected behaviour
        if idx == -1:
            self.__checksums.append(newsum)
        else:
            self.__checksums.insert(idx, newsum)
        return newsum
        

    def verify(self, binpath, libpath):
        pathlist = binpath.split(":")
        liblist  = libpath.split(":")
        # We want to make sure the file in question is on the path list, binary or lib depending

        for checksum in self.__checksums:
            if '.so' in checksum.filename:
                # Search ldlibpath
                for lib in liblist:
                    print("look for "+checksum.filename+"in lib path"+lib)
                    rslt = checksum.verify(lib)
                    if rslt:
                        return rslt
            else:
                # search binary path
                for p in pathlist:
                    print("look for "+checksum.filename+"in bin path"+p)
                    rslt = checksum.verify(lib)
                    if rslt:
                        return rslt
        return False


class Package:
    def __init__(self, name, vers, arch, desc, pkg_type):
        #
        if ":" in name:
            tok = name.split(":")
            self.name = tok[0]
            self.arch = tok[1]
        else:
            self.name = name
        self.version = vers
        self.arch = arch
        self.desc = desc
        self.pkg_type = pkg_type

    @classmethod
    def from_str(cls, pkg_str):
        pkg_list = pkg_str.split();
        # splits <pkgname>:<arch> (=pkgversion) into two peices
        arch = "all"
        # arch is optional. defaults to "all"
        if ":" in pkg_list[0]:
            tok = pkg_list[0].split(":")
            name = tok[0]
            arch = tok[1]
        else:
            name = pkg_list[0]

        # repslit the second part
 
        toks = pkg_list[1].split("=") 

        # give us "<pkg_version>)"
        toks = toks[1].split(")") 
        version = toks[0]
        desc  = ""
        return cls( name, vers, arch, desc, ".deb")

    def __repr__(self):
        return self.name+":"+self.arch+"(="+self.version+"   "+self.desc;

    def __str__(self):
        if self.arch != "all":
            return self.name+":"+self.arch+" "+"(="+self.version+")";
        else:
            return self.name+" "+self.version;


class Checksum:
    def __init__(self, filename, filelen, hashval):
        self.filename = filename
        self.filelen  = filelen
        self.hashval  = hashval

    @classmethod
    def from_str(cls, sig_str):
        sig_list = sig_str.split();
        return cls(sig_list[0], sig_list[1], sig_list[2])

    def __repr__(self):
        return "hashval: "+str(self.hashval)+" filelen:  "+str(self.filelen)+"file name: "+self.filename

    def __str__(self):
        return " "+str(self.hashval)+" "+str(self.filelen)+" "+self.filename

    def verify(self, path):
        other = checksum_file(path+"/"+self.filename)
        return False
         
    @classmethod
    def checksum_file(cls, filename):
        sha256_hash = hashlib.sha256()
        file_bytes = 0
        f = open(filename,"rb")
        # Read and update hash string value in blocks of 4K
        for byte_block in iter(lambda: f.read(4096),b""):
            sha256_hash.update(byte_block)
            file_bytes += len(byte_block)
        return cls(os.path.basename(filename), file_bytes, sha256_hash.hexdigest())
    
    
