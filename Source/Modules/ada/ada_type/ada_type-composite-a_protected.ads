package ada_Type.composite.a_protected
--
-- Models an Ada 'protected' type.
--
is

   type Item is new ada_Type.composite.item with private;

   type View  is access all Item;
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
   function depends_on             (Self : access Item;   a_Type    : in     ada_Type.view;
                                                          Depth     : in     Natural) return Boolean;
   overriding
   function depends_directly_on    (Self : access Item;   a_Type    : in     ada_Type.view;
                                                          Depth     : in     Natural) return Boolean;
   overriding
   function depends_on             (Self : access Item;   a_Package : access ada_Package.item'Class;
                                                          Depth     : in     Natural) return Boolean;
   overriding
   function resolved_Type          (Self : access Item) return ada_Type.view;



private

   type Item is new ada_Type.composite.item with
      record
         null;
      end record;

end ada_Type.composite.a_protected;

