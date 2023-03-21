## Builds the gnat version of Swig.
#


# build the ada binding to the swig C headers
#
#cd Source/Modules/ada/swig_binding
#./builder


# build the gnat swig executable
#
cd ada-build
gprbuild -P swig_applet -Xrestrictions=xgc