package ada_Type.elementary.an_access
--
--
--
is

   type Item  is abstract new ada_Type.elementary.item with private;

   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;



   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;



private

   type Item is abstract new ada_Type.elementary.item with
      record
         null; -- accessed_Type : ada_Type.view;           -- the base type to which the access refers
      end record;

end ada_Type.elementary.an_access;

