Swig4Ada
========

Provides a SWIG module to generate Ada bindings.

The companion project 'cBound' (link below) provides bindings to several common C libraries
produced by Swig4Ada.


Dependencies
============

- GNAT and gprbuild.
- GMP library.
- PCRE library (the original 'libpcre', not 'pcre2').
- GMP Ada Binding ~ Available at https://github.com/charlie5/cBound

The test suite (optional) also requires:

- lace    ~ Available at https://github.com/charlie5/lace      (the 'lace_environ' project).
- aShell  ~ Available at https://github.com/charlie5/aShell
- Florist ~ The POSIX Ada binding ('lib_florist' project).


Install
=======

- Install the GMP and PCRE libraries for your OS.
- Install cBound to provide the GMP library Ada binding.
- Add the cBound 'tier-1/gmp/library' folder to your GPR_PROJECT_PATH
  (cBound's 'cbound-gpr_paths.sh' script sets up the paths for all of its bindings).

- $ ./build_ada_swig.sh
- $ sudo ./install_ada_swig.sh

Installs to /usr/local.


Test Suite
==========

- Add the lace and aShell library folders to your GPR_PROJECT_PATH.

- $ cd Examples/ada/testsuite
- $ gprbuild -P testsuite.gpr
- $ ./launch_testsuite
