with
     multiple_inheritance.Binding,
     multiple_inheritance.Label,
     multiple_inheritance.Sprite,
     multiple_inheritance.Button,

     interfaces.C,

     Checks;


procedure Tester
--
--  Classes with more than one base class.
--
is
   use multiple_inheritance,
       multiple_inheritance.Binding,
       interfaces.C,
       Checks;

begin
   two_bases_with_no_virtual_function :
   declare
      the_Label : aliased Label.Item := Label.construct;
   begin
      check (the_Label.Position.x = 1 and the_Label.Position.y = 2,   "the members of the first base class");
      check (the_Label.Named.name_code = 77,                          "the member of the second base class");
      check (the_Label.size = 12,                                     "the member of the class itself");
      check (Label.total (the_Label) = 92,                            "C++ reads them all");
      check (label_code (the_Label.Named'unchecked_Access) = 77,      "the second base class is passed to C++ by pointer");
   end two_bases_with_no_virtual_function;

   a_virtual_base_and_one_which_is_not :
   declare
      the_Sprite : aliased Sprite.Item := Sprite.construct;
   begin
      check (the_Sprite.layer = 3,                                    "the member of the virtual base class");
      check (Sprite.frame (the_Sprite'Access) = 5,                    "the member of the class itself");
      check (Sprite.where (the_Sprite'Access) = 12,                   "C++ reads the members of the base class which is not virtual");

      --  The base class which is not virtual is reached by a function, as its part of the object
      --  may not be where an Ada component would be.
      --
      check (Sprite.as_Position (the_Sprite'Access).x = 1,            "Ada reads a member of that base class");
      Sprite.as_Position (the_Sprite'Access).y := 7;
      check (Sprite.where (the_Sprite'Access) = 17,                   "and C++ sees the value which Ada wrote to it");
      check (Sprite.draw  (the_Sprite'Access) = 25,                   "the overriding function");
      check (draw_it (the_Sprite'unchecked_Access) = 25,              "C++ dispatches through a pointer to the virtual base class");
   end a_virtual_base_and_one_which_is_not;

   two_virtual_bases :
   declare
      the_Button : aliased Button.Item := Button.construct;
   begin
      check (the_Button.layer = 3,                                    "the member of the first virtual base class");
      check (Button.id     (the_Button'Access) = 9,                   "the member of the class itself");
      check (Button.get_id (the_Button'Access) = 9,                   "C++ reads it");
      check (Button.draw   (the_Button'Access) = 30,                  "the function which overrides one of the first base class");
      check (draw_it (the_Button'unchecked_Access) = 30,              "C++ dispatches through a pointer to the first base class");
      check (Button.click  (the_Button'Access) = 2,                   "the function which overrides one of the second base class");

      --  The second virtual base class is not a parent of the Ada type, but is reached by a function.
      --
      check (click_it (Button.as_Clickable (the_Button'Access)) = 4,  "C++ dispatches through a pointer to the second base class");
      check (Button.as_Clickable (the_Button'Access).clicks = 4,      "Ada reads a member of the second base class");
   end two_virtual_bases;

   finish;
end Tester;
