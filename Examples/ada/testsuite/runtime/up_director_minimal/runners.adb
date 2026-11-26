package body Runners
is

   overriding
   function run (Self : access Always) return swig.bool
   is
      pragma Unreferenced (Self);
   begin
      return swig.bool'Val (1);
   end run;

end Runners;
