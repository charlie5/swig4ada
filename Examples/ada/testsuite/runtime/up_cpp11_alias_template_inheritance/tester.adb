with
     cpp11_alias_template_inheritance.Binding,
     cpp11_alias_template_inheritance.DerivedX,
     cpp11_alias_template_inheritance.Palette,
     cpp11_alias_template_inheritance.AliasCalcInt,
     cpp11_alias_template_inheritance.DerivedC,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'cpp11_alias_template_inheritance' of upstream's suite, after its Python test: classes whose base is named
--  through an alias template, and 'using' declarations which name a function, an overload and the constructors of the
--  base through the alias.
--
is
   use cpp11_alias_template_inheritance,
       cpp11_alias_template_inheritance.Binding,
       interfaces.C,
       Checks;

   the_Calc : constant AliasCalcInt.Item := AliasCalcInt.construct;
begin
   check (DerivedX.m (DerivedX.construct) = 11,                         "a function which 'using' names through the alias");

   check (palette_to_int (Palette.RED)   = 0
      and palette_to_int (Palette.GREEN) = 1
      and palette_to_int (Palette.BLUE)  = 2,                           "an enumeration named through the alias");

   check (AliasCalcInt.add (the_Calc, 5) = 105,                         "a function of the class");
   check (AliasCalcInt.add (the_Calc, 2, 3) = 5,                        "and the overload of its base which 'using' names through the alias");

   check (DerivedC.construct (42).BaseC.value = 42,                     "a constructor which the class inherits through the alias");

   finish;
end Tester;
