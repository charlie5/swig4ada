/* Two classes, each of which uses the other. */

class Owner;

class Pet {
public:
  int    age;
  Owner* owner;
  Pet () : age (3), owner (0) {}
  Owner* get_owner ()            { return owner; }
  void   set_owner (Owner* o)    { owner = o; }
};

class Owner {
public:
  int  id;
  Pet* pet;
  Owner () : id (7), pet (0) {}
  void adopt     (Pet* p)        { pet = p;  p->set_owner (this); }
  Pet* get_pet   ()              { return pet; }
  int  pet_age   ()              { return pet ? pet->age : -1; }
  Pet  first_pet ()              { return *pet; }     // Returns the other class by value.
};
