with
     library.Binding,
     library.int_Multiset,
     library.int_double_Multimap,
     library.double_Complex,
     library.wstring,
     library.Pointers,

     swig,
     interfaces.C,

     Checks;


procedure Tester
--
--  Further classes of the C++ standard library: a multiset, a multimap, a complex number and a wide
--  string, each made by Ada and used from both sides, and the streams, which are used by reference.
--
is
   use library,
       library.Binding,
       interfaces.C,
       Checks;

   use type swig.bool,
            library.Pointers.ostream_Pointer,
            library.Pointers.ostringstream_Pointer;

   function is_True (Value : in swig.bool) return Boolean
   is (Value /= swig.bool'Val (0));

   Unit : constant := interfaces.C.char'Size;

begin
   --  The size of each Ada type is that of the C++ type.
   --
   check (int_Multiset       .Item'Size / Unit = Integer (size_of_multiset),   "the size of a multiset");
   check (int_double_Multimap.Item'Size / Unit = Integer (size_of_multimap),   "the size of a multimap");
   check (double_Complex     .Item'Size / Unit = Integer (size_of_complex),    "the size of a complex number");
   check (wstring            .Item'Size / Unit = Integer (size_of_wstring),    "the size of a wide string");

   multiset :
   declare
      S : aliased int_Multiset.Item;
      X : aliased int := 2;
   begin
      check (is_True (int_Multiset.isEmpty (S)),               "a multiset with no initial value is empty");

      int_Multiset.add (S, X'unchecked_Access);
      int_Multiset.add (S, X'unchecked_Access);
      check (int_Multiset.size  (S) = 2,                       "an element may be added twice");
      check (int_Multiset.count (S, X'unchecked_Access) = 2,   "and is counted twice");
      check (is_True (int_Multiset.contains (S, X'unchecked_Access)),   "an element is found");

      fill (int_Multiset.Pointer'(S'unchecked_Access), 6);     -- Adds 1, 2, 0, 1, 2, 0.
      check (int_Multiset.size  (S) = 8,                       "elements added by C++");
      check (int_Multiset.count (S, X'unchecked_Access) = 4,   "are counted with those added from Ada");
      check (sum (int_Multiset.Pointer'(S'unchecked_Access)) = 10,   "C++ reads the whole multiset");

      check (int_Multiset.erase (S, X'unchecked_Access) = 4,   "every element of a value is erased");

      X := 7;
      check (not is_True (int_Multiset.contains (S, X'unchecked_Access)),   "an element which is absent is not found");

      int_Multiset.destruct_0 (S);
   end multiset;

   multimap :
   declare
      M   : aliased int_double_Multimap.Item;
      Key : aliased int    := 1;
      X   : aliased double := 10.0;
   begin
      check (is_True (int_double_Multimap.isEmpty (M)),               "a multimap with no initial value is empty");

      int_double_Multimap.add (M, Key'unchecked_Access, X'unchecked_Access);
      X := 20.0;
      int_double_Multimap.add (M, Key'unchecked_Access, X'unchecked_Access);

      check (int_double_Multimap.count (M, Key'unchecked_Access) = 2,   "a key may have two values");
      check (is_True (int_double_Multimap.has_key (M, Key'unchecked_Access)),   "a key is found");

      fill (int_double_Multimap.Pointer'(M'unchecked_Access), 4);     -- Adds 0.5 and 1.5 to the key 1, 1.0 and 2.0 to the key 0.
      check (int_double_Multimap.size  (M) = 6,                         "values added by C++");
      check (int_double_Multimap.count (M, Key'unchecked_Access) = 4,   "are counted with those added from Ada");
      check (total (int_double_Multimap.Pointer'(M'unchecked_Access)) = 35.0,   "C++ reads the whole multimap");

      check (int_double_Multimap.erase (M, Key'unchecked_Access) = 4,   "every value of a key is erased");
      check (int_double_Multimap.size  (M) = 2,                         "and the other keys remain");

      int_double_Multimap.clear (M);
      check (is_True (int_double_Multimap.isEmpty (M)),                 "a multimap is cleared");

      int_double_Multimap.destruct_0 (M);
   end multimap;

   complex_numbers :
   declare
      A      : aliased double_Complex.Item := double_Complex.construct (3.0, 4.0);
      B      : aliased double_Complex.Item := double_Complex.construct (1.0, 2.0);
      Real   : aliased double_Complex.Item := double_Complex.construct (6.0);
      Zero   : aliased double_Complex.Item := double_Complex.construct;
      Result :         double_Complex.Item;
   begin
      check (double_Complex.real (A) = 3.0 and double_Complex.imag (A) = 4.0,   "a complex number is made of its two parts");
      check (A.impl_M_real = 3.0           and A.impl_M_imag = 4.0,             "which are where C++ has them");
      check (double_Complex.real (Real) = 6.0 and double_Complex.imag (Real) = 0.0,   "the imaginary part may be left out");
      check (double_Complex.real (Zero) = 0.0 and double_Complex.imag (Zero) = 0.0,   "one made of nothing is zero");

      check (magnitude (A'unchecked_Access) = 5.0,                              "C++ reads a number made by Ada");

      Result := product (A'unchecked_Access, B'unchecked_Access);
      check (Result.impl_M_real = -5.0 and Result.impl_M_imag = 10.0,           "a complex result is returned");

      Result := conjugate (A);
      check (Result.impl_M_real = 3.0 and Result.impl_M_imag = -4.0,            "a complex number is passed by value");

      rotate (A'unchecked_Access);
      check (A.impl_M_real = -4.0 and A.impl_M_imag = 3.0,                      "C++ changes a number made by Ada");

      B.impl_M_imag := 9.0;
      check (double_Complex.imag (B) = 9.0,                                     "C++ reads a part which Ada has set");

      Result := B;
      check (Result.impl_M_real = 1.0 and Result.impl_M_imag = 9.0,             "a complex number is assigned in Ada, as it is a plain structure");
   end complex_numbers;

   wide_strings :
   declare
      Text  : aliased wchar_array := to_C (Wide_String'("wid"));
      Empty : aliased wstring.Item;
      Short : aliased wstring.Item := wstring.construct (Text (Text'First)'unchecked_Access);
      Made  : aliased wstring.Item;
   begin
      check (is_True (wstring.empty (Empty)) and wstring.length (Empty) = 0,   "a wide string with no initial value is empty");

      check (wstring.length (Short) = 3 and wstring.size (Short) = 3,          "a wide string is made of wide characters");
      check (wide_length (Short'unchecked_Access) = 3,                         "C++ reads its length");
      check (wide_at (Short'unchecked_Access, 1) = to_C (Wide_Character'('i')),   "and its characters");
      check (Short.impl_M_string_length = 3,                                   "its length is where C++ has it");
      check (to_Ada (Short.impl_M_local_buf, Trim_Nul => False) (1 .. 3) = "wid",   "a short one is held within the object");

      wide_append (Short'unchecked_Access);     -- Now too long to be held within the object.
      check (wstring.length (Short) = 72,                                      "a wide string is lengthened by C++");

      Copy :
      declare
         the_Copy : aliased wstring.Item := wstring.construct (Short'unchecked_Access);
      begin
         check (wstring.length (the_Copy) = 72,                                "a wide string is copied");
         wstring.clear (the_Copy);
         check (is_True (wstring.empty (the_Copy)) and wstring.length (Short) = 72,   "and the copy is cleared alone");
         wstring.destruct_0 (the_Copy);
      end Copy;

      wide_make (Made'unchecked_Access);
      check (wstring.length (Made) = 11,                                       "a wide string is returned");
      check (wide_at (Made'unchecked_Access, 0) = to_C (Wide_Character'('m')),    "with its characters");

      wstring.destruct_0 (Made);
      wstring.destruct_0 (Short);
      wstring.destruct_0 (Empty);
   end wide_strings;

   streams :
   declare
      the_Stream : constant library.Pointers.ostringstream_Pointer := new_stream;
      Output     : constant library.Pointers.ostream_Pointer       := as_ostream (the_Stream);
   begin
      check (the_Stream /= null and Output /= null,   "a stream is held by a pointer");
      check (is_True (is_good (Output)),              "and is passed back to C++");

      write (Output, 12);
      write (Output, 345);
      check (written (the_Stream) = 7,                "what is written through one pointer is seen through the other");

      check (standard_output /= null,                 "a standard stream is reached");
      check (is_True (is_good (standard_output)),     "and used");

      delete_stream (the_Stream);
   end streams;

   finish;
end Tester;
