import write_buildinfo

if __name__ == "__main__":
    #write_buildinfo.__init__("/tmp/xxx.buildinfo")
    files = [ "/home/azureuser/tmp/src/cfe-7.0.1.src/libexec/c++-analyzer",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/libexec/ccc-analyzer",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/clang-func-mapping",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/clang-rename",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/scan-view",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/clang-import-test",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/diagtool",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/scan-build",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/arcmt-test",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/clang-7",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/clang-refactor",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/c-index-test",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/llvm-lit",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/clang-tblgen",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/clang-check",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/c-arcmt-test",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/clang-offload-bundler",
        "/home/azureuser/tmp/src/cfe-7.0.1.src/bin/clang-format" ]

    for f in files:
        print("checksum: "+str( write_buildinfo.checksum_file(f)) +"\n")
