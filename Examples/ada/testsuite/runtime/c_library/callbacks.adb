package body Callbacks
is

   function add_to (Value : in int;   Context : in swig.void_ptr) return int
   is
      Offset : int with Import, Address => Context;
   begin
      return Value + Offset;
   end add_to;

end Callbacks;
