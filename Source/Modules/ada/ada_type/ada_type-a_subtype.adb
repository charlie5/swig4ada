with
     ada_Type.elementary.an_access.to_type.interfaces_c_pointer,
     ada_Type.composite.an_array,
     ada_Package;


package body ada_Type.a_subType
is
   --  Forge
   --

   function Subtype_construct (declaration_Package : access ada_Package.item'Class := null;
                               Name                : in     unbounded_String       := null_unbounded_String;
                               base_Type           : in     ada_Type.view) return a_subType.item
   is
   begin
      return Item' (declaration_package => declaration_Package,
                    name                => Name,
                    base_type           => base_Type);
   end Subtype_construct;


   function new_Subtype (declaration_Package : access ada_Package.item'Class := null;
                         Name                : in     unbounded_String       := null_unbounded_String;
                         base_Type           : in     ada_Type.view) return a_subType.view
   is
   begin
      return new Item' (Subtype_construct (declaration_Package, Name, base_Type));
   end new_Subtype;


   --  Attributes
   --

   overriding
   function depends_on (Self : access Item;   a_Type : in ada_Type.view;
                                              Depth  : in Natural) return Boolean
   is
   begin
      return    Self.base_Type.all'Access = a_Type
        or else Self.base_Type.depends_on (a_Type, Depth + 1);
   end depends_on;


   overriding
   function  depends_directly_on (Self : access Item;   a_Type : in ada_Type.view;
                                                        Depth  : in Natural) return Boolean
   is
      use ada_Type.elementary.an_access.to_type;
   begin
      if Self.base_Type.all in interfaces_c_pointer.item'Class
      then   -- The subtype is declared along with an instantiation of 'interfaces.C.Pointers',
             -- which needs the accessed type and its array type to be declared beforehand.
         return        Self.base_Type.all'Access = a_Type
               or else Self.base_Type.depends_directly_on (a_Type, Depth)
               or else (         a_Type.all in ada_Type.composite.an_array.item'Class                          -- The array type of the
                        and then    ada_Type.composite.an_array.view (a_Type).element_Type                     -- accessed type.
                                  = interfaces_c_pointer.view (Self.base_Type).accessed_Type);
      end if;

      return Self.base_Type.all'Access = a_Type;
   end depends_directly_on;


   overriding
   function depends_on (Self : access Item;   a_Package : access ada_Package.item'Class;
                                              Depth     : in     Natural) return Boolean
   is
   begin
      return    Self.base_Type.declaration_Package = a_Package
        or else Self.base_Type.depends_on (a_Package, Depth + 1);
   end depends_on;


   overriding
   function  context_required_Types (Self : access Item) return ada_Type.views
   is
   begin
      return [1 => Self.base_Type];
   end context_required_Types;


   overriding
   function required_Types (Self : access Item) return ada_Type.views
   is
   begin
      return [1 => Self.base_Type];
   end required_Types;


   function base_Type (Self : access Item) return ada_Type.view
   is
   begin
      return Self.base_Type;
   end base_Type;


   overriding
   function resolved_Type (Self : access Item) return ada_Type.view
   is
   begin
      return Self.base_Type.resolved_Type;
   end resolved_Type;

end ada_Type.a_subType;
