-- This file is generated by SWIG. Do *not* modify by hand.
with ref_example.Vector;
package ref_example.Binding is

   function addv
     (a    : access ref_example.Vector.Item;
      b    : access ref_example.Vector.Item)
      return ref_example.Vector.Item;

private

   pragma Import (C, addv, "Ada_addv");

end ref_example.Binding;