package body ada_Type.elementary.scalar.real.float
is

   --  Forge
   --

   function new_Item (declaration_Package : access ada_Package.item'class := null;
                      Name                : in     unbounded_String       := null_unbounded_String) return View
   is
   begin
      return new Item'(declaration_Package => declaration_Package,
                       name                => Name);
   end new_Item;


end ada_Type.elementary.scalar.real.float;

