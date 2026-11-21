with
     layouts.Binding,
     layouts.Value,
     layouts.Flags,
     layouts.Cross,
     layouts.Inner,
     layouts.Labelled,
     layouts.Device,
     layouts.Outer,
     layouts.Mixed,

     swig,
     interfaces.C,

     Checks;


procedure Tester
--
--  Unions, bit-fields and structures within structures. Each structure is filled by C++
--  and read by Ada, then changed by Ada and read by C++, and its size is compared.
--
is
   use layouts,
       layouts.Binding,
       interfaces.C,
       Checks;

   use type swig.bool,
            swig.long_long,
            swig.void_ptr;

   function bytes (Bits : in Natural) return int
   is (int (Bits / 8));

begin
   unions :
   declare
      the_Value : aliased Value.Item := make_value (1_078_530_011);     -- The bits of 3.14159274.
   begin
      check (Value.Item'Object_Size / 8 = 4 and size_of_value = 4,  "a union is the size of its largest member");
      check (the_Value.as_int = 1_078_530_011,                      "a union is returned by value");
      check (value_int (the_Value) = 1_078_530_011,                 "and passed by value");
      check (the_Value.as_float > 3.14 and the_Value.as_float < 3.15,   "its members share their storage");

      set_float (the_Value'unchecked_Access, 1.0);
      check (the_Value.as_int = 16#3F80_0000#,                      "C++ changes it through another member");
   end unions;

   simple_bit_fields :
   declare
      the_Flags : aliased Flags.Item;
   begin
      check (bytes (Flags.Item'Object_Size) = size_of_flags,        "a structure of bit-fields has the size which C++ gives it");

      fill_flags (the_Flags'unchecked_Access);
      check (the_Flags.ready = 1 and the_Flags.mode = 5 and the_Flags.level = 9,   "bit-fields which follow one another");
      check (the_Flags.offset = -7,                                 "a signed bit-field");
      check (the_Flags.wide = 40_000,                               "the bit-field after one with no name");
      check (the_Flags.after = 123,                                 "the member after the bit-fields");

      the_Flags.mode  := 2;
      the_Flags.level := 15;
      check (flags_sum (the_Flags'unchecked_Access) = 1 + 2 + 15 - 7 + 40_000 + 123,   "C++ reads the bit-fields which Ada wrote");
   end simple_bit_fields;

   crossing_bit_fields :
   declare
      use type Shade;
      the_Cross : aliased Cross.Item;
   begin
      check (bytes (Cross.Item'Object_Size) = size_of_cross,        "a structure whose bit-fields do not fit their units has the size of C++");

      fill_cross (the_Cross'unchecked_Access);
      check (the_Cross.x = 'x' and the_Cross.c = 'c',               "the members which are not bit-fields");
      check (the_Cross.a = 16#ABC_DEF1#,                            "a bit-field which begins a new unit");
      check (the_Cross.b = 1000,                                    "and the one after it, which begins another");
      check (the_Cross.d = 5,                                       "a bit-field after a member which is not one");
      check (the_Cross.e = 21,                                      "a bit-field after one of no width");
      check (the_Cross.on = swig.bool'Val (1),                      "a bit-field of type bool");
      check (the_Cross.shade = Light,                               "a bit-field of an enumeration type");
      check (the_Cross.s = -12,                                     "the last member");

      the_Cross.b := 7;
      the_Cross.e := 1;
      check (cross_sum (the_Cross'unchecked_Access) = 16#ABC_DEF1# + 7 + 5 + 1 + 1 + 2 - 12,   "C++ reads what Ada wrote");
   end crossing_bit_fields;

   bit_fields_after_a_structure :
   declare
      the_Labelled : aliased Labelled.Item;
   begin
      check (bytes (Labelled.Item'Object_Size) = size_of_labelled,      "bit-fields which follow a structure: the size");

      fill_labelled (the_Labelled'unchecked_Access);
      check (the_Labelled.low = 9 and the_Labelled.high = 6,            "and the bit-fields");
      check (the_Labelled.end_mark = 'e',                             "and the member after them");

      the_Labelled.high := 1;
      check (labelled_sum (the_Labelled'unchecked_Access) = 4 + 9 + 1,  "which C++ reads");
   end bit_fields_after_a_structure;

   bit_fields_in_a_virtual_class :
   declare
      the_Device : aliased Device.Item;
   begin
      check (bytes (Device.Item'Object_Size) = size_of_device,      "a class with virtual functions and bit-fields: the size");
      check (the_Device.enabled = 1 and the_Device.channel = 100,   "its bit-fields, set by its constructor");
      check (the_Device.rate = 9600,                                "and the member after them");

      the_Device.channel := 5;
      check (describe (the_Device'unchecked_Access) = 1005 + 9600,  "C++ reads what Ada wrote");

      Device.destruct_0 (the_Device);
   end bit_fields_in_a_virtual_class;

   structures_within_structures :
   declare
      the_Outer : aliased Outer.Item;
   begin
      check (bytes (Outer.Item'Object_Size) = size_of_outer,        "a structure which holds others has the size of C++");

      fill_outer (the_Outer'unchecked_Access);
      check (the_Outer.first = 'a' and the_Outer.last = 'z',        "its first and last members");
      check (the_Outer.inner.tag = 'b' and the_Outer.inner.amount = 1.5,   "a member which is a structure");
      check (the_Outer.middle = 7,                                  "the member after it");
      check (the_Outer.value.as_int = 9,                            "a member which is a union");
      check (the_Outer.pair (1).tag = 'p' and the_Outer.pair (1).amount = 3.5,   "a member which is an array of structures");
      check (the_Outer.link /= null and then the_Outer.link.amount = 1.5,   "a member which points to another");

      the_Outer.pair (0).amount := 10.0;
      the_Outer.last            := 'y';
      check (outer_sum (the_Outer'unchecked_Access) = 1.5 + 7.0 + 9.0 + 10.0 + 3.5 + 100.0,   "C++ reads what Ada wrote");
   end structures_within_structures;

   mixed_types :
   declare
      the_Mixed : aliased Mixed.Item;
   begin
      check (bytes (Mixed.Item'Object_Size) = size_of_mixed,        "a structure of the standard types has the size of C++");

      fill_mixed (the_Mixed'unchecked_Access);
      check (the_Mixed.c = 'm' and the_Mixed.big = 5_000_000_000,   "char and long long");
      check (the_Mixed.flag = swig.bool'Val (1) and the_Mixed.f = 0.5 and the_Mixed.s = -3,   "bool, float and short");
      check (the_Mixed.wide = 2.25,                                 "long double");
      check (the_Mixed.any = the_Mixed'Address,                     "a pointer to anything");
      check (the_Mixed.size = 77,                                   "size_t");

      the_Mixed.wide := 0.75;
      the_Mixed.size := 1;
      check (mixed_sum (the_Mixed'unchecked_Access) = 5_000_000_000.0 + 0.5 - 3.0 + 0.75 + 1.0 + 1.0,   "C++ reads what Ada wrote");
   end mixed_types;

   finish;
end Tester;
