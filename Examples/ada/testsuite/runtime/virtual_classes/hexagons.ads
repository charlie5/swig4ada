with
     virtual_classes.Shape,
     interfaces.C;

package Hexagons
--
-- A shape whose class is declared in Ada, and derived from an abstract C++ class.
--
-- The part of its object which is the abstract class is made by a constructor of that class.
--
is
   use virtual_classes,
       interfaces.C;

   type Item is new Shape.Item with
      record
         Side : aliased double;
      end record;

   overriding
   function area  (Self : access Item) return double;

   overriding
   function sides (Self : access Item) return int;

   pragma Convention (CPP, area);
   pragma Convention (CPP, sides);

end Hexagons;
