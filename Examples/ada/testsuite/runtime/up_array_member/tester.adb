with
     array_member.Binding,
     array_member.Foo,
     array_member.RayPacketData,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'array_member' of upstream's suite, after its Python test: an array which is a member
--  of a structure and one which is a global variable are assigned to each other and read by C++.
--
is
   use array_member,
       array_member.Binding,
       interfaces.C,
       Checks;

   the_Foo : aliased Foo.Item;
   Same    : Boolean := True;
begin
   the_Foo.data := global_data;

   for i in int range 0 .. 7
   loop
      Same := Same and get_value (the_Foo.data (0)'unchecked_Access, i) = get_value (global_data (0)'Access, i);
   end loop;

   check (Same,                                    "the global array is assigned to the member, and C++ reads the same from each");
   check (get_value (the_Foo.data (0)'unchecked_Access, 5) = 5,   "which is what the library gave it");

   for i in int range 0 .. 7
   loop
      set_value (the_Foo.data (0)'unchecked_Access, i, -i);
   end loop;

   global_data := the_Foo.data;
   Same        := True;

   for i in int range 0 .. 7
   loop
      Same := Same and get_value (global_data (0)'Access, i) = -i;
   end loop;

   check (Same,                                    "the member, which C++ has set, is assigned to the global array");

   --  The arrays of 'RayPacketData' have the length of an enumeration value of the class ('enum { Size = 32 };').
   --
   declare
      the_Data : RayPacketData.Item;
   begin
      check (the_Data.chitMat'Length = 32,         "an array member has the length which a value of an enumeration of its class gives");
      check (the_Data.hitMat2'Length (1) = 32 and the_Data.hitMat2'Length (2) = 32,   "in each of two dimensions");
   end;

   finish;
end Tester;
