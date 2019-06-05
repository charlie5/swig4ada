package ada_Type.elementary.scalar.real.fixed.ordinary
--
-- Models a simple fixed point real type.
--
is

   type Item is new ada_Type.elementary.scalar.real.fixed.item with private;

   type View  is access all Item;
   type Views is array (Positive range <>) of View;


   --  Containers
   --

   package Vectors is new ada.Containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;


private

   type Item is new ada_Type.elementary.scalar.real.fixed.item with
      record
         null;
      end record;

end ada_Type.elementary.scalar.real.fixed.ordinary;

