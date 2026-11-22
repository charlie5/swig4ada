with
     primitive_ref.Binding,
     primitive_ref.A,

     swig,
     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'primitive_ref' of upstream's suite, after its Python test: functions which take
--  and return a constant reference to each primitive type. In Ada each is a pointer.
--
is
   use primitive_ref,
       primitive_ref.Binding,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   use type swig.bool;

   an_Int    : aliased int            := 3;
   a_UInt    : aliased unsigned       := 3;
   a_Short   : aliased short          := 3;
   a_UShort  : aliased unsigned_short := 3;
   a_Long    : aliased long           := 3;
   a_ULong   : aliased unsigned_long  := 3;
   a_SChar   : aliased signed_char    := 3;
   a_UChar   : aliased unsigned_char  := 3;
   a_Float   : aliased C_float        := 3.5;
   a_Double  : aliased double         := 3.5;
   a_Bool    : aliased swig.bool      := swig.bool'Val (1);
   a_Char    :         chars_ptr      := new_String ("x");

   an_A      : aliased A.Item         := A.construct (5);
begin
   check (ref_int    (an_Int  'unchecked_Access).all = 3,     "a reference to an int");
   check (ref_uint   (a_UInt  'unchecked_Access).all = 3,     "to an unsigned int");
   check (ref_short  (a_Short 'unchecked_Access).all = 3,     "to a short");
   check (ref_ushort (a_UShort'unchecked_Access).all = 3,     "to an unsigned short");
   check (ref_long   (a_Long  'unchecked_Access).all = 3,     "to a long");
   check (ref_ulong  (a_ULong 'unchecked_Access).all = 3,     "to an unsigned long");
   check (ref_schar  (a_SChar 'unchecked_Access).all = 3,     "to a signed char");
   check (ref_uchar  (a_UChar 'unchecked_Access).all = 3,     "to an unsigned char");
   check (ref_float  (a_Float 'unchecked_Access).all = 3.5,   "to a float");
   check (ref_double (a_Double'unchecked_Access).all = 3.5,   "to a double");
   check (ref_bool   (a_Bool  'unchecked_Access).all = a_Bool,   "to a bool");
   check (String'(Value (ref_char (a_Char), 1)) = "x",        "to a char");

   check (ref_over (int'(0)) = 0,                             "an overloaded function, of a number");
   check (ref_over (an_A'unchecked_Access) = 5,               "and of a reference to a class");

   free (a_Char);
   finish;
end Tester;
