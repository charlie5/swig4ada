
package body ada_Type.elementary.scalar.discrete.integer.signed
is

   --  Forge
   --

   function new_Item  (declaration_Package : access ada_Package.item'Class := null;
                       Name                : in     unbounded_String       := null_unbounded_String) return View
   is
   begin
      return new Item' (declaration_Package => declaration_Package,
                        Name                => Name);
   end new_Item;

end ada_Type.elementary.scalar.discrete.integer.signed;

