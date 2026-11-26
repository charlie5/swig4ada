with
     cpp11_uniform_initialization.Binding,
     cpp11_uniform_initialization.AltStruct,
     cpp11_uniform_initialization.MoreInit,
     cpp11_uniform_initialization.VectorInt,

     swig.Pointers,
     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'cpp11_uniform_initialization' of upstream's suite, after its Python test: variables and members which
--  are initialised in braces, among them a vector, and a function whose parameter is a vector with a default argument
--  in braces.
--
is
   use cpp11_uniform_initialization,
       cpp11_uniform_initialization.Binding,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   the_Init : aliased MoreInit.Item := MoreInit.construct;
   Numbers  : aliased VectorInt.Item := VectorInt.construct;

   procedure add (the_Number : in int)
   is
      Value : aliased int := the_Number;
   begin
      VectorInt.add (Numbers, Value'unchecked_Access);
   end add;

begin
   check (var1.x = 5,                                                   "a structure whose members are initialised in braces");
   check (AltStruct.getX (var2) = 2,                                    "and one which braces construct");

   check (the_Init.charptr = Null_Ptr,                                  "a member initialised in braces to 'nullptr'");
   check (the_Init.yarray (4) = 5,                                      "an array");
   check (MoreInit.more1 (the_Init, the_Init.vi) = 15,                  "and a vector");

   add (-1);   add (1);   add (2);
   check (MoreInit.more1 (the_Init, Numbers) = 2,                       "a vector which is passed by value");
   check (MoreInit.more1 (the_Init) = 10,                               "and the default argument in braces");

   VectorInt.destruct_0 (Numbers);
   MoreInit .destruct_0 (the_Init);
   finish;
end Tester;
