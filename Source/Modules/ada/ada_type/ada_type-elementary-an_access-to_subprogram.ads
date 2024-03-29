with
     ada_subprogram;


package ada_Type.elementary.an_access.to_subProgram
--
-- Models a 'subprogram access' type.
--
is

   type Item  is new ada_Type.elementary.an_access.item with private;

   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;


   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;


   --  Forge
   --

   function new_Item (declaration_Package : access ada_Package.item'class := null;
                      Name                : in     unbounded_String       := null_unbounded_String;
                      accessed_subProgram : in     ada_subProgram.view) return View;


   --  Attributes
   --

   function accessed_subProgram     (Self : in     Item'Class) return ada_subProgram.view;

   overriding
   function  depends_on             (Self : access Item;   a_Type    : in     ada_Type.view;
                                                           Depth     : in     Natural) return Boolean;
   overriding
   function  depends_directly_on    (Self : access Item;   a_Type    : in     ada_Type.view;
                                                           Depth     : in     Natural) return Boolean;
   overriding
   function  depends_on             (Self : access Item;   a_Package : access ada_Package.item'Class;
                                                           Depth     : in     Natural) return Boolean;
   overriding
   function  required_Types         (Self : access Item) return ada_Type.views;

   overriding
   function  context_required_Types (Self : access Item) return ada_Type.views;

   overriding
   function  resolved_Type          (Self : access Item) return ada_Type.view;



private

   type Item is new ada_Type.elementary.an_access.item with
      record
         accessed_subProgram : ada_subProgram.view;           -- The base subProgram to which the access refers.
      end record;

end ada_Type.elementary.an_access.to_subProgram;
