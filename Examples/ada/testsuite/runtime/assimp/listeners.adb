package body Listeners
is

   overriding
   function Update (Self : access Progress;   percentage : in interfaces.C.C_float) return swig.bool
   is
   begin
      Self.Calls := Self.Calls + 1;
      Self.Last  := percentage;
      return 1;     -- Carry on with the import.
   end Update;



   overriding
   procedure write (Self : in out Log;   message : in interfaces.C.Strings.chars_ptr)
   is
      pragma Unreferenced (message);
   begin
      Self.Messages := Self.Messages + 1;
   end write;

end Listeners;
