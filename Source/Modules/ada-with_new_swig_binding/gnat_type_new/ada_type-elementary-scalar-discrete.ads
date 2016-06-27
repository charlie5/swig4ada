package ada_Type.elementary.scalar.discrete
--
--
--
is

   type Item is new ada_Type.elementary.scalar.item with private;

   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;



   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;



   --  Attributes
   --

   overriding
   function required_Types         (Self : access Item)  return ada_Type.views;
   overriding
   function context_required_Types (Self : access Item)  return ada_Type.views;

   overriding
   function  depends_on            (Self : access Item;   a_Type : in ada_Type.view) return Boolean;
   overriding
   function  depends_directly_on   (Self : access Item;   a_Type : in ada_Type.view) return Boolean;

   overriding
   function depends_on             (Self : access Item;   a_Package : access ada_Package.item'class) return Boolean;



private

   type Item is new ada_Type.elementary.scalar.item with
      record
         null;
      end record;

end ada_Type.elementary.scalar.discrete;
