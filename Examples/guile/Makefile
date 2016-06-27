# Makefile for Guile.  Used by all of the example programs.

subdirs		= simple matrix port constants multimap multivalue

top_srcdir	= ../..
SWIG		= ../$(top_srcdir)/preinst-swig
CC		= gcc
CXX		= g++
CFLAGS		= 
GUILEINCLUDE	= 
GUILELINK	= -L -lguile
SWIGOPT		=

WRAP		= $(IFILE:.i=_wrap.c)
CXXWRAP		= $(IFILE:.i=_wrap.cxx)

SO		= .so

all:
	for d in $(subdirs) ; do (cd $$d ; $(MAKE)) ; done

clean::
	for d in $(subdirs) ; do (cd $$d ; $(MAKE) clean) ; done
	rm -f *~ .~*

guile_clean:
	rm -f *.o *$(SO) *_wrap* *~ .~* core my-guile $(TARGET)

# This is meant to be used w/ "make -f ../Makefile" from subdirs.
# Doesn't make sense to use it from here.

sub-all::
	$(SWIG) -guile $(SWIGOPT) $(IFILE)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS) $(WRAP) $(GUILEINCLUDE) $(GUILELINK)

sub-all-cxx::
	$(SWIG) -c++ -guile $(SWIGOPT) $(IFILE)
	$(CXX) $(CFLAGS) -o $(TARGET) $(SRCS) $(CXXWRAP) $(GUILEINCLUDE) $(GUILELINK)

# Makefile ends here
