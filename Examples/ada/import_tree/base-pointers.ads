-- This file is generated by SWIG. Please do *not* modify by hand.
--
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;
package base.Pointers is

   -- gdouble_Pointer
   --
   type gdouble_Pointer is access all base.gdouble;

   -- gdouble_Pointers
   --
   type gdouble_Pointers is
     array
       (Interfaces.C.size_t range <>) of aliased base.Pointers.gdouble_Pointer;

end base.Pointers;