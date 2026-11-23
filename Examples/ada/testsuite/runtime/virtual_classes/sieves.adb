package body Sieves
is

   overriding
   function produce (Self : access Item) return int
   is
      pragma Unreferenced (Self);
   begin
      return 77;
   end produce;



   overriding
   function refine (Self : access Item) return int
   is
      pragma Unreferenced (Self);
   begin
      return 88;
   end refine;

end Sieves;
