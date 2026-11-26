with
     swig.Pointers,
     interfaces.C;

package Callbacks
--
--  A function of Ada which C++ calls through a pointer to it, of the type of those of 'funcptr_cpp' which take a
--  reference.
--
is
   use interfaces.C;

   function multiply (a : in swig.Pointers.int_Pointer;
                      b : in int) return int
     with Convention => C;

end Callbacks;
