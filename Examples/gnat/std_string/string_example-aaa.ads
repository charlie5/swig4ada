-- This file is generated by SWIG. Do *not* modify by hand.
--
with Interfaces.C;
with Swig.Pointers;
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;
with Swig;
package string_example.aaa is

   -- Item
   --

   type Item is record
      Rank : aliased Interfaces.C.int;
      Name : aliased Swig.Pointers.std_string;
      Age  : aliased Interfaces.C.int;
   end record;

   type Item_array is
     array (Interfaces.C.size_t range <>)
            of aliased string_example.aaa.Item;

   -- Pointers.Pointer
   --

   -- Pointer
   --
   type Pointer is access all string_example.aaa.Item;

   type Pointer_array is
     array (Interfaces.C.size_t range <>)
            of aliased string_example.aaa.Pointer;

   -- pointer_Pointers.Pointer
   --

   -- pointer_Pointer
   --
   type pointer_Pointer is access all string_example.aaa.Pointer;

   function construct return  string_example.aaa.Item;

private

   pragma Import (C, construct, "Ada_new_aaa");

end string_example.aaa;
