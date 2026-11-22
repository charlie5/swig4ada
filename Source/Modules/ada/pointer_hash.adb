with
     ada.unchecked_Conversion,
     system.storage_Elements;

function pointer_Hash (Self : in View) return ada.Containers.Hash_type
is
   function to_Integer is new ada.unchecked_Conversion (View, system.storage_Elements.Integer_Address);
begin
   return ada.Containers.Hash_type'Mod (to_Integer (Self));
end pointer_Hash;
