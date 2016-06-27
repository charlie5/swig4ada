package ada_Type.elementary.scalar
--
--
--
is

   type Item is abstract new ada_Type.elementary.item with private;

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
   function  depends_directly_on (Self : access Item;   a_Type    : in     ada_Type.view;
                                                        Depth     : in     Natural) return Boolean;

   overriding
   function  resolved_Type       (Self : access Item) return ada_Type.view;



private

   type Item is abstract new ada_Type.elementary.item with
      record
         null;
      end record;

end ada_Type.elementary.scalar;

