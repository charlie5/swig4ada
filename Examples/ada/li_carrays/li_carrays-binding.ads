-- This file is generated by SWIG. Please do *not* modify by hand.
--
with interfaces.c;
with li_carrays.AB;
with swig.pointers;
with interfaces.C;



package li_carrays.Binding is






   function  new_intArray (nelements : in interfaces.c.int) return swig.pointers.int_Pointer;

   procedure delete_intArray (ary : in swig.pointers.int_Pointer);

   function  intArray_getitem (ary : in swig.pointers.int_Pointer;
index : in interfaces.c.int) return interfaces.c.int;

   procedure intArray_setitem (ary : in swig.pointers.int_Pointer;
index : in interfaces.c.int;
value : in interfaces.c.int);

   function  new_ABArray (nelements : in interfaces.c.int) return li_carrays.AB.Pointer;

   procedure delete_ABArray (ary : in li_carrays.AB.Pointer);

   function  ABArray_getitem (ary : in li_carrays.AB.Pointer;
index : in interfaces.c.int) return li_carrays.AB.Item;

   procedure ABArray_setitem (ary : in li_carrays.AB.Pointer;
index : in interfaces.c.int;
value : in li_carrays.AB.Item);









private



   pragma Import (C, new_intArray, "new_intArray");
   pragma Import (C, delete_intArray, "delete_intArray");
   pragma Import (C, intArray_getitem, "intArray_getitem");
   pragma Import (C, intArray_setitem, "intArray_setitem");
   pragma Import (C, new_ABArray, "new_ABArray");
   pragma Import (C, delete_ABArray, "delete_ABArray");
   pragma Import (C, ABArray_getitem, "ABArray_getitem");
   pragma Import (C, ABArray_setitem, "ABArray_setitem");



end li_carrays.Binding;