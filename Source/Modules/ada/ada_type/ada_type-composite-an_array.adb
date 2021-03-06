package body ada_Type.composite.an_array
is

   --  Dimensions
   --

   function are_Constrained (Self : in array_dimension_upper_Bounds) return Boolean
   is
   begin
      for Each in Self'Range
      loop
         if Self (Each) = unConstrained then
            return False;
         end if;
      end loop;

      return True;
   end are_Constrained;


   --  Forge
   --

   function new_Item (declaration_Package              : access ada_Package.item'Class      := null;
                      Name                             : in     unbounded_String            := null_unbounded_String;
                      the_array_dimension_upper_Bounds : in     array_dimension_upper_Bounds;
                      element_Type                     : in     ada_Type.view) return View
   is
   begin
      return the_Item : constant View := new Item' (declaration_Package          => declaration_Package,
                                                    Name                         => Name,
                                                    element_Type                 => element_Type,
                                                    array_dimension_Count        => the_array_dimension_upper_Bounds'Length,
                                                    array_Dimensions_upper_Bound => <>)
      do
         for Each in the_array_dimension_upper_Bounds'Range
         loop
            the_Item.array_Dimensions_upper_Bound (Each) := the_array_dimension_upper_Bounds (Each);
         end loop;
      end return;
   end new_Item;



   --  Attributes
   --

   function element_Type (Self : access Item) return ada_Type.view
   is
   begin
      return Self.element_Type;
   end element_Type;



   procedure add_array_Dimension (Self        : access Item;
                                  upper_Bound : in     Integer := Unconstrained)
   is
   begin
      Self.array_dimension_Count                                     := Self.array_dimension_Count + 1;
      Self.array_Dimensions_upper_Bound (Self.array_dimension_Count) := upper_Bound;
   end add_array_Dimension;



   function is_Unconstrained (Self : access Item) return Boolean
   is
   begin

      for Each in 1 .. Self.array_dimension_Count
      loop
         if Self.array_Dimensions_upper_Bound (Each) = Unconstrained then
            return True;
         end if;
      end loop;

      return False;
   end is_Unconstrained;



   function  array_dimension_Count (Self : access Item) return Natural
   is
   begin
      return Self.array_dimension_Count;
   end array_dimension_Count;



   function  array_Dimensions_upper_Bound (Self : access Item) return array_dimension_upper_Bounds
   is
   begin
      return Self.array_Dimensions_upper_Bound (1 .. Self.array_dimension_Count);
   end array_Dimensions_upper_Bound;


   overriding
   function  required_Types (Self : access Item) return ada_Type.views
   is
   begin
      return (1 => Self.element_Type);
   end required_Types;


   overriding
   function  context_required_Types (Self : access Item) return ada_Type.views
   is
   begin
      return (1 => Self.element_Type);
   end context_required_Types;


   overriding
   function  depends_on (Self : access Item;   a_Type : in ada_Type.view;
                                               Depth  : in Natural) return Boolean
   is
   begin
      return    Self.element_Type.all'Access = a_Type
        or else Self.element_Type.depends_on (a_Type, Depth + 1);
   end depends_on;


   overriding
   function  depends_directly_on (Self : access Item;   a_Type : in ada_Type.view;
                                                        Depth  : in Natural) return Boolean
   is
      pragma Unreferenced (Depth);
   begin
      return Self.element_Type.all'Access = a_Type;
   end depends_directly_on;


   overriding
   function  depends_on (Self : access Item;   a_Package : access ada_Package.item'Class;
                                               Depth     : in     Natural) return Boolean
   is
   begin
      return    Self.element_Type.declaration_Package = a_Package
        or else Self.element_Type.depends_on (a_Package, Depth + 1);
   end depends_on;


   overriding
   function resolved_Type (Self : access Item) return ada_Type.view
   is
   begin
      return Self.all'Access;
   end resolved_Type;


end ada_Type.composite.an_array;
