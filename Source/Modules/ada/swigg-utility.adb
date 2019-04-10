with
     ada_Utility,
     DOHs.Pointers,
     swigg_Module.Binding,
     swigg_Module.Pointers;

package body swigg.Utility
is
   use ada_Utility;


   procedure replace_integer_with_float (Self : in out Text)
   is
   begin
      replace_All (Self, "0e", "0.0e");
      replace_All (Self, "1e", "1.0e");   replace_All (Self, "2e", "2.0e");   replace_All (Self, "3e", "3.0e");
      replace_All (Self, "4e", "4.0e");   replace_All (Self, "5e", "5.0e");   replace_All (Self, "6e", "6.0e");
      replace_All (Self, "7e", "7.0e");   replace_All (Self, "8e", "8.0e");   replace_All (Self, "9e", "9.0e");

      replace_All (Self, "0E", "0.0E");
      replace_All (Self, "1E", "1.0E");   replace_All (Self, "2E", "2.0E");   replace_All (Self, "3E", "3.0E");
      replace_All (Self, "4E", "4.0E");   replace_All (Self, "5E", "5.0E");   replace_All (Self, "6E", "6.0E");
      replace_All (Self, "7E", "7.0E");   replace_All (Self, "8E", "8.0E");   replace_All (Self, "9E", "9.0E");
   end replace_integer_with_float;



   procedure strip_c_integer_literal_qualifiers_in (Self : in out Text)
   is
   begin
      replace_All (Self, "1LL", "1");   replace_All (Self, "2LL", "2");   replace_All (Self, "3LL", "3");
      replace_All (Self, "4LL", "4");   replace_All (Self, "5LL", "5");   replace_All (Self, "6LL", "6");
      replace_All (Self, "7LL", "7");   replace_All (Self, "8LL", "8");   replace_All (Self, "9LL", "9");
      replace_All (Self, "0LL", "0");

      replace_All (Self, "1UL", "1");   replace_All (Self, "2UL", "2");   replace_All (Self, "3UL", "3");
      replace_All (Self, "4UL", "4");   replace_All (Self, "5UL", "5");   replace_All (Self, "6UL", "6");
      replace_All (Self, "7UL", "7");   replace_All (Self, "8UL", "8");   replace_All (Self, "9UL", "9");
      replace_All (Self, "0UL", "0");

      replace_All (Self, "1L", "1");   replace_All (Self, "2L", "2");   replace_All (Self, "3L", "3");
      replace_All (Self, "4L", "4");   replace_All (Self, "5L", "5");   replace_All (Self, "6L", "6");
      replace_All (Self, "7L", "7");   replace_All (Self, "8L", "8");   replace_All (Self, "9L", "9");
      replace_All (Self, "0L", "0");

      replace_All (Self, "1l", "1");   replace_All (Self, "2l", "2");   replace_All (Self, "3l", "3");
      replace_All (Self, "4l", "4");   replace_All (Self, "5l", "5");   replace_All (Self, "6l", "6");
      replace_All (Self, "7l", "7");   replace_All (Self, "8l", "8");   replace_All (Self, "9l", "9");
      replace_All (Self, "0l", "0");

      if Index (Self, "0x") = 0
      then
         replace_All (Self, "1F", "1");   replace_All (Self, "2F", "2");   replace_All (Self, "3F", "3");
         replace_All (Self, "4F", "4");   replace_All (Self, "5F", "5");   replace_All (Self, "6F", "6");
         replace_All (Self, "7F", "7");   replace_All (Self, "8F", "8");   replace_All (Self, "9F", "9");
         replace_All (Self, "0F", "0");
      end if;
   end strip_c_integer_literal_qualifiers_in;



   procedure strip_enum_Prefix (Self : in out Text)
   is
      enum_prefix_Token : constant String  := "enum ";
      enum_prefix_Index : constant Natural := Index (Self,  enum_prefix_Token);
   begin
      if enum_prefix_Index /= 0
      then
         delete (Self,  enum_prefix_Index,
                        enum_prefix_Index + enum_prefix_Token'Length - 1);
      end if;
   end strip_enum_Prefix;



   procedure strip_leading_global_namespace_Prefix (Self : in out Text)
   is
   begin
      if         Length (Self) >= 2
        and then Slice (Self, 1, 2) = "::"
      then
         delete (Self,  1,  2);
      end if;
   end strip_leading_global_namespace_Prefix;




   function strip_array_Bounds (Self : in doh_SwigType) return Text
   is
      use ada.Strings;

      stripped_swig_Type : Text := +Self;
      bounds_Start : Natural;
      bounds_End   : Natural;
   begin
      loop
         bounds_Start := Index (stripped_swig_Type,  "a(");
         exit when bounds_Start = 0;                              -- Loop til there are no more array bounds left.
         bounds_End   := Index (stripped_swig_Type,  ")",
                                from  => Index (stripped_swig_Type, ".", from => bounds_Start),
                                going => backward);

         delete (stripped_swig_Type,  bounds_Start + 1,
                                      bounds_End);
      end loop;

      return stripped_swig_Type;
   end strip_array_Bounds;



   function trim_Namespace (Self : in Text) return Text
   is
      use ada.Strings;
      the_Index : constant Natural := Index (Self, "::", going => backward);
   begin
      if the_Index = 0
      then
         return Self;
      else
         return to_unbounded_String (Slice (Self,  the_Index + 2, Length (Self)));
      end if;
   end trim_Namespace;
   pragma Unreferenced (trim_Namespace);



   function resolved_c_left_shift_Operator (Self : in Text) return Integer
   is
      shift_Index : constant Natural := Index (Self,  "<<");
      pre_Token   : constant String  := Slice (Self,  1,                shift_Index - 1);
      post_Token  : constant String  := Slice (Self,  shift_Index + 3,  Length (Self));
   begin
      return Integer'Value (pre_Token)  *  2**Integer'Value (post_Token);
   end resolved_c_left_shift_Operator;
   pragma Unreferenced (resolved_c_left_shift_Operator);


   procedure strip_all_qualifiers (Self : in out Text)
   is
      Pad       : Text renames Self;
      the_Index : Natural;

      procedure rid (the_Token : in String)
      is
      begin
         loop
            the_Index := Index (Pad, the_Token);
            exit when the_Index = 0;

            replace_Slice (Pad,  the_Index,
                                 the_Index + the_Token'Length - 1,
                                 "");
         end loop;
      end rid;

   begin
      rid ("q(const).");
      rid ("q(volatile).");
      rid ("struct ");
      rid ("enum ");

--        log ("strip_all_qualifiers ~ result: '" & Pad & "'");
   end strip_all_qualifiers;



   procedure strip_all_qualifiers (Self : in out doh_SwigType)
   is
      Pad : Text := +Self;
   begin
      strip_all_qualifiers (Pad);
      Self := doh_SwigType (to_Doh (to_String (Pad)));
   end strip_all_qualifiers;



   function sibling_module_Name_of (the_Node : in doh_Node) return String
   is
      use swigg_Module.Binding,
          swigg_Module.Pointers,
          DOHs.Pointers;

      the_Sibling : Node_Pointer := first_Child (parent_Node (Node_Pointer (the_Node)));
   begin
      while exists (DOH_pointer (the_Sibling))
      loop
         if String'(+node_Type (the_Sibling)) = "module"
         then
            return +doh_Item (get_Attribute (the_Sibling, String_Pointer (-"name")));
         end if;

         the_Sibling := next_Sibling (the_Sibling);
      end loop;

      return "";
   end sibling_module_Name_of;



   function owner_module_Name_of (the_Node : in doh_Node) return String
   is
   begin
      if sibling_module_Name_of (the_Node) /= ""
      then
         return sibling_module_Name_of (the_Node);
      end if;

      declare
         use DOHs.Pointers,
             swigg_Module,
             swigg_Module.Binding,
             swigg_Module.Pointers;
         the_Parent : DOH_Pointer := DOH_Pointer (parent_Node (Node_Pointer (the_Node)));
      begin
         while exists (the_Parent)
         loop
            if sibling_module_Name_of (the_Parent) /= ""
            then
               return sibling_module_Name_of (the_Parent);
            end if;

            the_Parent := DOH_Pointer (parent_Node (Node_Pointer (the_Parent)));
         end loop;
      end;

      raise Program_Error;  -- Should never arrive here.
   end owner_module_Name_of;


end swigg.Utility;
