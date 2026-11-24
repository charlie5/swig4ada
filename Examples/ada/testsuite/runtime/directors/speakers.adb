package body Speakers
is

   overriding
   procedure speak (Self   : in out Parrot;
                    word   : in     std_string_Pointer;
                    Result : in     std_string_Pointer)
   is
   begin
      Self.Calls := Self.Calls + 1;
      assign (Result.all, to_C ("polly says " & to_Ada (word.all)));
   end speak;


   overriding
   procedure speak (Self   : in out Parrot;
                    times  : in     int;
                    Result : in     std_string_Pointer)
   is
      pragma Unreferenced (Self);
   begin
      assign (Result.all, to_C ("squawk" & int'Image (times)));
   end speak;


   overriding
   procedure label (Self   : in out Parrot;
                    Result : in     directors.Label.Pointer)
   is
   begin
      Speaker.Director.label (Speaker.Director.Item (Self), Result);     -- What the function of the class does.
      assign (Result.text, to_C (to_Ada (Result.text) & " and parrot"));
   end label;


   overriding
   function sum (Self : access Parrot;
                 p    : in     Point.Item) return int
   is
      pragma Unreferenced (Self);
   begin
      return p.x * p.y;
   end sum;


   overriding
   procedure secret (Self   : in out Parrot;
                     Result : in     std_string_Pointer)
   is
      pragma Unreferenced (Self);
   begin
      assign (Result.all, to_C ("parrot secret"));
   end secret;


   overriding
   function level (Self : access Parrot) return int
   is
      pragma Unreferenced (Self);
   begin
      return 9;
   end level;



   overriding
   procedure name (Self   : in out Choir;
                   Result : in     std_string_Pointer)
   is
      pragma Unreferenced (Self);
   begin
      assign (Result.all, to_C ("choir"));
   end name;


   overriding
   function pitch (Self : access Choir) return int
   is
      pragma Unreferenced (Self);
   begin
      return 440;
   end pitch;

end Speakers;
