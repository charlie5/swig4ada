with
     li_carrays.Binding,
     li_carrays.doubleArray,
     li_carrays.XY,
     li_carrays.XYArray,
     li_carrays.AB,

     swig.Pointers,
     interfaces.C,

     ada.Text_IO,
     ada.Command_Line;


procedure Tester
--
--  C arrays, reached through the functions and classes which 'carrays.i' makes.
--
is
   use li_carrays,
       li_carrays.Binding,
       interfaces.C,
       ada.Text_IO;

   use type swig.Pointers.int_Pointer,
            swig.Pointers.double_Pointer,
            doubleArray.Pointer,
            XYArray.Pointer,
            AB.Pointer;

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

begin
   array_functions :
   declare
      the_Ints : constant swig.Pointers.int_Pointer := new_intArray (4);
      the_ABs  : constant AB.Pointer                := new_ABArray  (2);
   begin
      check (the_Ints /= null,                          "an array of int is made");

      for i in size_t range 0 .. 3     -- An index is a 'size_t', as of SWIG 4.2.
      loop
         intArray_setitem (the_Ints, i, int (i) * 10);
      end loop;

      check (intArray_getitem (the_Ints, 3) = 30,       "its items are set and read back");
      check (the_Ints.all = 0,                          "the pointer is to its first item");

      ABArray_setitem (the_ABs, 1, (a => 5, b => 6));
      check (ABArray_getitem (the_ABs, 1).b = 6,        "an array of structures, whose items are passed by value");

      delete_ABArray  (the_ABs);
      delete_intArray (the_Ints);
   end array_functions;

   array_classes :
   declare
      the_Doubles : constant doubleArray.Pointer := new_doubleArray (3);
      the_XYs     : constant XYArray.Pointer     := new_XYArray (3);
   begin
      check (the_Doubles /= null,                       "an array class is made by the function which stands for its constructor");

      doubleArray.setitem (the_Doubles.all, 2, 2.5);
      check (doubleArray.getitem (the_Doubles.all, 2) = 2.5,   "its items are set and read back");
      check (doubleArray.cast (the_Doubles.all) /= null,       "it is cast to a pointer to its first item");
      check (doubleArray.frompointer (doubleArray.cast (the_Doubles.all)) = the_Doubles,   "and made from one again");

      XYArray.setitem (the_XYs.all, 1, (x => 7, y => 8));
      check (XYArray.getitem (the_XYs.all, 1).y = 8,    "an array class of structures");

      delete_XYArray     (the_XYs);
      delete_doubleArray (the_Doubles);
   end array_classes;

   array_variables :
   declare
      the_Global : constant XYArray.Pointer := XYArray.frompointer (globalXYArray (0)'Access);
   begin
      globalXYArray (2) := (x => 3, y => 4);
      check (XYArray.getitem (the_Global.all, 2).x = 3,   "an array variable of the library, read as an array class");

      globalABArray (0).a := 9;
      check (ABArray_getitem (globalABArray (0)'Access, 0).a = 9,   "and another, read by the array functions");
   end array_variables;

   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end Tester;
