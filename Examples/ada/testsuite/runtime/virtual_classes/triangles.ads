with
     virtual_classes.Square,
     interfaces.C;

package Triangles
--
-- A shape whose class is declared in Ada, and derived from a C++ class.
--
-- Its parent must be a class with a constructor which is bound, which an abstract C++ class does not
-- have. The package is at library level, as C++ calls its functions through the vtable of the class.
--
is
   use virtual_classes,
       interfaces.C;

   type Item is new Square.Item with
      record
         Base, Height : aliased double;
      end record;

   overriding
   function area  (Self : access Item) return double;

   overriding
   function sides (Self : access Item) return int;

   pragma Convention (CPP, area);
   pragma Convention (CPP, sides);

end Triangles;
