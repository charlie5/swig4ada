with
     cpp17_nested_namespaces.Binding,
     cpp17_nested_namespaces.A1Struct,
     cpp17_nested_namespaces.B1Struct,
     cpp17_nested_namespaces.C1Struct,
     cpp17_nested_namespaces.B2Struct,
     cpp17_nested_namespaces.C2Struct,
     cpp17_nested_namespaces.B3Struct,
     cpp17_nested_namespaces.C3Struct,

     Checks;


procedure Tester
--
--  The case 'cpp17_nested_namespaces' of upstream's suite, after its Python test: classes and functions of nested
--  namespaces, declared in the form of C++17 ('namespace A1::B1 { ... }') and in the older form, in either order.
--  The namespaces have no packages, so each class is a package of the module.
--
is
   use cpp17_nested_namespaces,
       cpp17_nested_namespaces.Binding,
       Checks;
begin
   A1Struct.A1Method (A1Struct.construct);
   B1Struct.B1Method (B1Struct.construct);
   C1Struct.C1Method (C1Struct.construct);
   A1Struct.A1Method (createA1Struct);
   B1Struct.B1Method (createB1Struct);
   C1Struct.C1Method (createC1Struct);
   check (True,                                                         "the classes and functions of namespaces nested in the older form");

   B2Struct.B2Method (B2Struct.construct);
   C2Struct.C2Method (C2Struct.construct);
   B2Struct.B2Method (createB2Struct);
   C2Struct.C2Method (createC2Struct);
   check (True,                                                         "and in the form of C++17");

   B3Struct.B3Method (B3Struct.construct);
   C3Struct.C3Method (C3Struct.construct);
   B3Struct.B3Method (createB3Struct);
   C3Struct.C3Method (createC3Struct);
   check (True,                                                         "the inner namespace first");

   finish;
end Tester;
