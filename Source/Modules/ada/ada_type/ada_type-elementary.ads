package ada_Type.elementary
--
-- Models any elemementary type.
--
is

   type Item  is abstract new ada_Type.item with private;

   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;


   --  Containers
   --

   package Vectors is new ada.Containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;


private

   type Item is abstract new ada_Type.item with
      record
         null;
      end record;

end ada_Type.elementary;
