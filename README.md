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
- gnatpp, and a GCC which provides C, C++ and the address sanitizer.


Install
=======

- Install the GMP and PCRE libraries for your OS.
- Install cBound to provide the GMP library Ada binding.
- Add the cBound 'tier-1/gmp/library' folder to your GPR_PROJECT_PATH
  (cBound's 'cbound-gpr_paths.sh' script sets up the paths for all of its bindings).

- $ ./build_ada_swig.sh
- $ sudo ./install_ada_swig.sh

Installs to /usr/local.


Usage
=====

    $ swig4ada -ada [-c++] [-I<dir>] [-outdir <dir>] foo.i

For a module 'foo' this writes the wrapper 'foo_wrap.c' (or 'foo_wrap.cxx') and a family of Ada specs:

- foo.ads                  ~ The top package: simple types, enumerations, constants and variables.
- foo-binding.ads          ~ The functions which are not members of a class.
- foo-<class>.ads          ~ One package for each structure or class, with its principal type 'Item'
                             and its 'Pointer', 'Item_Array' and 'Pointer_Array'.
- foo-<class>-guards.ads   ~ For a class with a virtual destructor (see 'Destructors', below).
- foo-pointers.ads         ~ Pointer types, where any are needed.

A program which uses the binding compiles the specs and the wrapper, and needs the support packages
'swig', 'swig.pointers', 'swig.guards' and (for C++ strings) 'swig.std_Strings'. These are the 'swig*.ads'
and 'swig*.adb' files at the root of this repository; they are not installed, so add that folder to the
source directories of your project. The projects under 'Examples/ada' show how.

'swig4ada-debug.log' is written to the current directory on every run.


Using a generated binding
=========================

The examples below are taken from the run-time cases of the test suite ('Examples/ada/testsuite/runtime'),
each of which is a complete, tested program.

Structures and simple classes
-----------------------------

A C structure, or a C++ class which has no virtual function and declares neither a destructor nor a copy
constructor, is an Ada record. It may be declared, copied and assigned as usual.

    P : aliased Point.Item := make_point (3, 4);
    ...
    shift (P'unchecked_Access, 10, 20);     -- void shift (Point* p, int dx, int dy);

A pointer or a reference in C or C++ is a pointer in Ada, so a variable is passed as 'X'Access' or
'X'unchecked_Access'. This holds for the simple types too: 'void increment (int& value)' is called as
'increment (I'unchecked_Access)'.

Classes which C++ constructs
----------------------------

A class which declares a destructor or a copy constructor, or has a base class or a member which does
(a 'std::string' member, or a standard container, say), is a limited record of convention CPP. Its objects
are made by its C++ constructors, and cannot be copied or assigned in Ada.

    A : aliased Buffer.Item := Buffer.construct (4);     -- Buffer (int n);
    B : aliased Buffer.Item;                             -- The default constructor is called.

A function which returns such a class by value is a procedure in Ada. Its last parameter, 'Result', points
to an object of the caller, which is replaced by the result:

    make_buffer (10, B'unchecked_Access);                -- Buffer make_buffer (int n);

Classes with virtual functions
------------------------------

A class with a virtual function is a tagged limited type, which shares the vtable of the C++ class. Calls
dispatch in both directions, a 'Pointer' may point to an object of any derived class, and a type may be
derived from the class in Ada:

    type Item is new Shape.Item with
       record
          Side : aliased double;
       end record;

    overriding
    function area (Self : access Item) return double;
    pragma Convention (CPP, area);

C++ then calls 'area' through a 'Shape*'. Such a type, and any Ada function which is given to C or C++ as a
callback, must be declared at library level, not inside a subprogram.

Only the first base class which has virtual functions becomes the parent. A base class with none becomes a
record component, and any further virtual base class is left out, with a warning.

The members which a derived class adds are read and written through functions, not as record components:

    the_Colour := Horse.coat (the_Horse'Access);         -- Colour coat;
    Horse.set_coat (the_Horse, Blue);

C++ lays such members out in a way which an Ada type extension cannot follow, so the components of the
record (named '<member>_storage') only reserve their storage, and must not be used. The members of a base
class, and of a class which is not derived, are ordinary components.

Destructors
-----------

Ada does not call the destructor of a C++ object. Call 'destruct' yourself, or, for a class with a virtual
destructor, declare a guard after the object, which calls it when the guard leaves scope:

    the_Circle : aliased Circle.Item := Circle.construct (2.0);
    the_Guard  : Circle.Guards.Guard (the_Circle'Access) with Unreferenced;

For a class with a virtual destructor, 'destruct_0' destructs the object and 'destruct' also frees it, so
'destruct' is only for an object which was allocated by C++ 'new'.

Strings and containers
----------------------

A 'std::string' is 'swig.std_Strings.std_String'. The interface file must '%include <std_string.i>', which
adds to the wrapper the functions which that package imports.

    Name   : aliased std_String := to_std_String (to_C ("Ada"));
    Result : aliased std_String;
    ...
    greeting (Name, Result'unchecked_Access);            -- std::string greeting (std::string name);
    put_Line (to_Ada (Result));
    destruct (Result);
    destruct (Name);

'std_vector.i', 'std_list.i', 'std_deque.i', 'std_set.i', 'std_multiset.i', 'std_map.i', 'std_multimap.i',
'std_pair.i' and 'std_complex.i' provide the containers, each instantiated with '%template' as usual. They
bind the common members (size, element access, insertion and removal), and assume the GNU libstdc++.

Other things to know
--------------------

- An overloaded function keeps its name, and a default argument gives one Ada function for each form of
  the call. An operator needs a name: '%rename (plus) Money::operator+;'.
- A static member function is a function of the package of its class.
- 'operator->' is the function 'dereference', and the functions of the class which a smart pointer points
  to are also functions of the smart pointer.
- A class of a namespace has its package directly under the module, as namespaces are not kept.
- A C++ exception does not reach Ada. A wrapper which catches one (see '%catches') records it, and the
  call returns. The record is read with the C functions 'swig_ada_pending_exception',
  'swig_ada_pending_exception_text' and 'swig_ada_clear_pending_exception', which a program imports for
  itself.
- A wrapper calls the protected members of a class, so a C++ wrapper is compiled with access opened to it:
  by 'g++ -fno-access-control', or by '#define protected public' ahead of the class in the interface file.

Limitations
-----------

- Multiple inheritance from more than one class with virtual functions.
- Static member variables.
- A class which is derived from a virtual class and is itself a template instance may not link its
  destructor.
- Directors.


Test Suite
==========

- Add the lace and aShell library folders to your GPR_PROJECT_PATH.

- $ cd Examples/ada/testsuite
- $ gprbuild -P testsuite.gpr
- $ ./launch_testsuite

The launcher runs the generator over the interface files of the SWIG test suite, and checks that each
case generates, that its specs compile and that its wrapper compiles. It then builds and runs the cases
under 'runtime', each of which binds a small C or C++ library and tests the binding from Ada. These are
built with the address sanitizer of GCC.

The launcher uses the installed library files, so install before running it, or set the 'SWIG_LIB'
environment variable to the 'Lib' folder of this repository.
