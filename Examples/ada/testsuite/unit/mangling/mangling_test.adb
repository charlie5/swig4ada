with
     cpp_Mangling,
     ada.Strings.unbounded,
     Checks;


procedure mangling_Test
--
--  Makes the C++ symbol of each name of a table, and checks it against the symbol which GCC gave the entity.
--
is
   use ada.Strings.unbounded,
       Checks;

   function "+" (Text : in String) return unbounded_String
     renames to_unbounded_String;


   type Row is
      record
         Name   : unbounded_String;     -- As swig holds it.
         Suffix : unbounded_String;     -- 'E' for a variable, 'D1Ev' and 'D0Ev' for a destructor.
         Symbol : unbounded_String;     -- As GCC gives it.
      end record;

   the_Table : constant array (Positive range <>) of Row
     := [
      (+"Shape",                                        +"D1Ev", +"_ZN5ShapeD1Ev"),
      (+"Shape::total",                                 +"E",    +"_ZN5Shape5totalE"),
      (+"Poly",                                         +"D1Ev", +"_ZN4PolyD1Ev"),
      (+"Poly",                                         +"D0Ev", +"_ZN4PolyD0Ev"),
      (+"geometry::Dimensions",                         +"E",    +"_ZN8geometry10DimensionsE"),
      (+"geometry::solid::Box",                         +"D1Ev", +"_ZN8geometry5solid3BoxD1Ev"),
      (+"geometry::solid::Box::count",                  +"E",    +"_ZN8geometry5solid3Box5countE"),
      (+"Outer::Inner",                                 +"D1Ev", +"_ZN5Outer5InnerD1Ev"),
      (+"Outer::Inner::n",                              +"E",    +"_ZN5Outer5Inner1nE"),
      (+"Source<(int)>",                                +"D1Ev", +"_ZN6SourceIiED1Ev"),
      (+"Source<(int)>::made",                          +"E",    +"_ZN6SourceIiE4madeE"),
      (+"Source<(unsigned int)>",                       +"D1Ev", +"_ZN6SourceIjED1Ev"),
      (+"Source<(unsigned long)>",                      +"D1Ev", +"_ZN6SourceImED1Ev"),
      (+"Source<(long long)>",                          +"D1Ev", +"_ZN6SourceIxED1Ev"),
      (+"Source<(bool)>",                               +"D1Ev", +"_ZN6SourceIbED1Ev"),
      (+"Source<(double)>",                             +"D1Ev", +"_ZN6SourceIdED1Ev"),
      (+"Source<(long double)>",                        +"D1Ev", +"_ZN6SourceIeED1Ev"),
      (+"Source<(wchar_t)>",                            +"D1Ev", +"_ZN6SourceIwED1Ev"),
      (+"Source<(Shape)>",                              +"D1Ev", +"_ZN6SourceI5ShapeED1Ev"),
      (+"Source<(Shape)>::made",                        +"E",    +"_ZN6SourceI5ShapeE4madeE"),
      (+"Source<(p.Shape)>",                            +"D1Ev", +"_ZN6SourceIP5ShapeED1Ev"),
      (+"Source<(p.p.Shape)>",                          +"D1Ev", +"_ZN6SourceIPP5ShapeED1Ev"),
      (+"Source<(r.Shape)>",                            +"D1Ev", +"_ZN6SourceIR5ShapeED1Ev"),
      (+"Source<(z.Shape)>",                            +"D1Ev", +"_ZN6SourceIO5ShapeED1Ev"),
      (+"Source<(p.q(const).char)>",                    +"D1Ev", +"_ZN6SourceIPKcED1Ev"),
      (+"Source<(geometry::Thing)>",                    +"D1Ev", +"_ZN6SourceIN8geometry5ThingEED1Ev"),
      (+"Source<(geometry::solid::Box)>",               +"D1Ev", +"_ZN6SourceIN8geometry5solid3BoxEED1Ev"),
      (+"Source<(geometry::solid::Box)>::made",         +"E",    +"_ZN6SourceIN8geometry5solid3BoxEE4madeE"),
      (+"Source<(Source<(int)>)>",                      +"D1Ev", +"_ZN6SourceIS_IiEED1Ev"),
      (+"Source<(Pair<(Shape,p.Shape)>)>",              +"D1Ev", +"_ZN6SourceI4PairI5ShapePS1_EED1Ev"),
      (+"Pair<(int,double)>",                           +"D1Ev", +"_ZN4PairIidED1Ev"),
      (+"Pair<(Shape,Shape)>",                          +"D1Ev", +"_ZN4PairI5ShapeS0_ED1Ev"),
      (+"Pair<(Shape,p.Shape)>",                        +"D1Ev", +"_ZN4PairI5ShapePS0_ED1Ev"),
      (+"Pair<(p.Shape,p.Shape)>",                      +"D1Ev", +"_ZN4PairIP5ShapeS1_ED1Ev"),
      (+"Pair<(p.Shape,p.p.Shape)>",                    +"D1Ev", +"_ZN4PairIP5ShapePS1_ED1Ev"),
      (+"Pair<(p.q(const).Shape,p.q(const).Shape)>",    +"D1Ev", +"_ZN4PairIPK5ShapeS2_ED1Ev"),
      (+"Pair<(p.q(const).char,p.q(const).char)>",      +"D1Ev", +"_ZN4PairIPKcS1_ED1Ev"),
      (+"Pair<(geometry::Thing,geometry::Thing)>",      +"D1Ev", +"_ZN4PairIN8geometry5ThingES1_ED1Ev"),
      (+"Pair<(geometry::Thing,geometry::solid::Box)>", +"D1Ev", +"_ZN4PairIN8geometry5ThingENS0_5solid3BoxEED1Ev"),
      (+"Pair<(Source<(int)>,Source<(int)>)>",          +"D1Ev", +"_ZN4PairI6SourceIiES1_ED1Ev"),
      (+"Pair<(Outer::Inner,p.Outer::Inner)>",          +"D1Ev", +"_ZN4PairIN5Outer5InnerEPS1_ED1Ev"),
      (+"Array<(int,8)>",                               +"D1Ev", +"_ZN5ArrayIiLi8EED1Ev"),
      (+"Array<(Shape,16)>",                            +"D1Ev", +"_ZN5ArrayI5ShapeLi16EED1Ev"),
      (+"ns::Tmpl<(int)>",                              +"D1Ev", +"_ZN2ns4TmplIiED1Ev"),
      (+"ns::Tmpl<(ns::Thing)>",                        +"D1Ev", +"_ZN2ns4TmplINS_5ThingEED1Ev"),
      (+"ns::Tmpl<(ns::Tmpl<(int)>)>",                  +"D1Ev", +"_ZN2ns4TmplINS0_IiEEED1Ev"),
      (+"ns::Held<(int)>::count",                       +"E",    +"_ZN2ns4HeldIiE5countE"),
      (+"ns::Held<(ns::Thing)>::count",                 +"E",    +"_ZN2ns4HeldINS_5ThingEE5countE")
        ];

   --  Names whose symbol is not made, for which nothing must be given: a wrong symbol would fail only when the program is linked.
   --
   the_Refused : constant array (Positive range <>) of unbounded_String
     := [+"",
         +"std::vector<(int)>",               -- The standard library, whose names are abbreviated.
         +"Source<(std::string)>",
         +"Array<(int,-1)>",                  -- A negative number.
         +"Source<(a(4).int)>",               -- An array.
         +"Source<(f(int).int)>",             -- A function.
         +"Source<(int)",                     -- Not well formed.
         +"operator +"];

begin
   for Each of the_Table
   loop
      declare
         Name   : constant String := to_String (Each.Name);
         Actual : constant String := cpp_Mangling.Symbol (Name, to_String (Each.Suffix));
      begin
         check (Actual = Each.Symbol,
                "'" & Name & "' with '" & to_String (Each.Suffix) & "' is '" & to_String (Each.Symbol) & "'"
                & (if Actual = Each.Symbol then "" else ", and not '" & Actual & "'"));
      end;
   end loop;

   for Each of the_Refused
   loop
      check (cpp_Mangling.Symbol (to_String (Each), "D1Ev") = "",
             "'" & to_String (Each) & "' is given no symbol");
   end loop;

   finish;
end mangling_Test;
