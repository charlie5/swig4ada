package body ada_Type.elementary.an_access.to_type.interfaces_c_pointer
is



   --  Forge
   --

   function new_Item (declaration_Package : access ada_Package.item'class := null;
                      Name                : in     unbounded_String       := null_unbounded_String;
                      accessed_Type       : in ada_Type.view) return View
   is
   begin
      return new ada_Type.elementary.an_access.to_type.interfaces_c_pointer.item'(declaration_Package   => declaration_Package,
                                                                                  Name                  => Name,
                                                                                  accessed_Type         => accessed_Type,
                                                                                  associated_array_Type => <>);
   end new_Item;




   --  Attributes
   --

   procedure associated_array_Type_is (Self : access Item;   Now : in ada_Type.view)
   is
   begin
      Self.associated_array_Type := Now;
   end associated_array_Type_is;



   function required_Types (Self : in Item) return ada_Type.views
   is
   begin
      return (1 => Self.accessed_Type);
   end required_Types;



   overriding function context_required_Types (Self : access Item)  return ada_Type.views
   is
   begin
      return (1 => Self.accessed_Type);
   end context_required_Types;



   overriding function depends_on (Self : access Item;   a_Type : in     ada_Type.view) return Boolean
   is
   begin
      return    Self.accessed_Type.all'Access = a_Type
        or else Self.accessed_Type.depends_on (a_Type)

        or else Self.associated_array_Type.all'Access = a_Type
        or else Self.associated_array_Type.depends_on (a_Type);
   end depends_on;



   overriding function depends_directly_on (Self : access Item;   a_Type : in     ada_Type.view) return Boolean
   is
   begin
      return    Self.accessed_Type        .all'Access = a_Type
        or else Self.associated_array_Type.all'Access = a_Type;
   end depends_directly_on;


end ada_Type.elementary.an_access.to_type.interfaces_c_pointer;
