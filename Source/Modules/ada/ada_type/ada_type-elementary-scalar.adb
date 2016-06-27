package body ada_Type.elementary.scalar
is

   overriding
   function  depends_directly_on   (Self : access Item;   a_Type    : in     ada_Type.view;
                                                          Depth     : in     Natural) return Boolean
   is
      pragma Unreferenced (Self, a_Type, Depth);
   begin
      return False;
   end depends_directly_on;



   overriding
   function resolved_Type (Self : access Item) return ada_Type.view
   is
   begin
      --  log ("'ultimate_base_Type' ~ c_type_Kind: '" & a_c_type_kind'Image (self.my.c_type_Kind) & "'");

--        if self.declaration_Package.Kind = header_Import then
      return Self.all'Access;
--        else
--           return Self.all'access;
--        end if;
   end resolved_Type;


end ada_Type.elementary.scalar;
