import write_buildinfo
import os 
from operator import add

if __name__ == "__main__":
    write_buildinfo.__init__("/tmp/xxx.buildinfo", "/src", "/build" )
