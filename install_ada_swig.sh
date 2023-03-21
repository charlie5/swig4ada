## Installs the Ada version of Swig to /user/local.
#

set -e

# Copy binary to install location.
#
cp ./ada-build/swig_ada /usr/local/bin


#cp ./swig.ads                    /usr/local/include
#cp ./swig-pointers.ads           /usr/local/include
#cp ./interfaces_cpp_pointers.ads /usr/local/include
#cp ./interfaces_cpp_pointers.adb /usr/local/include


mkdir -p /usr/local/share/swig/4.0.0/ada
#cp     ./Lib/ada/* /usr/local/share/swig/4.0.0/ada/
cp -fr ./Lib/*     /usr/local/share/swig/4.0.0 
