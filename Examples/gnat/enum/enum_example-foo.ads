-- This file is generated by SWIG. Please do *not*
--modify by hand.
--
with Interfaces.C.Pointers;
with Interfaces.C.Strings;
with System;
package enum_example.Foo is

   -- Item
   --

   type Item is record
      null;
   end record;

   -- Items
   --
   type Items is
     array (Interfaces.C.size_t range <>) of aliased enum_example.Foo.Item;

   -- Pointers.Pointer
   --

   -- Pointer
   --
   type Pointer is access all enum_example.Foo.Item;

   -- Pointers
   --
   type Pointers is
     array (Interfaces.C.size_t range <>) of aliased enum_example.Foo.Pointer;

   -- Pointer_Pointers.Pointer
   --

   -- Pointer_Pointer
   --
   type Pointer_Pointer is access all enum_example.Foo.Pointer;

   -- speed
   --
   type speed is (IMPULSE, WARP, LUDICROUS);

   for speed use (IMPULSE => 10, WARP => 20, LUDICROUS => 30);

   pragma Convention (C, speed);

   type speed_array is
     array (Interfaces.C.size_t range <>) of aliased enum_example.Foo.speed;

   -- speed_Pointers.Pointer
   --

   -- speed_Pointer
   --
   type speed_Pointer is access all enum_example.Foo.speed;

   -- speed_Pointers
   --
   type speed_Pointers is
     array (Interfaces.C.size_t range <>)
            of aliased enum_example.Foo.speed_Pointer;

   -- speed_Pointer_Pointers.Pointer
   --

   -- speed_Pointer_Pointer
   --
   type speed_Pointer_Pointer is access all enum_example.Foo.speed_Pointer;

   function construct return  enum_example.Foo.Item;

   procedure enum_test
     (Self : in enum_example.Foo.Item;
      s    : in enum_example.Foo.speed);

private

   pragma Import (C, construct, "Ada_new_Foo");
   pragma Import (C, enum_test, "Ada_Foo_enum_test");

end enum_example.Foo;
