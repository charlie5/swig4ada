package body Callbacks
is

   function multiply (a : in swig.Pointers.int_Pointer;
                      b : in int) return int
   is
   begin
      return a.all * b;
   end multiply;

end Callbacks;
