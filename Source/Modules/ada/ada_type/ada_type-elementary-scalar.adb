package body ada_Type.elementary.scalar
is

   overriding
   function depends_directly_on   (Self : access Item;   a_Type : in ada_Type.view;
                                                         Depth  : in Natural) return Boolean
   is
      pragma Unreferenced (Self, a_Type, Depth);
   begin
      return False;
   end depends_directly_on;


   overriding
   function resolved_Type (Self : access Item) return ada_Type.view
   is
   begin
      return Self.all'Access;
   end resolved_Type;


end ada_Type.elementary.scalar;
