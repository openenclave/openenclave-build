#
# Class definition of buildinfoc

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
        self.checksums = checksums
        self.build_path = build_path
        self.build_env = build_env
        self.signature_version = signature_version
        self.signature = signature

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
        for checksum in self.checksums:
            ret.append(" "+checksum+"\n")
        #
        ret.append("Build-Path:"+self.build_path+"\n")
        ret.append("Build-Environment:\n")
        for pkg in self.build_env:
            ret.append(pkg.name+" (="+pkg.version+"),\n")
        ret.append("-----BEGIN PGP SIGNATURE-----\n")
        ret.append("Version: "+self.signature_version+"\n")
        ret.append("\n")
        ret.append(self.signature+"\n")
        ret.append("-----END PGP SIGNATURE-----\n")
        ret.append("-----END PGP SIGNED MESSAGE-----\n")

        return ret

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
        for checksum in self.checksums:
            ret += (" "+checksum+"\n")
        #
        ret += ("Build-Path:"+self.build_path+"\n")
        ret += ("Build-Environment:\n")
        for pkg in self.build_env:
            ret += (" "+pkg.name+" (="+pkg.version+"),\n")
        ret += ("-----BEGIN PGP SIGNATURE-----\n")
        ret += ("Version: "+self.signature_version+"\n")
        ret += ("\n")
        ret += (self.signature+"\n")
        ret += ("-----END PGP SIGNATURE-----\n")
        ret += ("-----END PGP SIGNED MESSAGE-----\n")

        return ret

class Package:
    def __init__(self, name, vers, arch, desc, pkg_type):
        #
        self.name = name
        self.version = vers
        self.arch = arch
        self.desc = desc
        self.pkg_type = pkg_type

    def __repr__(self):
        return self.name+" "+self.version;

    def __str__(self):
        return self.name+":"+self.desc;

class Checksum:
    def __init__(self, pkg_filename, pkg_filelen, pkg_hashval):
        self.filename = pkg_filename
        self.filelen  = pkg_filelen
        self.hashval  = pkg_hashval

    def __repr__(self):
        return " "+str(self.hashval)+" "+str(self.filelen)+" "+self.filename

    def __str__(self):
        return " "+str(self.hashval)+" "+str(self.filelen)+" "+self.filename
