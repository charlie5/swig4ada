with
     swig,
     interfaces.C;

package Callbacks
--
-- An Ada function which C calls. It is at library level, as its address is given to C.
--
is
   use interfaces.C;

   function add_to (Value : in int;   Context : in swig.void_ptr) return int
     with Convention => C;
   --
   -- Returns the value plus the 'int' which the context points to.

end Callbacks;
