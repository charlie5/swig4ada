-- This file is generated by SWIG. Please do *not* modify by hand.
--
with interfaces.c;
with interfaces.C;
with System;
private with system.Address_To_Access_Conversions;



package class_example.Shape is

   -- Item
   -- 

type Item is  tagged limited
      record
         x : aliased interfaces.c.double;
         y : aliased interfaces.c.double;
      end record;




   pragma Import (CPP, Entity => Item);




   -- Items
   -- 
   type Items is array (interfaces.C.Size_t range <>) of aliased class_example.Shape.Item;






   procedure destruct_0 (Self : in out class_example.Shape.Item);

   procedure destruct (Self : in out class_example.Shape.Item);

   procedure move (Self : in out class_example.Shape.Item'Class;
dx : in interfaces.c.double;
dy : in interfaces.c.double);

   function  area (Self : access class_example.Shape.Item) return interfaces.c.double;

   function  perimeter (Self : access class_example.Shape.Item) return interfaces.c.double;





   -- Pointer
   -- 
   type Pointer is access all class_example.Shape.Item;

   -- Pointers
   -- 
   type Pointers is array (interfaces.C.Size_t range <>) of aliased class_example.Shape.Pointer;



   -- Pointer_Pointer
   -- 
   type Pointer_Pointer is access all class_example.Shape.Pointer;







private



   pragma Import (CPP, destruct_0, "_ZN5ShapeD1Ev");
   pragma Import (CPP, destruct, "_ZN5ShapeD1Ev");
   pragma Import (CPP, move, "Ada_Shape_move");
   pragma Import (CPP, area, "Ada_Shape_area");
   pragma Import (CPP, perimeter, "Ada_Shape_perimeter");


   package conversions is new System.Address_To_Access_Conversions (Item);




end class_example.Shape;
