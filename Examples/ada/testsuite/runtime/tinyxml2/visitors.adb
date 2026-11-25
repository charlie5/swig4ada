with
     tinyxml2.XMLNode,
     interfaces.C.Strings;

package body Visitors
is
   use type XMLAttribute.Pointer;


   overriding
   function VisitEnter (Self : access Counter;   arg_1 : access XMLElement.Item'Class;
                                                 arg_2 : in     XMLAttribute.Pointer) return swig.bool
   is
      pragma Unreferenced (arg_1);
   begin
      Self.Elements := Self.Elements + 1;

      if arg_2 /= null
      then
         Self.Attributes := Self.Attributes + 1;
      end if;

      return 1;     -- Carry on with the walk.
   end VisitEnter;



   overriding
   function Visit (Self : access Counter;   arg_1 : access XMLText.Item'Class) return swig.bool
   is
   begin
      append (Self.Texts, interfaces.C.Strings.Value (XMLNode.Value (arg_1)) & " ");
      return 1;
   end Visit;

end Visitors;
