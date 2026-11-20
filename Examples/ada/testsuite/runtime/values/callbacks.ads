with
     interfaces.C;

package Callbacks
--
-- An Ada function which C++ calls. It is at library level, as its address is given to C++.
--
is
   use interfaces.C;

   function multiply (a, b : in int) return int
     with Convention => C;

end Callbacks;
