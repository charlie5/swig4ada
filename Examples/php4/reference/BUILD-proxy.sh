#! /bin/sh -e

${SWIG:=swig}  -php4 -make -c++ -withcxx example.cxx example.i
make
php -d extension_dir=. runme-proxy.php4
