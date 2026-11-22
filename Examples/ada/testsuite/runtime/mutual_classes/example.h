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

/* A base class which knows of the class that is derived from it. */

class Leaf;

class Node {
public:
  int depth;
  Node () : depth (1) {}
  virtual ~Node () {}
  virtual int weight ()   { return 1; }
  Leaf* as_leaf ();                         // Returns a pointer to the derived class.
};

class Leaf : public Node {
public:
  int value;
  Leaf () : value (9) {}
  virtual int weight ()   { return 5; }
};

inline Leaf* Node::as_leaf ()   { return dynamic_cast <Leaf*> (this); }
