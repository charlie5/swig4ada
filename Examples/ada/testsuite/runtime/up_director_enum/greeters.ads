with
     director_enum.Foo;

package Greeters
--
--  A class which is declared in Ada and derived from 'Foo', whose virtual function of an enumeration C++ calls
--  through the vtable.
--
is
   use director_enum;

   type Yo_Sayer is new Foo.Item with null record;

   overriding
   function say_hi (Self : access Yo_Sayer;
                    h    : in     Hallo) return Hallo;

   pragma Convention (CPP, say_hi);

end Greeters;
