package body Greeters
is

   overriding
   function say_hi (Self : access Yo_Sayer;
                    h    : in     Hallo) return Hallo
   is
      pragma Unreferenced (Self, h);
   begin
      return yo;
   end say_hi;

end Greeters;
