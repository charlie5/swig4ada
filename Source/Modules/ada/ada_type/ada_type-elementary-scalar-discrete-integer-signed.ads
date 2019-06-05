
package ada_Type.elementary.scalar.discrete.integer.signed
--
-- Models a signed integer type.
--
is

   type Item is new ada_Type.elementary.scalar.discrete.integer.item with private;

   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;


   --  Containers
   --
   package Vectors is new ada.Containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;


   --  Forge
   --
   function new_Item  (declaration_Package : access ada_Package.item'Class := null;
                       Name                : in     unbounded_String       := null_unbounded_String) return View;



private

   type Item is new ada_Type.elementary.scalar.discrete.integer.item with
      record
         null;
      end record;

end ada_Type.elementary.scalar.discrete.integer.signed;

