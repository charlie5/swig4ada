with
     example.int_vector,

     swig,
     interfaces.C,

     ada.Text_IO,
     ada.Command_Line;


procedure Tester
--
--  A vector of the C++ standard library.
--
is
   use example,
       interfaces.C,
       ada.Text_IO;

   use type swig.bool;

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


   the_Vector : aliased int_vector.Item;
   the_Values : aliased array (1 .. 5) of aliased int := [10, 20, 30, 40, 50];

begin
   check (int_vector.isEmpty (the_Vector) = swig.bool'Val (1),   "a vector is empty when made");

   for Each of the_Values
   loop
      int_vector.add (the_Vector, Each'unchecked_Access);
   end loop;

   check (int_vector.size (the_Vector) = 5,             "items are added");
   check (int_vector.get (the_Vector, 2).all = 30,      "and read back");
   check (int_vector.capacity (the_Vector) >= 5,        "it has room for them");

   the_Values (1) := 99;
   int_vector.set (the_Vector, 4, the_Values (1)'unchecked_Access);
   check (int_vector.get (the_Vector, 4).all = 99,      "an item is replaced");

   declare
      the_Copy : aliased int_vector.Item := int_vector.construct (the_Vector'unchecked_Access);
   begin
      int_vector.clear (the_Vector);
      check (int_vector.size (the_Vector) = 0,          "the vector is cleared");
      check (int_vector.size (the_Copy) = 5,            "a copy made beforehand keeps its items");

      int_vector.destruct_0 (the_Copy);
   end;

   int_vector.destruct_0 (the_Vector);

   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end Tester;
