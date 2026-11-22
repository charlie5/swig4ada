with
     friends.Binding,
     friends.A,
     friends.B,
     friends.D_i,
     friends.D_d,
     friends.Foe,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'friends' of upstream's suite, after its Python test: friend functions, which are defined
--  in their class or only declared there, of a class, of a template and of a class in a namespace.
--  Each is a function of the binding package, with no 'Self'.
--
is
   use friends,
       friends.Binding,
       interfaces.C,
       Checks;

   an_A   : aliased A.Item   := A.construct (2);
   a_B    : aliased B.Item   := B.Item (B.construct (3));
   an_Int : aliased D_i.Item := D_i.construct (2);
   a_Real : aliased D_d.Item := D_d.construct (3.3);
   a_Foe  : aliased Foe.Item := Foe.construct (111);
begin
   check (get_val1 (an_A'unchecked_Access) = 2,                    "a friend which is defined in its class");
   check (get_val2 (an_A'unchecked_Access) = 4,                    "a second");
   check (get_val3 (an_A'unchecked_Access) = 6,                    "a third");
   check (get_val1 (int'(1), 2, 3) = 1,                            "one of the same name which takes no object");

   check (mix (an_A'unchecked_Access, a_B'unchecked_Access) = 5,   "a friend of two classes");

   check (get_val1 (an_Int'unchecked_Access) = 2,                  "a friend of a template instance");
   check (get_val1 (a_Real'unchecked_Access) = 3.3,                "and of another instance");

   set (an_Int'unchecked_Access, 4);
   set (a_Real'unchecked_Access, 1.3);

   check (get_val1 (an_Int'unchecked_Access) = 4,                  "a friend which sets a private member");
   check (get_val1 (a_Real'unchecked_Access) = 1.3,                "of the other instance");

   check (chum_blah = 1234,                                        "a function which is a friend of a class that it uses");
   check (mate_blah = 4321,                                        "and a second");

   check (friend_definition  = 10,                                 "a friend which is defined in a class of a namespace");
   check (friend_declaration = 11,                                 "one which is declared there");
   check (friend_args_definition  (a_Foe'unchecked_Access) = 111,  "one which is defined there, and takes the class");
   check (friend_args_declaration (a_Foe'unchecked_Access) = 111,  "one which is declared there, and takes the class");

   check (friend_definition_compiler  = 20,                        "likewise, where the interface file does not show the definition");
   check (friend_declaration_compiler = 21,                        "nor the declaration");
   check (friend_args_definition_compiler  (a_Foe'unchecked_Access) = 111,  "with the class as its parameter");
   check (friend_args_declaration_compiler (a_Foe'unchecked_Access) = 111,  "and likewise");

   finish;
end Tester;
