with
     ada.Finalization;

generic
   type Item is abstract tagged limited private;

   with procedure destruct (Self : in out Item) is abstract;

package swig.Guards
--
-- Provides a scope guard for a C++ object.
--
-- The destructor of a C++ object is not called when the object leaves its scope.
-- A guard declared after the object calls the destructor when the guard leaves its own scope.
--
--    the_Circle : aliased Circle.item := Circle.construct (2.0);
--    the_Guard  : Circle.Guards.Guard (the_Circle'Access);
--
is
   type Guard (Target : not null access Item'Class) is new ada.Finalization.limited_Controlled with private;

private

   type Guard (Target : not null access Item'Class) is new ada.Finalization.limited_Controlled with null record;

   overriding
   procedure finalize (Self : in out Guard);

end swig.Guards;
