with
     base,
     example,

     interfaces.C,

     ada.Text_IO,
     ada.Command_Line;


procedure Tester
--
--  A module whose array type is made of a type of the module which it imports.
--
is
   use interfaces.C,
       ada.Text_IO;

   use type base.gdouble;

   Failures : Natural := 0;


   procedure check (Condition : in Boolean;   What : in String)
   is
   begin
      if Condition
      then
         put_Line ("   ok      " & What);
      else
         put_Line ("   FAILED  " & What);
         Failures := Failures + 1;
      end if;
   end check;


   the_Vector : constant example.GtsVector4 := [1.0, 2.0, 3.0, 4.5];
   the_Third  : constant base.gdouble       := the_Vector (2);

begin
   check (example.GtsVector4'Length = 4,                    "the array type has the length of the C++ type");
   check (example.GtsVector4'First  = 0,                    "and begins at zero, as in C++");
   check (the_Third = 3.0,                                  "its elements are of the type of the imported module");
   check (base.gdouble'Size = double'Size,                  "which is a C double");
   check (example.GtsVector4'Object_Size = 4 * double'Size, "so the array has the size of the C++ array");

   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end Tester;
