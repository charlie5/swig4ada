-- This file is generated by SWIG. Please do *not* modify by hand.
--
with Interfaces.C;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;
package simple_example.Binding is

   function gcd
     (x : in Interfaces.C.int;
      y : in Interfaces.C.int) return Interfaces.C.int;

private

   pragma Import (C, gcd, "gcd");

end simple_example.Binding;
