-- This file is generated by SWIG. Please do *not* modify by hand.
--
with interfaces.c;
with swig.pointers;
with interfaces.C;



package li_carrays.doubleArray is

   -- Item
   -- 

type Item is 
      record
          null;
      end record;



   -- Items
   -- 
   type Items is array (interfaces.C.Size_t range <>) of aliased li_carrays.doubleArray.Item;



   -- Pointer
   -- 
   type Pointer is access all li_carrays.doubleArray.Item;

   -- Pointers
   -- 
   type Pointers is array (interfaces.C.Size_t range <>) of aliased li_carrays.doubleArray.Pointer;



   -- Pointer_Pointer
   -- 
   type Pointer_Pointer is access all li_carrays.doubleArray.Pointer;






   function  getitem (Self : in li_carrays.doubleArray.Item;
index : in interfaces.c.int) return interfaces.c.double;

   procedure setitem (Self : in li_carrays.doubleArray.Item;
index : in interfaces.c.int;
value : in interfaces.c.double);

   function  cast (Self : in li_carrays.doubleArray.Item) return swig.pointers.double_Pointer;









private



   pragma Import (C, getitem, "getitem");
   pragma Import (C, setitem, "setitem");
   pragma Import (C, cast, "cast");



end li_carrays.doubleArray;
