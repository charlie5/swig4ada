package ada_Type.composite.an_array
--
-- Models an Ada array.
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


   --  Dimensions
   --
   unConstrained : constant := -1;

   type array_dimension_upper_Bounds is array (Positive range <>) of Integer;

   function are_Constrained (Self : in array_dimension_upper_Bounds) return Boolean;


   --  Forge
   --
   function new_Item (declaration_Package              : access ada_Package.item'Class      := null;
                      Name                             : in     unbounded_String            := null_unbounded_String;
                      the_array_dimension_upper_Bounds : in     array_dimension_upper_Bounds;
                      element_Type                     : in     ada_Type.view) return View;


   --  Attributes
   --
   function  element_Type (Self : access Item) return ada_Type.view;

   procedure add_array_Dimension          (Self : access Item;   upper_Bound : in Integer := unConstrained);
   function  is_Unconstrained             (Self : access Item) return Boolean;
   function  array_dimension_Count        (Self : access Item) return Natural;
   function  array_Dimensions_upper_Bound (Self : access Item) return array_dimension_upper_Bounds;

   overriding
   function  context_required_Types
                            (Self : access Item) return ada_Type.views;
   overriding
   function  required_Types (Self : access Item) return ada_Type.views;

   overriding
   function  depends_on     (Self : access Item;   a_Type    : in     ada_Type.view;
                                                   Depth     : in     Natural) return Boolean;
   overriding
   function  depends_directly_on
                            (Self : access Item;   a_Type    : in     ada_Type.view;
                                                   Depth     : in     Natural) return Boolean;
   overriding
   function  depends_on     (Self : access Item;   a_Package : access ada_Package.item'Class;
                                                   Depth     : in     Natural) return Boolean;
   overriding
   function resolved_Type   (Self : access Item) return ada_Type.view;



private

   type Item is new ada_Type.composite.item with
      record
         element_Type : ada_Type.view;

         array_dimension_Count        : Natural := 0;
         array_Dimensions_upper_Bound : array_dimension_upper_Bounds (1 .. 100);
      end record;

end ada_Type.composite.an_array;
