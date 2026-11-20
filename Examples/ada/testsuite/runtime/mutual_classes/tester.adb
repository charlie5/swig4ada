with
     mutual_classes.Owner,
     mutual_classes.Pet,

     interfaces.C,

     Checks;


procedure Tester
--
--  Two classes, each of which has the other as the type of a member, a parameter and a result.
--
is
   use mutual_classes,
       interfaces.C,
       Checks;

   use type Pet.Pointer;

   the_Owner : aliased Owner.Item := Owner.construct;
   the_Pet   : aliased Pet  .Item := Pet  .construct;
begin
   check (the_Owner.id = 7 and the_Pet.age = 3,   "both objects are constructed");
   check (Owner.pet_age (the_Owner) = -1,         "the owner has no pet at first");

   Owner.adopt (the_Owner, the_Pet'unchecked_Access);

   check (Owner.get_pet (the_Owner) = the_Pet'unchecked_Access,   "the owner points to the pet");
   check (Owner.pet_age (the_Owner) = 3,                          "the owner reads the pet");
   check (Pet.get_owner (the_Pet).id = 7,                         "the pet points back to the owner");

   the_Pet.age := 4;
   check (Owner.get_pet (the_Owner).age = 4,      "a change to the pet is seen through the owner");
   check (Owner.first_pet (the_Owner).age = 4,    "the other class is returned by value");

   finish;
end Tester;
