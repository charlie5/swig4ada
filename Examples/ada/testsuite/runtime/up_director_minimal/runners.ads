with
     director_minimal.Minimal,
     swig;

package Runners
--
--  A class which is declared in Ada and derived from 'Minimal', whose virtual function C++ calls through the vtable.
--
is
   use director_minimal;

   type Always is new Minimal.Item with null record;

   overriding
   function run (Self : access Always) return swig.bool;

   pragma Convention (CPP, run);

end Runners;
