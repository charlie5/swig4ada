package body Triangles
is

   overriding
   function area (Self : access Item) return double
   is
   begin
      return Self.Base * Self.Height / 2.0;
   end area;



   overriding
   function sides (Self : access Item) return int
   is
      pragma Unreferenced (Self);
   begin
      return 3;
   end sides;

end Triangles;
