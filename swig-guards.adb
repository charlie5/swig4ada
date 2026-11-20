package body swig.Guards
is

   overriding
   procedure finalize (Self : in out Guard)
   is
   begin
      destruct (Self.Target.all);     -- Dispatches to the destructor of the target's own class.
   end finalize;

end swig.Guards;
