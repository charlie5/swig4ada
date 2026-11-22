with
     ada.Containers;

generic
   type View is private;     -- An access type.

function pointer_Hash (Self : in View) return ada.Containers.Hash_type;
--
-- A hash of a pointer: its address, within the range of a hash.
--
