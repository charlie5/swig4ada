with
     unions.SmallStruct,
     unions.BigStruct,
     unions.EmbeddedUnionTest,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'unions' of upstream's suite, after its Python test: a union which
--  is a member of a structure, and whose own members are structures.
--
is
   use unions,
       interfaces.C,
       Checks;

   Small : SmallStruct.Item;
   Big   : BigStruct  .Item;
   Test  : EmbeddedUnionTest.Item;
begin
   Small.jill      := 200;
   Big.smallstruct := Small;
   Big.jack        := 300;

   Test.number    := 1;
   Test.uni.small := Small;

   check (Test.uni.small.jill = 200,                "a member of a union is set, and read");
   check (Test.number = 1,                          "the member beside the union keeps its value");

   Test.number  := 2;
   Test.uni.big := Big;

   check (Test.uni.big.jack = 300,                  "the other member of the union is set");
   check (Test.uni.big.smallstruct.jill = 200,      "and a structure within it is read");
   check (Test.number = 2,                          "the member beside the union keeps its value");

   finish;
end Tester;
