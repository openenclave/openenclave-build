export CC=clang
export CXX=clang++
export LD=ld.lld
export CFLAGS="-Wno-unused-command-line-argument -Wl,-I/lib64/ld-linux-x86-64.so.2"
export CXXFLAGS="-Wno-unused-command-line-argument -Wl,-I/lib64/ld-linux-x86-64.so.2"
export LDFLAGS="-I/lib64/ld-linux-x86-64.so.2"
export C_INCLUDE_PATH="/usr/include:/usr/include/x86_64-linux-gnu"
export CXX_INCLUDE_PATH="/usr/include:/usr/include/x86_64-linux-gnu"

