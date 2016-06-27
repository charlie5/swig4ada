with
     ada.Containers.Vectors;

limited
with
     ada_Package;


package ada_Type.a_subType
is

   type Item  is new ada_Type.item with private;

   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;



   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;




   --  Forge
   --

   function new_Subtype       (declaration_Package : access ada_Package.item'Class := null;
                               Name                : in     unbounded_String       := null_unbounded_String;
                               base_Type           : in     ada_Type.view) return a_subType.view;

   function Subtype_construct (declaration_Package : access ada_Package.item'Class := null;
                               Name                : in     unbounded_String       := null_unbounded_String;
                               base_Type           : in     ada_Type.view) return a_subType.item'Class;



   --  Attributes
   --

   overriding
   function  required_Types         (Self : access Item) return ada_Type.views;
   overriding
   function  context_required_Types (Self : access Item) return ada_Type.views;

   overriding
   function  depends_on            (Self : access Item;   a_Type    : in     ada_Type.view;
                                                          Depth     : in     Natural) return Boolean;
   overriding
   function  depends_directly_on   (Self : access Item;   a_Type    : in     ada_Type.view;
                                                          Depth     : in     Natural) return Boolean;

   overriding
   function  depends_on             (Self : access Item;   a_Package : access ada_Package.item'Class;
                                                           Depth     : in     Natural) return Boolean;

   function  base_Type              (Self : access Item) return ada_Type.view;
   overriding
   function  resolved_Type          (Self : access Item) return ada_Type.view;



   --  Operations
   --

   overriding
   procedure verify (Self : access Item) is null;




private

   type Item is new ada_Type.item with
      record
         base_Type : ada_Type.view;           -- The base type of the typedef (ie, the 'int' in   'typedef  int  Index_Type;').
      end record;

end ada_Type.a_subType;
