-- This file is generated by SWIG. Please do *not* modify by hand.
--
with interfaces.C;
with interfaces.C.Pointers;

package swigmod.Pointers is

   -- DoxygenTranslator_Pointer
   --
   package C_DoxygenTranslator_Pointers is new interfaces.c.Pointers
     (Index => interfaces.c.size_t, Element => swigmod.DoxygenTranslator,
      element_Array      => swigmod.DoxygenTranslator_Array,
      default_Terminator => 0);

   subtype DoxygenTranslator_Pointer is C_DoxygenTranslator_Pointers.Pointer;

   -- DoxygenTranslator_Pointer_Array
   --
   type DoxygenTranslator_Pointer_Array is
     array
       (interfaces.C.Size_t range <>) of aliased swigmod.Pointers
       .DoxygenTranslator_Pointer;

   -- Status_Pointer
   --
   package C_Status_Pointers is new interfaces.c.Pointers
     (Index              => interfaces.c.size_t, Element => swigmod.Status,
      element_Array      => swigmod.Status_Array,
      default_Terminator => swigmod.Status'Val (0));

   subtype Status_Pointer is C_Status_Pointers.Pointer;

   -- Status_Pointer_Array
   --
   type Status_Pointer_Array is
     array
       (interfaces.C.Size_t range <>) of aliased swigmod.Pointers
       .Status_Pointer;

end swigmod.Pointers;
