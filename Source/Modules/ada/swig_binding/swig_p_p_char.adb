--
-- This file was automatically generated by SWIG version 1.3.29 (http://www.swig.org).
--
-- Do not make changes to this file. Modify the SWIG interface file instead.
--


package body swig_p_p_char is
   procedure define (Self       :    out Item;
                     cPtr       : in     system.Address;
                     future_use : in     Boolean)
   is
      pragma Unreferenced (future_use);
   begin
      self.swigCPtr := cPtr;
   end define;



   function defined (cPtr       : in system.Address;
                     cMemoryOwn : in Boolean       := true) return Item'Class
   is
      pragma Unreferenced (cMemoryOwn);
      --the_Item : Itemz;
      the_Item : constant Item := (swigCPtr => cPtr);
   begin
      --define (the_Item, cPtr, cMemoryOwn);

      return the_Item;
   end defined;



   function getCPtr (Self : in Item) return system.Address
   is
   begin
      return self.swigCPtr;
   end getCPtr;
end swig_p_p_char;
