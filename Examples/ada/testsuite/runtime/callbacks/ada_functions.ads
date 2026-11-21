with
     callbacks.Sample,
     callbacks.Listener,

     swig,
     interfaces.C.Strings;

package ada_Functions
--
-- Functions of Ada which C++ calls. They are at library level, as their addresses are given to C++.
--
is
   use callbacks,
       interfaces.C;

   function  weigh     (the_Sample : in Sample.Pointer)                    return double        with Convention => C;
   procedure collect   (Value      : in int;   Context : in swig.void_ptr)                      with Convention => C;
   function  length_of (Name       : in Strings.chars_ptr)                 return int           with Convention => C;
   function  make      (Id         : in int)                               return Sample.Item   with Convention => C;
   procedure tell      (To         : in Listener.Pointer;   What : in int)                      with Convention => C;
   procedure reset     (the_Sample : in Sample.Pointer)                                         with Convention => C;

end ada_Functions;
