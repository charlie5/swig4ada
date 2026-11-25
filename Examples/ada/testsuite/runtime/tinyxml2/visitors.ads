with
     tinyxml2.XMLVisitor,
     tinyxml2.XMLElement,
     tinyxml2.XMLAttribute,
     tinyxml2.XMLText,
     swig,
     ada.Strings.unbounded;

package Visitors
--
-- A visitor which is declared in Ada and derived from that of tinyxml2, which the library calls back as it walks
-- a document: it is given each element, with its first attribute, and each text. It is at library level, as
-- tinyxml2 calls its functions through the vtable of the class.
--
is
   use tinyxml2,
       ada.Strings.unbounded;

   type Counter is new XMLVisitor.Item with
      record
         Elements   : Natural := 0;           -- How many elements have been met.
         Attributes : Natural := 0;           -- How many of them have an attribute.
         Texts      : unbounded_String;       -- Each text which is met, in order.
      end record;

   overriding
   function VisitEnter (Self : access Counter;   arg_1 : access XMLElement.Item'Class;
                                                 arg_2 : in     XMLAttribute.Pointer) return swig.bool;
   pragma Convention (CPP, VisitEnter);

   overriding
   function Visit (Self : access Counter;   arg_1 : access XMLText.Item'Class) return swig.bool;
   pragma Convention (CPP, Visit);

end Visitors;
