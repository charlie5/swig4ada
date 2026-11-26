with
     li_cpointer_cpp.Binding,
     li_cpointer_cpp.doublep,

     swig.Pointers,
     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'li_cpointer_cpp' of upstream's suite, after its Python test: the functions which '%pointer_functions'
--  of 'cpointer.i' makes for a pointer to an 'int', the class which '%pointer_class' makes for one to a 'double', and
--  the function of '%pointer_cast'.
--
is
   use li_cpointer_cpp,
       li_cpointer_cpp.Binding,
       interfaces.C,
       Checks;

   use type swig.Pointers.double_Pointer,
            doublep.Pointer;

   the_Int    : constant swig.Pointers.int_Pointer := new_intp;
   the_Double : constant doublep.Item             := doublep.construct;
begin
   check (intp_value (the_Int) = 0,                                     "a new pointer is to a zero");

   intp_assign (the_Int, 3);
   check (intp_value (the_Int) = 3,                                     "which is assigned");
   delete_intp (the_Int);

   declare
      the_Copy : constant swig.Pointers.int_Pointer := copy_intp (5);
   begin
      check (intp_value (the_Copy) = 5,                                 "a copy of a value");
      delete_intp (the_Copy);
   end;

   doublep.assign (the_Double, 2.5);
   check (doublep.value (the_Double) = 2.5,                             "the class of a pointer");
   check (doublep.cast (the_Double).all = 2.5,                          "and the pointer which it holds");
   check (doublep.frompointer (doublep.cast (the_Double)) /= null,      "which is made a class again");

   check (int_to_uint (-1) = unsigned'Last,                             "a cast of one type to another");

   doublep.destruct (the_Double);
   finish;
end Tester;
