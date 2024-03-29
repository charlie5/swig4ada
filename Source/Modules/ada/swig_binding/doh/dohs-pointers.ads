-- This file is generated by SWIG. Please do not modify by hand.
--
with interfaces.C;
with interfaces.C.Pointers;

package DOHs.Pointers is

   -- DOH_Pointer
   --
   package C_DOH_Pointers is new interfaces.c.Pointers
     (Index         => interfaces.c.size_t, Element => DOHs.DOH,
      element_Array => DOHs.DOH_Array, default_Terminator => 0);

   subtype DOH_Pointer is C_DOH_Pointers.Pointer;

   -- DOH_Pointer_Array
   --
   type DOH_Pointer_Array is
     array (interfaces.C.Size_t range <>) of aliased DOHs.Pointers.DOH_Pointer;

   -- DohFuncPtr_t_Pointer
   --
   package C_DohFuncPtr_t_Pointers is new interfaces.c.Pointers
     (Index         => interfaces.c.size_t, Element => DOHs.DohFuncPtr_t,
      element_Array => DOHs.DohFuncPtr_t_Array, default_Terminator => 0);

   subtype DohFuncPtr_t_Pointer is C_DohFuncPtr_t_Pointers.Pointer;

   -- DohFuncPtr_t_Pointer_Array
   --
   type DohFuncPtr_t_Pointer_Array is
     array
       (interfaces.C.Size_t range <>) of aliased DOHs.Pointers
       .DohFuncPtr_t_Pointer;

end DOHs.Pointers;
