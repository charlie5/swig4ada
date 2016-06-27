# ------------------------------------------------------------
# SWIG Examples Makefile
#
# This file is used by the examples to build modules.  Assuming
# you ran configure, this file will probably work.  However,
# it's not perfect so you might need to do some hand tweaking.
#
# Other notes:
#
# 1.   Take a look at the prefixes below.   Since SWIG works with
#      multiple target languages, you may need to find out where
#      certain packages have been installed.   Set the prefixes
#      accordingly.
#
# 2.   To use this makefile, simply set SRCS, INTERFACE, INCLUDES, LIBS,
#      TARGET, and do a
#           $(MAKE) -f Makefile.template.in SRCS='$(SRCS)' \
#           INCLUDES='$(INCLUDES) LIBS='$(LIBS)' INTERFACE='$(INTERFACE)' \
#           TARGET='$(TARGET)' method
#
#      'method' describes what is being built.
#---------------------------------------------------------------

TARGET     =
CC         = gcc
CXX        = g++
CFLAGS     = 
prefix     = /usr/local
exec_prefix= ${prefix}
SRCS       =
INCLUDES   =
LIBS       =
INTERFACE  =
SWIGOPT    =
SWIG       = swig

LIBM       = -lieee -lm
LIBC       = 
LIBCRYPT   = -lcrypt
SYSLIBS    = $(LIBM) $(LIBC) $(LIBCRYPT)
LIBPREFIX  =

# RUNTOOL is for use as with runtime tools, eg set it to valgrind
RUNTOOL    =
COMPILETOOL=

# X11 options

XLIB       = -lX11
XINCLUDE   = # no special path needed

IWRAP      = $(INTERFACE:.i=_wrap.i)
ISRCS      = $(IWRAP:.i=.c)
ICXXSRCS   = $(IWRAP:.i=.cxx)
IOBJS      = $(IWRAP:.i=.o)

##################################################################
# Dynamic loading for C++
# If you are going to be building dynamic loadable modules in C++,
# you may need to edit this line appropriately.
#
# This line works for g++, but I'm not sure what it might be
# for other C++ compilers
##################################################################

CPP_DLLIBS = #-L/usr/local/lib/gcc-lib/sparc-sun-solaris2.5.1/2.7.2 \
             -L/usr/local/lib -lg++ -lstdc++ -lgcc

# Solaris workshop 5.0 
# CPP_DLLIBS = -L/opt/SUNWspro/lib -lCrun

# Symbols used for using shared libraries
SO=		.so
LDSHARED=	gcc -shared
CCSHARED=	-fpic
CXXSHARED=      gcc -shared

# This is used for building shared libraries with a number of C++
# compilers.   If it doesn't work,  comment it out.
CXXSHARED= g++ -shared 

OBJS      = $(SRCS:.c=.o) $(CXXSRCS:.cxx=.o)

##################################################################
#####                       Tcl/Tk                          ######
##################################################################

# Set these to your local copy of Tcl/Tk.

TCL_INCLUDE = 
TCL_LIB     = 
TCL_OPTS    = -ldl 
TK_OPTS     = -ltk -ltcl -ldl 

# Extra Tcl specific dynamic linking options
TCL_DLNK   = 
TCL_LDSHARED = gcc -shared
TCL_CXXSHARED = CXXSHARED= g++ -shared 
TCL_SO     = .so

# -----------------------------------------------------------
# Build a new version of the tclsh shell
# -----------------------------------------------------------


tclsh: $(SRCS)
	$(SWIG) -tcl8 $(SWIGOPT) $(TCL_SWIGOPTS) -ltclsh.i $(INTERFACE)
	$(CC) $(CFLAGS) $(SRCS) $(ISRCS) $(INCLUDES) $(TCL_INCLUDE) \
	$(TCL_LIB)  $(TCL_OPTS) $(LIBS) $(SYSLIBS) -o $(TARGET)

tclsh_cpp: $(SRCS)
	$(SWIG) -tcl8 -c++ $(SWIGOPT) $(TCL_SWIGOPTS) -ltclsh.i $(INTERFACE)
	$(CXX) $(CFLAGS) $(SRCS) $(CXXSRCS) $(ICXXSRCS) $(INCLUDES) $(TCL_INCLUDE) \
	$(TCL_LIB) $(TCL_OPTS) $(LIBS) $(SYSLIBS) -o $(TARGET)

# -----------------------------------------------------------
# Build a new copy of wish
# -----------------------------------------------------------

wish: $(SRCS)
	$(SWIG) -tcl8 $(SWIGOPT) $(TCL_SWIGOPTS) -lwish.i $(INTERFACE)
	$(CC) $(CFLAGS) $(SRCS) $(ISRCS) $(INCLUDES) $(TCL_INCLUDE) \
	$(XINCLUDE) $(TCL_LIB) $(TK_OPTS) $(XLIB) $(LIBS) $(SYSLIBS) -o $(TARGET)


wish_cpp: $(SRCS)
	$(SWIG) -tcl8 -c++ $(SWIGOPT) $(TCL_SWIGOPTS) -lwish.i $(INTERFACE)
	$(CXX) $(CFLAGS) $(SRCS) $(CXXSRCS) $(ICXXSRCS) $(INCLUDES) $(TCL_INCLUDE) \
	$(XINCLUDE) $(TCL_LIB) $(TK_OPTS) $(XLIB) $(LIBS) $(SYSLIBS) -o $(TARGET)

# -----------------------------------------------------------
# Build a Tcl dynamic loadable module (you might need to tweak this)
# -----------------------------------------------------------

tcl:  $(SRCS)
	$(SWIG) -tcl8 $(SWIGOPT) $(TCL_SWIGOPTS) $(INTERFACE)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(SRCS) $(ISRCS) $(INCLUDES) $(TCL_INCLUDE)
	$(TCL_LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(TCL_DLNK) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(TCL_SO)

# -----------------------------------------------------------
# Build a Tcl7.5 dynamic loadable module for C++
# -----------------------------------------------------------

tcl_cpp: $(SRCS)
	$(SWIG) -tcl8 -c++ $(SWIGOPT) $(TCL_SWIGOPTS) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(SRCS) $(CXXSRCS) $(ICXXSRCS) $(INCLUDES) $(TCL_INCLUDE)
	$(TCL_CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(TCL_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(TCL_SO)

# -----------------------------------------------------------------
# Cleaning the Tcl examples
# -----------------------------------------------------------------

tcl_clean:
	rm -f *_wrap* *~ .~* mytclsh 
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                       PERL 5                          ######
##################################################################

# You need to set this variable to the Perl5 directory containing the
# files "perl.h", "EXTERN.h" and "XSUB.h".   With Perl5.003, it's
# usually something like /usr/local/lib/perl5/arch-osname/5.003/CORE.

PERL5_INCLUDE= /usr/lib/perl/5.8/CORE

# Extra Perl specific dynamic linking options
PERL5_DLNK   = 
PERL5_CCFLAGS = -D_REENTRANT -D_GNU_SOURCE -DTHREADS_HAVE_PIDS -DDEBIAN -fno-strict-aliasing -pipe -isystem /usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64

# ----------------------------------------------------------------
# Build a Perl5 dynamically loadable module (C)
# ----------------------------------------------------------------

perl5: $(SRCS)
	$(SWIG) -perl5 $(SWIGOPT) $(INTERFACE)
	$(CC) -c -Dbool=char $(CCSHARED) $(CFLAGS) $(SRCS) $(ISRCS) $(INCLUDES) $(PERL5_CCFLAGS) -I$(PERL5_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(PERL5_DLNK) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# ----------------------------------------------------------------
# Build a Perl5 dynamically loadable module (C++)
# ----------------------------------------------------------------

perl5_cpp: $(SRCS)
	$(SWIG) -perl5 -c++ $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(SRCS) $(CXXSRCS) $(ICXXSRCS) $(INCLUDES) $(PERL5_CCFLAGS) -I$(PERL5_INCLUDE)
	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(PERL5_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# ----------------------------------------------------------------
# Build a module from existing XS C source code.   (ie. from xsubpp).
# ----------------------------------------------------------------
perl5_xs: $(SRCS)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(SRCS) $(INCLUDES) -I$(PERL5_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(OBJS) $(LIBS) -o $(TARGET)$(SO)

# ----------------------------------------------------------------
# Build a statically linked Perl5 executable
# ----------------------------------------------------------------

PERL5_LIB    = -L$(PERL5_INCLUDE) -lperl.so.5.8.8 -ldl  $(SYSLIBS)

perl5_static: $(SRCS)
	$(SWIG) -perl5 -static -lperlmain.i $(SWIGOPT) $(INTERFACE)
	$(CC) $(CFLAGS) -Dbool=char $(SRCS) $(ISRCS) $(INCLUDES) -I$(PERL5_INCLUDE) $(PERL5_LIB) $(LIBS) -o $(TARGET)

perl5_static_cpp: $(SRCS)
	$(SWIG) -perl5 -c++ -static -lperlmain.i $(SWIGOPT) $(INTERFACE)
	$(CXX) $(CFLAGS) $(SRCS) $(CXXSRCS) $(ICXXSRCS) $(INCLUDES) -I$(PERL5_INCLUDE) $(PERL5_LIB) $(LIBS) -o $(TARGET)

# -----------------------------------------------------------------
# Cleaning the Perl5 examples
# -----------------------------------------------------------------

perl5_clean:
	rm -f *_wrap* *~ .~* myperl *.pm
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                       PYTHON                          ######
##################################################################

# Make sure these locate your Python installation
PYTHON_INCLUDE= $(DEFS) -I/usr/include/python2.5 -I/usr/lib/python2.5/config
PYTHON_LIB    = /usr/lib/python2.5/config

# Extra Python specific dynamic linking options
PYTHON_DLNK   = 
PYTHON_SO     = .so

# ----------------------------------------------------------------
# Build a C dynamically loadable module
# ----------------------------------------------------------------

python: $(SRCS)
	$(SWIG) -python $(SWIGOPT) $(INTERFACE)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(ISRCS) $(SRCS) $(INCLUDES) $(PYTHON_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(PYTHON_DLNK) $(LIBS) -o $(LIBPREFIX)_$(TARGET)$(PYTHON_SO)

# -----------------------------------------------------------------
# Build a C++ dynamically loadable module
# -----------------------------------------------------------------

python_cpp: $(SRCS)
	$(SWIG) -c++ -python $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) $(PYTHON_INCLUDE)
	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(PYTHON_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)_$(TARGET)$(PYTHON_SO)

# -----------------------------------------------------------------
# Build statically linked Python interpreter
#
# These should only be used in conjunction with the %include embed.i
# library file
# -----------------------------------------------------------------

#TKINTER = -L/usr/X11R6.3/lib -L/usr/local/compat/lib -ltk4.0 -ltcl7.4 -lX11
TKINTER =
PYTHON_LIBOPTS = -lpython2.5 -ldl  $(TKINTER) $(SYSLIBS)

python_static: $(SRCS)
	$(SWIG) -python -lembed.i $(SWIGOPT) $(INTERFACE)
	$(CC) $(CFLAGS) -Xlinker -export-dynamic $(ISRCS) $(SRCS) $(INCLUDES) \
	$(PYTHON_INCLUDE) $(LIBS) -L$(PYTHON_LIB) $(PYTHON_LIBOPTS) -o $(TARGET)

python_static_cpp: $(SRCS)
	$(SWIG) -c++ -python -lembed.i $(SWIGOPT) $(INTERFACE)
	$(CXX) $(CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) \
	$(PYTHON_INCLUDE) $(LIBS)  -L$(PYTHON_LIB) $(PYTHON_LIBOPTS) -o $(TARGET)

# -----------------------------------------------------------------
# Cleaning the python examples
# -----------------------------------------------------------------

python_clean:
	rm -f *_wrap* *~ .~* mypython *.pyc
	rm -f core 
	rm -f *.o *.so *.so

##################################################################
#####                       OCTAVE                          ######
##################################################################

# Make sure these locate your Octave installation
OCTAVE_INCLUDE= $(DEFS) 
OCTAVE_LIB    = 

# Extra Octave specific dynamic linking options
OCTAVE_DLNK   = 
OCTAVE_SO     = .oct

# ----------------------------------------------------------------
# Build a C dynamically loadable module
# ----------------------------------------------------------------

octave: $(SRCS)
	$(SWIG) -octave $(SWIGOPT) $(INTERFACE)
	$(CXX) -g -c $(CCSHARED) $(CFLAGS) $(ICXXSRCS) $(CXXSRCS) $(INCLUDES) -I$(OCTAVE_INCLUDE)
	$(CC) -g -c $(CCSHARED) $(CFLAGS) $(SRCS) $(INCLUDES) $(OCTAVE_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(OCTAVE_DLNK) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(OCTAVE_SO)

# -----------------------------------------------------------------
# Build a C++ dynamically loadable module
# -----------------------------------------------------------------

octave_cpp: $(SRCS)
	$(SWIG) -c++ -octave $(SWIGOPT) $(INTERFACE)
	$(CXX) -g -c $(CCSHARED) $(CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) -I$(OCTAVE_INCLUDE)
	$(CXXSHARED) -g $(CFLAGS) $(OBJS) $(IOBJS) $(OCTAVE_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(OCTAVE_SO)

# -----------------------------------------------------------------
# Cleaning the octave examples
# -----------------------------------------------------------------

octave_clean:
	rm -f *_wrap* *~ .~* myoctave *.pyc
	rm -f core 
	rm -f *.o *.so *.oct

##################################################################
#####                       GUILE                           ######
##################################################################

# Make sure these locate your Guile installation
GUILE_INCLUDE = 
GUILE_LIB     = 
GUILE_SO      = .so
GUILE_LIBPREFIX = lib

#------------------------------------------------------------------
# Build a dynamically loaded module with passive linkage and the scm interface
#------------------------------------------------------------------
guile: $(SRCS)
	$(SWIG) -guile -scm -Linkage passive $(SWIGOPT) $(INTERFACE)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(INCLUDES) $(GUILE_INCLUDE) $(ISRCS) $(SRCS)
	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(GUILE_LIBPREFIX)$(TARGET)$(GUILE_SO)

guile_cpp: $(SRCS)
	$(SWIG) -c++ -guile -scm -Linkage passive $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(INCLUDES) $(GUILE_INCLUDE) $(ICXXSRCS) $(SRCS) $(CXXSRCS)
	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(GUILE_LIBPREFIX)$(TARGET)$(GUILE_SO)

guile_externalhdr:
	$(SWIG) -guile -external-runtime $(TARGET)

#------------------------------------------------------------------
# Build a dynamically loaded module with passive linkage and the gh interface
#------------------------------------------------------------------
guile_gh: $(SRCS)
	$(SWIG) -guile -gh -Linkage passive $(SWIGOPT) $(INTERFACE)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(INCLUDES) $(GUILE_INCLUDE) $(ISRCS) $(SRCS)
	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(GUILE_LIBPREFIX)$(TARGET)$(GUILE_SO)

guile_gh_cpp: $(SRCS)
	$(SWIG) -c++ -guile -gh -Linkage passive $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(INCLUDES) $(GUILE_INCLUDE) $(ICXXSRCS) $(SRCS) $(CXXSRCS)
	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(GUILE_LIBPREFIX)$(TARGET)$(GUILE_SO)

# -----------------------------------------------------------------
# Build a dynamically loadable module with passive linkage
# -----------------------------------------------------------------

guile_passive: $(SRCS)
	$(SWIG) -guile -Linkage passive $(SWIGOPT) $(INTERFACE)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(INCLUDES) $(GUILE_INCLUDE) $(ISRCS) $(SRCS)
	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(GUILE_LIBPREFIX)$(TARGET)$(GUILE_SO)

guile_passive_cpp: $(SRCS)
	$(SWIG) -c++ -guile -Linkage passive $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(INCLUDES) $(GUILE_INCLUDE) $(ICXXSRCS) $(SRCS) $(CXXSRCS)
	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(GUILE_LIBPREFIX)$(TARGET)$(GUILE_SO)

# -----------------------------------------------------------------
# Build statically linked Guile interpreter
# -----------------------------------------------------------------

GUILE_LIBOPTS = -L -lguile -ldl  $(SYSLIBS)

guile_static: $(SRCS)
	$(SWIG) -guile -lguilemain.i -Linkage ltdlmod $(SWIGOPT) $(INTERFACE)
	$(CC) $(CFLAGS) $(ISRCS) $(SRCS) $(INCLUDES) \
	  -DSWIGINIT="SCM scm_init_$(TARGET)_module(void); scm_init_$(TARGET)_module();" \
	  $(GUILE_INCLUDE) $(LIBS) -L$(GUILE_LIB) $(GUILE_LIBOPTS) -o $(TARGET)-guile

guile_static_cpp: $(SRCS)
	$(SWIG) -c++ -guile -lguilemain.i -Linkage ltdlmod $(SWIGOPT) $(INTERFACE)
	$(CXX) $(CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) \
	  -DSWIGINIT="SCM scm_init_$(TARGET)_module(void); scm_init_$(TARGET)_module();" \
	  $(GUILE_INCLUDE) $(LIBS) -L$(GUILE_LIB) $(GUILE_LIBOPTS) -o $(TARGET)-guile

guile_simple: $(SRCS)
	$(SWIG) -guile -lguilemain.i -Linkage simple $(SWIGOPT) $(INTERFACE)
	$(CC) $(CFLAGS) $(ISRCS) $(SRCS) $(INCLUDES) \
	  $(GUILE_INCLUDE) $(LIBS) -L$(GUILE_LIB) $(GUILE_LIBOPTS) -o $(TARGET)-guile

guile_simple_cpp: $(SRCS)
	$(SWIG) -c++ -guile -lguilemain.i -Linkage simple $(SWIGOPT) $(INTERFACE)
	$(CXX) $(CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) \
	  $(GUILE_INCLUDE) $(LIBS) -L$(GUILE_LIB) $(GUILE_LIBOPTS) -o $(TARGET)-guile

# -----------------------------------------------------------------
# Cleaning the Guile examples
# -----------------------------------------------------------------

guile_clean:
	rm -f *_wrap* *~ .~* my-guile $(TARGET)
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                       JAVA                            ######
##################################################################

# You need to set this variable to the java directories containing the
# files "jni.h" and "md.h"
# usually something like /usr/java/include and /usr/java/include/<arch-osname>.
JAVA_INCLUDE= 

# Extra Java specific dynamic linking options
JAVA_DLNK  = 
JAVA_LIBPREFIX = lib
JAVASO =.so
JAVALDSHARED = $(LDSHARED)
JAVACXXSHARED = $(CXXSHARED)
JAVACFLAGS = 

# ----------------------------------------------------------------
# Build a java dynamically loadable module (C)
# ----------------------------------------------------------------

java: $(SRCS)
	$(SWIG) -java $(SWIGOPT) $(INTERFACE)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(JAVACFLAGS) $(SRCS) $(ISRCS) $(INCLUDES) $(JAVA_INCLUDE)
	$(JAVALDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(JAVA_DLNK) $(LIBS) -o $(JAVA_LIBPREFIX)$(TARGET)$(JAVASO)

# ----------------------------------------------------------------
# Build a java dynamically loadable module (C++)
# ----------------------------------------------------------------

java_cpp: $(SRCS)
	$(SWIG) -java -c++ $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(JAVACFLAGS) $(SRCS) $(CXXSRCS) $(ICXXSRCS) $(INCLUDES) $(JAVA_INCLUDE)
	$(JAVACXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(JAVA_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(JAVA_LIBPREFIX)$(TARGET)$(JAVASO)

# -----------------------------------------------------------------
# Cleaning the java examples
# -----------------------------------------------------------------

java_clean:
	rm -f *_wrap* *~ .~* *.class `find . -name \*.java | grep -v main.java`
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      MODULA3                          ######
##################################################################

MODULA3_INCLUDE= @MODULA3INC@

# ----------------------------------------------------------------
# Build a modula3 dynamically loadable module (C)
# ----------------------------------------------------------------

modula3: $(SRCS)
	$(SWIG) -modula3 $(SWIGOPT) $(INTERFACE)
#	$(CC) -c $(CCSHARED) $(CFLAGS) $(SRCS) $(ISRCS) $(INCLUDES) \
#       $(OBJS) $(IOBJS) $(LIBS)

modula3_cpp: $(SRCS)
	$(SWIG) -modula3 -c++ $(SWIGOPT) $(INTERFACE)

# -----------------------------------------------------------------
# Cleaning the modula3 examples
# -----------------------------------------------------------------

modula3_clean:
	rm -f *_wrap* *.i3 *.m3
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                       MZSCHEME                        ######
##################################################################

MZC = test -n "" && 
MZDYNOBJ = 
MZSCHEME_SO = .so

# ----------------------------------------------------------------
# Build a C/C++ dynamically loadable module
# ----------------------------------------------------------------

mzscheme: $(SRCS)
	$(SWIG) -mzscheme $(SWIGOPT) $(INTERFACE)
	$(MZC) `echo $(INCLUDES) | sed 's/-I/++ccf -I/g'` --cc $(ISRCS) $(SRCS)
	$(MZC) --ld $(TARGET)$(MZSCHEME_SO) $(OBJS) $(IOBJS)

mzscheme_cpp: $(SRCS)
	$(SWIG) -mzscheme -c++ $(SWIGOPT) $(INTERFACE)
	$(MZC) `echo $(INCLUDES) | sed 's/-I/++ccf -I/g'` --cc $(ICXXSRCS) $(SRCS) $(CXXSRCS)
	$(CXXSHARED) $(CFLAGS) -o $(LIBPREFIX)$(TARGET)$(MZSCHEME_SO) $(OBJS) $(IOBJS) $(MZDYNOBJ) $(CPP_DLLIBS) 

# -----------------------------------------------------------------
# Cleaning the mzscheme examples
# -----------------------------------------------------------------

mzscheme_clean:
	rm -f *_wrap* *~ .~* 
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                          Ocaml                         #####
##################################################################

OCC=:
OCAMLDLGEN=:
OCAMLFIND=:
OCAMLMKTOP=: $(SWIGWHERE)
NOLINK ?= false
OCAMLPP= -pp "camlp4o ./swigp4.cmo"
OCAMLCORE=\
	rm -rf swig.mli swig.ml swigp4.ml && \
	$(SWIG) -ocaml -co swig.mli 2>/dev/null &&  \
	$(SWIG) -ocaml -co swig.ml 2>/dev/null &&  \
	$(SWIG) -ocaml -co swigp4.ml 2>/dev/null &&  \
	$(OCC) -c swig.mli &&  \
	$(OCC) -c swig.ml &&  \
	$(OCC) -I `camlp4 -where` -pp "camlp4o pa_extend.cmo q_MLast.cmo" \
		-c swigp4.ml

ocaml_static: $(SRCS)
	$(OCAMLCORE)
	$(SWIG) -ocaml $(SWIGOPT) $(INTERFACE)
	$(OCC) -g -c -ccopt -g -ccopt "$(INCLUDES)" $(ISRCS) $(SRCS)
	$(OCC) -g -c $(INTERFACE:%.i=%.mli)
	$(OCC) -g -c $(INTERFACE:%.i=%.ml)
	test -z "$(PROGFILE)" || test -f "$(PROGFILE)" && \
		$(OCC) $(OCAMLPP) -c $(PROGFILE)
	$(NOLINK) || $(OCC) -g -ccopt -g -cclib -g -custom -o $(TARGET) \
		swig.cmo \
		$(INTERFACE:%.i=%.cmo) \
		$(PROGFILE:%.ml=%.cmo) \
		$(INTERFACE:%.i=%_wrap.o) $(OBJS) -cclib "$(LIBS)"

ocaml_dynamic: $(SRCS)
	$(OCAMLCORE)
	$(SWIG) -ocaml $(SWIGOPT) $(INTERFACE)
	$(OCC) -g -c -ccopt -g -ccopt "$(INCLUDES)" $(ISRCS) $(SRCS)
	$(CXXSHARED) $(CFLAGS) $(CCSHARED) $(CFLAGS) -o $(INTERFACE:%.i=%.so) \
		$(INTERFACE:%.i=%_wrap.o) $(OBJS) $(LIBS)
	$(OCAMLDLGEN) $(INTERFACE:%.i=%.ml) $(INTERFACE:%.i=%.so) > \
		$(INTERFACE:%.i=%_dynamic.ml)
	mv $(INTERFACE:%.i=%_dynamic.ml) $(INTERFACE:%.i=%.ml)
	rm $(INTERFACE:%.i=%.mli)
	$(OCAMLFIND) $(OCC) -g -c -package dl $(INTERFACE:%.i=%.ml)
	test -z "$(PROGFILE)" || test -f "$(PROGFILE)" && \
		$(OCC) $(OCAMLPP) -c $(PROGFILE)
	$(NOLINK) || $(OCAMLFIND) \
		$(OCC) -g -ccopt -g -cclib -g -custom -o $(TARGET) \
		swig.cmo \
		-package dl -linkpkg \
		$(INTERFACE:%.i=%.cmo) $(PROGFILE:%.ml=%.cmo)

ocaml_static_toplevel: $(SRCS)
	$(OCAMLCORE)
	$(SWIG) -ocaml $(SWIGOPT) $(INTERFACE)
	$(OCC) -g -c -ccopt -g -ccopt "$(INCLUDES)" $(ISRCS) $(SRCS)
	$(OCC) -g -c $(INTERFACE:%.i=%.mli)
	$(OCC) -g -c $(INTERFACE:%.i=%.ml)
	test -z "$(PROGFILE)" || test -f "$(PROGFILE)" && \
		$(OCC) $(OCAMLPP) -c $(PROGFILE)
	$(NOLINK) || $(OCAMLMKTOP) \
		swig.cmo \
		-I `camlp4 -where` camlp4o.cma swigp4.cmo \
		-g -ccopt -g -cclib -g -custom -o $(TARGET)_top \
		$(INTERFACE:%.i=%.cmo) \
		$(INTERFACE:%.i=%_wrap.o) $(OBJS) -cclib "$(LIBS)"

ocaml_static_cpp: $(SRCS)
	$(OCAMLCORE)
	$(SWIG) -ocaml -c++ $(SWIGOPT) $(INTERFACE)
	cp $(ICXXSRCS) $(ICXXSRCS:%.cxx=%.c)
	$(OCC) -cc '$(CXX)' -g -c -ccopt -g -ccopt "-xc++ $(INCLUDES)" \
		$(ICXXSRCS:%.cxx=%.c) $(SRCS) $(CXXSRCS)
	$(OCC) -g -c $(INTERFACE:%.i=%.mli)
	$(OCC) -g -c $(INTERFACE:%.i=%.ml)
	test -z "$(PROGFILE)" || test -f "$(PROGFILE)" && \
		$(OCC) $(OCAMLPP) -c $(PROGFILE)
	$(NOLINK) || $(OCC) -g -ccopt -g -cclib -g -custom -o $(TARGET) \
		swig.cmo \
		$(INTERFACE:%.i=%.cmo) \
		$(PROGFILE:%.ml=%.cmo) \
		$(INTERFACE:%.i=%_wrap.o) $(OBJS) \
		-cclib "$(LIBS)" -cc '$(CXX)' 

ocaml_static_cpp_toplevel: $(SRCS)
	$(OCAMLCORE)
	$(SWIG) -ocaml -c++ $(SWIGOPT) $(INTERFACE)
	cp $(ICXXSRCS) $(ICXXSRCS:%.cxx=%.c)
	$(OCC) -cc '$(CXX)' -g -c -ccopt -g -ccopt "-xc++ $(INCLUDES)" \
		$(ICXXSRCS:%.cxx=%.c) $(SRCS) $(CXXSRCS)
	$(OCC) -g -c $(INTERFACE:%.i=%.mli)
	$(OCC) -g -c $(INTERFACE:%.i=%.ml)
	test -z "$(PROGFILE)" || test -f "$(PROGFILE)" && \
		$(OCC) $(OCAMLPP) -c $(PROGFILE)
	$(NOLINK) || $(OCAMLMKTOP) \
		swig.cmo \
		-I `camlp4 -where` camlp4o.cma swigp4.cmo \
		-g -ccopt -g -cclib -g -custom -o $(TARGET)_top \
		$(INTERFACE:%.i=%.cmo) \
		$(INTERFACE:%.i=%_wrap.o) $(OBJS) \
		-cclib "$(LIBS)" -cc '$(CXX)' 

ocaml_dynamic_cpp: $(SRCS)
	$(OCAMLCORE)
	$(SWIG) -ocaml -c++ $(SWIGOPT) $(INTERFACE)
	cp $(ICXXSRCS) $(ICXXSRCS:%.cxx=%.c)
	$(OCC) -cc '$(CXX)' -g -c -ccopt -g -ccopt "-xc++ $(INCLUDES)" \
		$(ICXXSRCS:%.cxx=%.c) $(SRCS) $(CXXSRCS) -ccopt -fPIC
	$(CXXSHARED) $(CFLAGS) -o $(INTERFACE:%.i=%.so) \
		$(INTERFACE:%.i=%_wrap.o) $(OBJS) \
		$(CPP_DLLIBS) $(LIBS)
	$(OCAMLDLGEN) $(INTERFACE:%.i=%.ml) $(INTERFACE:%.i=%.so) > \
		$(INTERFACE:%.i=%_dynamic.ml)
	mv $(INTERFACE:%.i=%_dynamic.ml) $(INTERFACE:%.i=%.ml)
	rm $(INTERFACE:%.i=%.mli)
	$(OCAMLFIND) $(OCC) -g -c -package dl $(INTERFACE:%.i=%.ml)
	test -z "$(PROGFILE)" || test -f "$(PROGFILE)" && \
		$(OCC) $(OCAMLPP) -c $(PROGFILE)
	$(NOLINK) || $(OCAMLFIND) \
		swig.cmo \
		$(OCC) -cclib -export-dynamic -g -ccopt -g -cclib -g -custom \
		-o $(TARGET) \
		-package dl -linkpkg \
		$(INTERFACE:%.i=%.cmo) $(PROGFILE:%.ml=%.cmo) -cc '$(CXX)'

ocaml_clean:
	rm -f *_wrap* *~ .~* *.cmo *.cmi $(MLFILE) $(MLFILE)i swig.mli swig.cmi swig.ml swig.cmo swigp4.ml swigp4.cmo
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                       RUBY                            ######
##################################################################

# Make sure these locate your Ruby installation
RUBY_CFLAGS=  -fPIC $(DEFS)
RUBY_INCLUDE= -I
RUBY_LIB     = 
RUBY_DLNK = 

# ----------------------------------------------------------------
# Build a C dynamically loadable module
# ----------------------------------------------------------------

ruby: $(SRCS)
	$(SWIG) -ruby $(SWIGOPT) $(INTERFACE)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(RUBY_CFLAGS) $(ISRCS) $(SRCS) $(INCLUDES) $(RUBY_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(RUBY_DLNK) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Build a C++ dynamically loadable module
# -----------------------------------------------------------------

ruby_cpp: $(SRCS)
	$(SWIG) -c++ -ruby $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(RUBY_CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) $(RUBY_INCLUDE)
	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(RUBY_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Build statically linked Ruby interpreter
#
# These should only be used in conjunction with the %include embed.i
# library file
# -----------------------------------------------------------------

RUBY_LIBOPTS =  -lpthread -ldl -lcrypt -lm  -ldl  $(SYSLIBS)

ruby_static: $(SRCS)
	$(SWIG) -ruby -lembed.i $(SWIGOPT) $(INTERFACE)
	$(CC) $(CFLAGS) $(RUBY_CFLAGS) -Xlinker -export-dynamic $(ISRCS) $(SRCS) $(INCLUDES) \
	$(RUBY_INCLUDE) $(LIBS) -L$(RUBY_LIB) $(RUBY_LIBOPTS) -o $(TARGET)

ruby_cpp_static: $(SRCS)
	$(SWIG) -c++ -ruby -lembed.i $(SWIGOPT) $(INTERFACE)
	$(CXX) $(CFLAGS) $(RUBY_CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) \
	$(RUBY_INCLUDE) $(LIBS)  -L$(RUBY_LIB) $(RUBY_LIBOPTS) -o $(TARGET)


# -----------------------------------------------------------------
# Cleaning the Ruby examples
# -----------------------------------------------------------------

ruby_clean:
	rm -f *_wrap* *~ .~* myruby *.pm
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                       PHP                             ######
##################################################################

# -------------------------------------------------------------------
# Build a PHP4 dynamically loadable module (C)
# -------------------------------------------------------------------

PHP4_INCLUDE = 
PHP4_SO      = .so

php4: $(SRCS)
	$(SWIG) -php5 $(SWIGOPT) $(INTERFACE)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(SRCS) $(ISRCS) $(INCLUDES) $(PHP4_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(PHP4_SO)

# --------------------------------------------------------------------
# Build a PHP4 dynamically loadable module (C++)
# --------------------------------------------------------------------

php4_cpp: $(SRCS)
	$(SWIG) -php5 -cppext cxx -c++ $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(SRCS) $(CXXSRCS) $(ICXXSRCS) $(INCLUDES) $(PHP4_INCLUDE)
	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(PHP4_SO)

# -----------------------------------------------------------------
# Running a PHP4 example
# -----------------------------------------------------------------

PHP4=
SCRIPT ?= runme.php4

php4_run:
	env LD_LIBRARY_PATH=.:$$LD_LIBRARY_PATH $(RUNTOOL) $(PHP4) -n -q -d extension_dir=. $(SCRIPT)

# -----------------------------------------------------------------
# Cleaning the PHP4 examples
# -----------------------------------------------------------------

php4_clean:
	rm -f *_wrap* *~ .~* example.php php_example.h
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                       Pike                            ######
##################################################################

# Make sure these locate your Pike installation
PIKE_CFLAGS  =  -DHAVE_CONFIG_H
PIKE_INCLUDE = 
PIKE_LIB     = @PIKELIB@
PIKE_DLNK    = 

# ----------------------------------------------------------------
# Build a C dynamically loadable module
# ----------------------------------------------------------------

pike: $(SRCS)
	$(SWIG) -pike $(SWIGOPT) $(INTERFACE)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(PIKE_CFLAGS) $(ISRCS) $(SRCS) $(INCLUDES) $(PIKE_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(PIKE_DLNK) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Build a C++ dynamically loadable module
# -----------------------------------------------------------------

pike_cpp: $(SRCS)
	$(SWIG) -c++ -pike $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(PIKE_CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) $(PIKE_INCLUDE)
	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(PIKE_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Build statically linked Pike interpreter
#
# These should only be used in conjunction with the %include embed.i
# library file
# -----------------------------------------------------------------

PIKE_LIBOPTS = @PIKELINK@ -ldl  $(SYSLIBS)

pike_static: $(SRCS)
	$(SWIG) -pike -lembed.i $(SWIGOPT) $(INTERFACE)
	$(CC) $(CFLAGS) $(PIKE_CFLAGS) -Xlinker -export-dynamic $(ISRCS) $(SRCS) $(INCLUDES) \
	$(PIKE_INCLUDE) $(LIBS) -L$(PIKE_LIB) $(PIKE_LIBOPTS) -o $(TARGET)

pike_cpp_static: $(SRCS)
	$(SWIG) -c++ -pike -lembed.i $(SWIGOPT) $(INTERFACE)
	$(CXX) $(CFLAGS) $(PIKE_CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) \
	$(PIKE_INCLUDE) $(LIBS)  -L$(PIKE_LIB) $(PIKE_LIBOPTS) -o $(TARGET)

# -----------------------------------------------------------------
# Cleaning the Pike examples
# -----------------------------------------------------------------

pike_clean:
	rm -f *_wrap* *~ .~* mypike 
	rm -f core 
	rm -f *.o *.so


##################################################################
#####                      Chicken                          ######
##################################################################

CHICKEN = 
CHICKEN_CSC = 
CHICKEN_LIBOPTS =   $(SYSLIBS)
CHICKEN_SHAREDLIBOPTS =   $(SYSLIBS)
CHICKEN_CFLAGS = 
CHICKENOPTS = -quiet
CHICKEN_MAIN =

# SWIG produces $(ISRCS) (the C wrapper file) 
# and $(CHICKEN_GENERATED_SCHEME) (the Scheme wrapper file):
CHICKEN_GENERATED_SCHEME = $(INTERFACE:.i=.scm)
CHICKEN_COMPILED_SCHEME = $(INTERFACE:.i=_chicken.c)
CHICKEN_COMPILED_OBJECT = $(CHICKEN_COMPILED_SCHEME:.c=.o)

# flags for the main chicken sources (only used when compiling staticly)
CHICKEN_COMPILED_MAIN = $(CHICKEN_MAIN:.scm=_chicken.c)
CHICKEN_COMPILED_MAIN_OBJECT = $(CHICKEN_COMPILED_MAIN:.c=.o)

# -----------------------------------------------------------------
# Build a CHICKEN dynamically loadable module
# -----------------------------------------------------------------

# This is the old way to build chicken, but it does not work correctly with exceptions
chicken_direct: $(SRCS)
	$(SWIG) -chicken $(SWIGOPT) $(INCLUDE) $(INTERFACE)
	$(CHICKEN) $(CHICKEN_GENERATED_SCHEME) $(CHICKENOPTS) \
		-dynamic -feature chicken-compile-shared \
		-output-file $(CHICKEN_COMPILED_SCHEME)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(CHICKEN_CFLAGS) \
		$(INCLUDES) $(CHICKEN_INCLUDE) $(ISRCS) $(SRCS) $(CHICKEN_COMPILED_SCHEME)
	$(LDSHARED) $(CFLAGS) $(CHICKEN_COMPILED_OBJECT) $(OBJS) $(IOBJS) \
		$(LIBS) $(CHICKEN_SHAREDLIBOPTS) -o $(LIBPREFIX)$(TARGET)$(SO)

chicken_direct_cpp: $(CXXSRCS) $(CHICKSRCS)
	$(SWIG) -c++ -chicken $(SWIGOPT) $(INCLUDE) $(INTERFACE)
	$(CHICKEN) $(CHICKEN_GENERATED_SCHEME) $(CHICKENOPTS) \
		-dynamic -feature chicken-compile-shared \
		-output-file $(CHICKEN_COMPILED_SCHEME)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(CHICKEN_CFLAGS) \
		$(INCLUDES) $(CHICKEN_INCLUDE) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(CHICKEN_COMPILED_SCHEME)
	$(CXXSHARED) $(CFLAGS) $(CHICKEN_COMPILED_OBJECT) $(OBJS) $(IOBJS) \
		$(LIBS) $(CPP_DLLIBS) $(CHICKEN_SHAREDLIBOPTS) -o $(LIBPREFIX)$(TARGET)$(SO)

# -----------------------------------------------------------------
# Build statically linked CHICKEN interpreter
# -----------------------------------------------------------------

# The following two targets are also used by the test suite
chicken_static: $(SRCS) $(CHICKSRCS)
	$(SWIG) -chicken $(SWIGOPT) $(INCLUDE) $(INTERFACE)
	$(CHICKEN) $(CHICKEN_GENERATED_SCHEME) $(CHICKENOPTS) \
		-output-file $(CHICKEN_COMPILED_SCHEME)
	$(CHICKEN) $(CHICKEN_MAIN) $(CHICKENOPTS) \
		-output-file $(CHICKEN_MAIN:.scm=_chicken.c)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(CHICKEN_CFLAGS) \
		$(INCLUDES) $(CHICKEN_INCLUDE) $(ISRCS) $(SRCS) \
		$(CHICKEN_COMPILED_SCHEME) $(CHICKEN_COMPILED_MAIN)
	$(CC) $(CHICKEN_COMPILED_OBJECT) $(CHICKEN_COMPILED_MAIN_OBJECT) \
		$(OBJS) $(IOBJS) $(LIBS) $(CHICKEN_SHAREDLIBOPTS) -o $(TARGET)

chicken_static_cpp: $(CXXSRCS) $(CHICKSRCS)
	$(SWIG) -c++ -chicken $(SWIGOPT) $(INCLUDE) $(INTERFACE)
	$(CHICKEN) $(CHICKEN_GENERATED_SCHEME) $(CHICKENOPTS) \
		-output-file $(CHICKEN_COMPILED_SCHEME)
	$(CHICKEN) $(CHICKEN_MAIN) $(CHICKENOPTS) \
		-output-file $(CHICKEN_MAIN:.scm=_chicken.c)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(CHICKEN_CFLAGS) \
		$(INCLUDES) $(CHICKEN_INCLUDE) $(ICXXSRCS) $(SRCS) $(CXXSRCS) \
		$(CHICKEN_COMPILED_SCHEME) $(CHICKEN_COMPILED_MAIN)
	$(CXX) $(CHICKEN_COMPILED_OBJECT) $(CHICKEN_COMPILED_MAIN_OBJECT) \
		$(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) $(CHICKEN_SHAREDLIBOPTS) -o $(TARGET)

# ----------------------------------------------------------------
# Build a shared library using csc
# ----------------------------------------------------------------

chicken:
	$(SWIG) -chicken $(SWIGOPT) $(INCLUDE) $(INTERFACE)
	$(CHICKEN_CSC) -s `echo $(INCLUDES) | sed 's/-I/-C -I/g'` $(CHICKEN_GENERATED_SCHEME) $(SRCS) $(ISRCS) -o $(TARGET)$(SO)

chicken_cpp:
	$(SWIG) -c++ -chicken $(SWIGOPT) $(INCLUDE) $(INTERFACE)
	$(CHICKEN_CSC) -s `echo $(INCLUDES) | sed 's/-I/-C -I/g'` $(CHICKEN_GENERATED_SCHEME) $(SRCS) $(ICXXSRCS) $(CXXSRCS) -o $(TARGET)$(SO)

chicken_externalhdr:
	$(SWIG) -chicken -external-runtime $(TARGET)

chicken_clean:
	rm -f *_wrap* *~ .~* *_chicken*
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      CSHARP                           ######
##################################################################

# Extra CSharp specific dynamic linking options
CSHARP_DLNK  = 
CSHARP_LIBPREFIX = lib
CSHARPCOMPILER = 
CSHARPCILINTERPRETER = 
CSHARPCFLAGS = 
CSHARPSO = .so

# ----------------------------------------------------------------
# Build a CSharp dynamically loadable module (C)
# ----------------------------------------------------------------

csharp: $(SRCS)
	$(SWIG) -csharp $(SWIGOPT) $(INTERFACE)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(CSHARPCFLAGS) $(SRCS) $(ISRCS) $(INCLUDES)
	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(CSHARP_DLNK) $(LIBS) -o $(CSHARP_LIBPREFIX)$(TARGET)$(CSHARPSO)

# ----------------------------------------------------------------
# Build a CSharp dynamically loadable module (C++)
# ----------------------------------------------------------------

csharp_cpp: $(SRCS)
	$(SWIG) -csharp -c++ $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(CSHARPCFLAGS) $(SRCS) $(CXXSRCS) $(ICXXSRCS) $(INCLUDES)
	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(CSHARP_DLNK) $(LIBS) $(CPP_DLLIBS) -o $(CSHARP_LIBPREFIX)$(TARGET)$(CSHARPSO)

# ----------------------------------------------------------------
# Compile CSharp files
# ----------------------------------------------------------------

csharp_compile: $(SRCS)
	$(COMPILETOOL) $(CSHARPCOMPILER) $(CSHARPFLAGS) $(CSHARPSRCS)

# -----------------------------------------------------------------
# Cleaning the CSharp examples
# -----------------------------------------------------------------

csharp_clean:
	rm -f *_wrap* *~ .~* runme runme.exe *.exe.mdb gc.log `find . -name \*.cs | grep -v runme.cs`
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      LUA                              ######
##################################################################

# lua flags
LUA_INCLUDE= 
LUA_LIB    =  -llualib

# Extra specific dynamic linking options
LUA_DLNK   = 
LUA_SO     = .so

# Extra code for lua static link
LUA_INTERP     = ../lua.c

# ----------------------------------------------------------------
# Build a C dynamically loadable module
# ----------------------------------------------------------------

lua: $(SRCS)
	$(SWIG) -lua $(SWIGOPT) $(INTERFACE)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(ISRCS) $(SRCS) $(INCLUDES) $(LUA_INCLUDE)
	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(LUA_LIB) -o $(LIBPREFIX)$(TARGET)$(LUA_SO)

# -----------------------------------------------------------------
# Build a C++ dynamically loadable module
# -----------------------------------------------------------------

lua_cpp: $(SRCS)
	$(SWIG) -c++ -lua $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) $(LUA_INCLUDE)
	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(LUA_LIB) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(LUA_SO)

# -----------------------------------------------------------------
# Build statically linked Lua interpreter
# -----------------------------------------------------------------

lua_static: $(SRCS)
	$(SWIG) -lua -module example $(SWIGOPT) $(INTERFACE)
	$(CC) $(CFLAGS)  $(ISRCS) $(SRCS) $(LUA_INTERP) $(INCLUDES) \
	$(LUA_INCLUDE) $(LIBS) $(LUA_LIB) -o $(TARGET)

lua_static_cpp: $(SRCS)
	$(SWIG) -c++ -lua -module example $(SWIGOPT) $(INTERFACE)
	$(CXX) $(CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(LUA_INTERP) $(INCLUDES) \
	$(LUA_INCLUDE) $(LIBS)  $(LUA_LIB) -o $(TARGET)

# -----------------------------------------------------------------
# Cleaning the lua examples
# -----------------------------------------------------------------

lua_clean:
	rm -f *_wrap* *~ .~* mylua
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                   ALLEGRO CL                          ######
##################################################################

allegrocl: $(SRCS)
	$(SWIG) -allegrocl -cwrap $(SWIGOPT) $(INTERFACE)
	$(CC) -c $(CCSHARED) $(CFLAGS) $(ISRCS) $(INCLUDES) $(SRCS) 
	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

allegrocl_cpp: $(SRCS)
	$(SWIG) -c++ -allegrocl $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) 
	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

allegrocl_clean:
	rm -f *_wrap* *~ .~*
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      CLISP                            ######
##################################################################

clisp: $(SRCS)
	$(SWIG) -clisp $(SWIGOPT) $(INTERFACE)

clisp_cpp: $(SRCS)
	$(SWIG) -c++ -clisp $(SWIGOPT) $(INTERFACE)

clisp_clean:
	rm -f *_wrap* *~ .~*
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      CFFI                             ######
##################################################################

cffi: $(SRCS)
	$(SWIG) -cffi $(SWIGOPT) $(INTERFACE)
#	$(CC) -c $(CCSHARED) $(CFLAGS) $(ISRCS) $(INCLUDES) $(SRCS) 
#	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

cffi_cpp: $(SRCS)
	$(SWIG) -c++ -cffi $(SWIGOPT) $(INTERFACE)
	$(CXX) -c $(CCSHARED) $(CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) 
	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

cffi_clean:
	rm -f *_wrap* *~ .~*
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      UFFI                             ######
##################################################################

uffi: $(SRCS)
	$(SWIG) -uffi $(SWIGOPT) $(INTERFACE)
#	$(CC) -c $(CCSHARED) $(CFLAGS) $(ISRCS) $(INCLUDES) $(SRCS) 
#	$(LDSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

uffi_cpp: $(SRCS)
	$(SWIG) -c++ -uffi $(SWIGOPT) $(INTERFACE)
#	$(CXX) -c $(CCSHARED) $(CFLAGS) $(ICXXSRCS) $(SRCS) $(CXXSRCS) $(INCLUDES) 
#	$(CXXSHARED) $(CFLAGS) $(OBJS) $(IOBJS) $(LIBS) $(CPP_DLLIBS) -o $(LIBPREFIX)$(TARGET)$(SO)

uffi_clean:
	rm -f *_wrap* *~ .~*
	rm -f core 
	rm -f *.o *.so

##################################################################
#####                      R                                ######
##################################################################

R = R
RCXXSRCS = $(INTERFACE:.i=_wrap.cpp) #Need to use _wrap.cpp for R build system as it does not understand _wrap.cxx
RRSRC = $(INTERFACE:.i=.R)

r: $(SRCS)
	$(SWIG) -r $(SWIGOPT) $(INTERFACE)
	+( PKG_LIBS="$(SRCS)" PKG_CPPFLAGS="$(INCLUDES)" $(R) CMD SHLIB -o $(LIBPREFIX)$(TARGET)$(SO) $(ISRCS) )

r_cpp: $(CXXSRCS)
	$(SWIG) -c++ -r $(SWIGOPT) -o $(RCXXSRCS) $(INTERFACE)
	+( PKG_LIBS="$(CXXSRCS)" PKG_CPPFLAGS="$(INCLUDES)" $(R) CMD SHLIB -o $(LIBPREFIX)$(TARGET)$(SO) $(RCXXSRCS) )

r_clean:
	rm -f *_wrap* *~ .~*
	rm -f core 
	rm -f *.o *.so NAMESPACE
	rm -f $(RRSRC) runme.Rout .RData

