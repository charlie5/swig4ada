-- This file is generated by SWIG. Please do *not*
--modify by hand.
--
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;
package enum_example is

   -- color
   --
   type color is (RED, BLUE, GREEN);

   for color use (RED => 0, BLUE => 1, GREEN => 2);

   pragma Convention (C, color);

   type color_array is
     array (Interfaces.C.size_t range <>) of aliased enum_example.color;

end enum_example;