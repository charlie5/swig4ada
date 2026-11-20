package body Hexagons
is

   overriding
   function area (Self : access Item) return double
   is
   begin
      return 2.5 * Self.Side * Self.Side;     -- Near enough for a test.
   end area;



   overriding
   function sides (Self : access Item) return int
   is
      pragma Unreferenced (Self);
   begin
      return 6;
   end sides;

end Hexagons;
