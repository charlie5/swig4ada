with
     virtual_classes.Filter,
     interfaces.C;

package Sieves
--
-- A class which is declared in Ada, and derived from an abstract C++ class which has a pure virtual
-- function of its own and one of its base class.
--
is
   use virtual_classes,
       interfaces.C;

   type Item is new Filter.Item with null record;

   overriding
   function produce (Self : access Item) return int;

   overriding
   function refine  (Self : access Item) return int;

   pragma Convention (CPP, produce);
   pragma Convention (CPP, refine);

end Sieves;
