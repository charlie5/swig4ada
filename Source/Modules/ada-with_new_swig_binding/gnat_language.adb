with
     Transformer,

     gnat_Language.source_Generator,
     gnat_Language.Forge,

     ada_Utility,

     interfaces.c,
     ada.Strings.fixed;


--  old ...
--

with gnat_Language.c_expression_Resolver;
                              use gnat_Language.c_expression_Resolver;

with swigg.Binding;           use swigg.Binding;
with swigg.Dispatcher;        use swigg.Dispatcher;
with swigg.Wrapper;           use swigg.Wrapper;

--  with swig_p_Doh;

with interfaces.c.Strings;    use interfaces.c.Strings;

with ada.text_IO;             use ada.text_IO;

with System.Machine_Code;     use System.Machine_Code;
with ada_Package;             use ada_Package;
with ada_Variable;            use ada_Variable;
with c_Parameter;             use c_Parameter;


package body gnat_Language
is
   use ada_Utility;
   use ada.Strings, ada.Strings.Fixed;
   use ada.Containers;

   use type swig_p_Doh.item;


   -----------
   --  Globals
   -----------

   usage_help_Text : constant array (1 .. 3) of access String
     := (new String'("Gnat/Ada Options (available with -gnat)"),
         new String'("       -namespace <nm> - Generate wrappers into Ada namespace <nm>"),
         new String'("       -noproxy        - Generate the low-level functional interface instead of proxy classes"));

   NL              : constant String
     := portable_new_line_Token;



   --  This provides the gnat_Language object to the (c-side) swig 'main' function.
   --
   function swig_gnat return system.Address
   is
      the_gnat_Language : gnat_Language.view;
   begin
      the_gnat_Language := Forge.construct;

      initialize            (the_gnat_Language.all);
      swig_director_connect (the_gnat_Language.all);

      return getCPtr (the_gnat_Language.all);
   end swig_gnat;



   -----------
   --  Utility
   -----------

   procedure log (the_Map : symbol_value_Maps.Map)
   is
      Cursor : symbol_value_Maps.Cursor := First (the_Map);
   begin
      while has_Element (Cursor) loop
--           log ("key: '" & Key (Cursor) & "'     value: " & Image (Element (Cursor)));
         next (Cursor);
      end loop;
   end log;



   procedure replace_integer_with_float (Self : in out unbounded_String)
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



   procedure strip_c_integer_literal_qualifiers_in (Self : in out unbounded_String)
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

      if Index (Self, "0x") = 0 then
         replace_All (Self, "1F", "1");   replace_All (Self, "2F", "2");   replace_All (Self, "3F", "3");
         replace_All (Self, "4F", "4");   replace_All (Self, "5F", "5");   replace_All (Self, "6F", "6");
         replace_All (Self, "7F", "7");   replace_All (Self, "8F", "8");   replace_All (Self, "9F", "9");
         replace_All (Self, "0F", "0");
      end if;
   end strip_c_integer_literal_qualifiers_in;



   procedure strip_enum_Prefix (Self : in out unbounded_String)
   is
      enum_prefix_Token : constant String  := "enum ";
      enum_prefix_Index : constant Natural := Index (Self,  enum_prefix_Token);
   begin
      if enum_prefix_Index /= 0
      then
         delete (Self,  enum_prefix_Index,  enum_prefix_Index + enum_prefix_Token'Length - 1);
      end if;
   end strip_enum_Prefix;



   procedure strip_leading_global_namespace_Prefix (Self : in out unbounded_String)
   is
   begin
      if         Length (Self) >= 2
        and then Slice (Self, 1, 2) = "::"
      then
         delete (Self,  1,  2);
      end if;
   end strip_leading_global_namespace_Prefix;




   function strip_array_Bounds (Self : in doh_SwigType'Class) return unbounded_String
   is
      stripped_swig_Type : unbounded_String := +Self;
      bounds_Start : Natural;
      bounds_End   : Natural;
   begin
      loop
         bounds_Start := Index (stripped_swig_Type,  "a(");
         exit when bounds_Start = 0;                              -- Loop til there are no more array bounds left.
         bounds_End   := Index (stripped_swig_Type,  ")",
                                from  => Index (stripped_swig_Type, ".", from => bounds_Start),
                                going => backward);

         delete (stripped_swig_Type,  bounds_Start + 1,  bounds_End);
      end loop;

      return stripped_swig_Type;
   end strip_array_Bounds;



   function trim_Namespace (Self : in unbounded_String) return unbounded_String
   is
      the_Index : constant Natural := Index (Self, "::", going => backward);
   begin
      if the_Index = 0 then
         return Self;
      else
         return to_unbounded_String (Slice (Self,  the_Index + 2, Length (Self)));
      end if;
   end trim_Namespace;



   function resolved_c_left_shift_Operator (Self : in unbounded_String) return Integer
   is
      shift_Index : constant Natural := Index (Self,  "<<");
      pre_Token   : constant String  := Slice (Self,  1,                shift_Index - 1);
      post_Token  : constant String  := Slice (Self,  shift_Index + 3,  Length (Self));
   begin
      return Integer'Value (pre_Token) * 2 ** Integer'Value (post_Token);
   end resolved_c_left_shift_Operator;



   procedure strip_all_qualifiers (Self : in out doh_SwigType'Class)
   is
      Pad       : unbounded_String := +Self;
      the_Index : Natural;

      procedure rid (the_Token : in String)
      is
      begin
         loop
            the_Index := Index (Pad, the_Token);
            exit when the_Index = 0;

            replace_Slice (Pad,
                           the_Index,  the_Index + the_Token'Length - 1,
                           "");
         end loop;
      end rid;

   begin
      rid ("q(const).");
      rid ("q(volatile).");
      rid ("struct ");
      rid ("enum ");

--        log ("strip_all_qualifiers ~ result: '" & Pad & "'");

      Self := doh_SwigType'Class (to_Doh (to_String (Pad)));
      --        Self := to_Doh (to_String (Pad));
   end strip_all_qualifiers;



   function sort_by_large_to_small (Left, Right : in unbounded_String) return Boolean        -- sorting function (tbd: obsolete)
   is
   begin
      return Length (Left) > Length (Right);
   end sort_by_large_to_small;



   function sibling_module_Name_of (the_Node : in doh_Node'Class) return String
   is
      the_Sibling : doh_Node'Class := first_Child (parent_Node (the_Node));
   begin
      while exists (the_Sibling)
      loop
         if String'(+node_Type (the_Sibling)) = "module" then
            return +get_Attribute (the_Sibling, -"name");
         end if;

         the_Sibling := next_Sibling (the_Sibling);
      end loop;

      return "";
   end sibling_module_Name_of;



   function owner_module_Name_of (the_Node : in doh_Node'Class) return String
   is
   begin
      if sibling_module_Name_of (the_Node) /= "" then
         return sibling_module_Name_of (the_Node);
      end if;

      declare
         the_Parent : doh_Node'Class := parent_Node (the_Node);
      begin
         while exists (the_Parent)
         loop
            if sibling_module_Name_of (the_Parent) /= "" then
               return sibling_module_Name_of (the_Parent);
            end if;

            the_Parent := parent_Node (the_Parent);
         end loop;
      end;

      raise Program_Error;  -- should not happen
   end owner_module_Name_of;


   function is_a_function_Pointer (Self : in doh_swigType'Class) return Boolean;



   -----------------
   --  gnat_Language
   -----------------

   procedure add_new_c_Type (Self : access Item'Class;   the_new_Type : c_Type.view)
   is
      the_current_Module : constant swig_Module.swig_Module_view := Self.current_Module;
   begin
--        log ("add_new_c_Type: '" & the_new_Type.Name & "'");

      the_current_Module.C.new_c_Types       .append (the_new_Type);
      the_current_Module.C.new_c_Declarations.append (the_new_Type.all'Access);
   end add_new_c_Type;



   procedure register (Self : access Item;   the_c_Type              : in     c_Type.view;
                                             the_swig_Type           : in     doh_swigType'Class;
                                             is_core_C_type          : in     Boolean           := False;
                                             create_array_Type       : in     Boolean           := True;
                                             add_level_3_Indirection : in     Boolean           := False)
   is
--        the_current_Module         : a_Module_view := Self.current_Module;
      is_a_new_Type              : constant Boolean       := (not is_core_C_type); --  and (not Self.is_Importing);

      the_c_type_Pointer         : c_Type.view;
      the_c_type_pointer_Pointer : c_Type.view;

   begin
--        log (the_c_Type.Name & " is_a_new_Type: " & Boolean'Image (is_a_new_Type));

      do_c_Type :
      begin
         Self.swig_type_Map_of_c_type.insert (+the_swig_Type,   the_c_Type);
         Self.name_Map_of_c_type     .insert (the_c_Type.Name,  the_c_Type);

         if is_a_new_Type then
            Self.add_new_c_Type (the_c_Type);
         end if;
      end do_c_Type;


      do_level_1_indirection :
      declare
      begin
         if create_array_Type then   -- add associated array
            declare
               array_swigType   : constant doh_swigType'Class := to_DOH ("a." & (+the_swig_Type));    -- swigtype_add_Array (doh_copy (the_swig_Type), to_DOH (""));
               the_c_type_Array : c_Type.view;
            begin
               the_c_type_Array := c_type.new_array_Type (the_c_Type.nameSpace,
                                                          the_c_Type.Name & "[]",
                                                          element_type => the_c_Type);
               the_c_type_Array.add_array_Dimension;

               Self.swig_type_Map_of_c_type.insert (+array_swigType,        the_c_type_Array);
               Self.name_Map_of_c_type     .insert (the_c_type_Array.Name,  the_c_type_Array);

               if is_a_new_Type then
                  Self.add_new_c_Type (the_c_type_Array);
               end if;
            end;
         end if;


         declare   -- add associated pointer
            pointer_swigType : constant doh_swigType'Class := swigtype_add_Pointer (doh_copy (the_swig_Type));
         begin
            the_c_type_Pointer := c_type.new_type_Pointer (the_c_Type.nameSpace,
                                                           the_c_Type.Name & "*",
                                                           accessed_type => the_c_Type);
            Self.swig_type_Map_of_c_type.insert (+pointer_swigType,        the_c_type_Pointer);
            Self.name_Map_of_c_type     .insert (the_c_type_Pointer.Name,  the_c_type_Pointer);

            declare   -- register pointer to 'const'
               the_pointer_to_const_swigType : constant doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Qualifier (doh_copy (the_swig_Type), to_Doh ("const")));
               the_c_pointer_to_const_Name   : constant unbounded_String   := "const " & the_c_Type.Name & "*";
            begin
               --           log ("pointer_to_const_swigType: '" & String'(+pointer_to_const_swigType) & "'");
               --           log ("c_pointer_to_const_Name: '" & c_pointer_to_const_Name & "'");
               Self.swig_type_Map_of_c_type.insert (+the_pointer_to_const_swigType, the_c_type_Pointer);
               Self.name_Map_of_c_type     .insert (the_c_pointer_to_const_Name,    the_c_type_Pointer);
            end;

            if is_a_new_Type then
               Self.add_new_c_Type (the_c_type_Pointer);
            end if;
         end;


         declare   -- add associated reference
            reference_swigType   : constant doh_swigType'Class := SwigType_add_reference (doh_copy (the_swig_Type));
         begin
            Self.swig_type_Map_of_c_type.insert (+reference_swigType,      the_c_type_Pointer);
            Self.name_Map_of_c_type     .insert (the_c_type.Name & "&",    the_c_type_Pointer);

            declare   -- register reference to 'const'
               the_reference_to_const_swigType : constant doh_swigType'Class := SwigType_add_reference (swigtype_add_Qualifier (doh_copy (the_swig_Type), to_Doh ("const")));
               the_c_reference_to_const_Name   : constant unbounded_String   := "const " & the_c_Type.Name & "&";
            begin
               --           log ("pointer_to_const_swigType: '" & String'(+pointer_to_const_swigType) & "'");
               --           log ("c_pointer_to_const_Name: '" & c_pointer_to_const_Name & "'");
               Self.swig_type_Map_of_c_type.insert (+the_reference_to_const_swigType, the_c_type_Pointer);
               Self.name_Map_of_c_type     .insert (the_c_reference_to_const_Name,    the_c_type_Pointer);
            end;

--              if is_a_new_Type then
--                 Self.add_new_c_Type (the_c_type_Pointer);
--              end if;
         end;
      end do_level_1_indirection;


      do_level_2_indirection :
      begin
         the_c_type_pointer_Pointer := c_type.new_type_Pointer    (the_c_Type.nameSpace,
                                                                   the_c_Type.Name & "**",
                                                                   accessed_type => the_c_type_Pointer);
         if create_array_Type then   -- add associated array
            declare
               array_of_pointers_swigType : constant doh_swigType'Class := to_DOH ("a." & (+swigtype_add_Pointer (doh_copy (the_swig_Type))));
               the_c_type_pointer_Array   : c_Type.view;
            begin
               the_c_type_pointer_Array := c_type.new_array_Type (the_c_Type.nameSpace,  the_c_Type.Name & "*[]",
                                                                  element_type => the_c_type_Pointer);
               the_c_type_pointer_Array.add_array_Dimension;

               Self.swig_type_Map_of_c_type.insert (+array_of_pointers_swigType,   the_c_type_pointer_Array);
               Self.name_Map_of_c_type     .insert (the_c_type_pointer_Array.Name, the_c_type_pointer_Array);

               if is_a_new_Type then
                  Self.add_new_c_Type (the_c_type_pointer_Array);
               end if;
            end;
         end if;


         declare   -- add pointer pointer
            pointer_to_pointer_swigType : constant doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Pointer (doh_copy (the_swig_Type)));
         begin
            Self.swig_type_Map_of_c_type.insert (+pointer_to_pointer_swigType,    the_c_type_pointer_Pointer);
            Self.name_Map_of_c_type     .insert (the_c_type_pointer_Pointer.Name, the_c_type_pointer_Pointer);
         end;


         declare   -- register pointer pointer to 'const'
            the_pointer_to_pointer_to_const_swigType : constant doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Pointer (swigtype_add_Qualifier (doh_copy (the_swig_Type),
                                                                                                            to_Doh ("const"))));
            the_c_pointer_to_pointer_to_const_Name   : constant unbounded_String   := "const " & the_c_Type.Name & "**";
         begin
            --           log ("pointer_to_const_swigType: '" & String'(+pointer_to_const_swigType) & "'");
            --           log ("c_pointer_to_const_Name: '" & c_pointer_to_const_Name & "'");
            Self.swig_type_Map_of_c_type.insert (+the_pointer_to_pointer_to_const_swigType, the_c_type_pointer_Pointer);
            Self.name_Map_of_c_type.insert      (the_c_pointer_to_pointer_to_const_Name,    the_c_type_pointer_Pointer);
         end;

         if is_a_new_Type then
            Self.add_new_c_Type (the_c_type_pointer_Pointer);
         end if;
      end do_level_2_indirection;


      if add_level_3_Indirection
      then
         do_level_3_indirection :
         declare
            the_c_type_pointer_pointer_Pointer : constant c_Type.view :=  c_type.new_type_Pointer    (the_c_Type.nameSpace,
                                                                                             the_c_Type.Name & "***",
                                                                                             accessed_type => the_c_type_pointer_Pointer);
         begin
            if create_array_Type then   -- add associated array
               declare
                  array_of_pointer_pointers_swigType : constant doh_swigType'Class := to_DOH ("a." & (+swigtype_add_Pointer (swigtype_add_Pointer (doh_copy (the_swig_Type)))));
                  the_c_type_pointer_pointer_Array   : c_Type.view;
               begin
                  the_c_type_pointer_pointer_Array := c_type.new_array_Type (the_c_Type.nameSpace,  the_c_Type.Name & "**[]",
                                                                             element_type => the_c_type_pointer_Pointer);
                  the_c_type_pointer_pointer_Array.add_array_Dimension;

                  Self.swig_type_Map_of_c_type.insert (+array_of_pointer_pointers_swigType,   the_c_type_pointer_pointer_Array);
                  Self.name_Map_of_c_type     .insert (the_c_type_pointer_pointer_Array.Name, the_c_type_pointer_pointer_Array);

                  if is_a_new_Type then
                     Self.add_new_c_Type (the_c_type_pointer_pointer_Array);
                  end if;
               end;
            end if;


            declare   -- add pointer pointer
               pointer_to_pointer_pointer_swigType : constant doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Pointer (swigtype_add_Pointer (doh_copy (the_swig_Type))));
            begin
               Self.swig_type_Map_of_c_type.insert (+pointer_to_pointer_pointer_swigType,    the_c_type_pointer_pointer_Pointer);
               Self.name_Map_of_c_type     .insert (the_c_type_pointer_pointer_Pointer.Name, the_c_type_pointer_pointer_Pointer);
            end;


            if is_a_new_Type then
               Self.add_new_c_Type (the_c_type_pointer_pointer_Pointer);
            end if;
         end do_level_3_indirection;
      end if;

   end register;



   procedure register_Mirror (Self : access Item'Class;   proxy_Name              : in     unbounded_String;
                                                          the_c_Type              : in     c_Type.view;
                                                          the_swig_Type           : in     doh_swigType'Class;
                                                          is_core_C_type          : in     Boolean := False;
                                                          create_array_Type       : in     Boolean := True;
                                                          add_level_3_Indirection : in     Boolean := False)
   is
      pragma Unreferenced (add_level_3_Indirection);
--        the_current_Module : a_Module_view := Self.current_Module;
--        is_a_new_Type      : constant Boolean       := (not is_core_C_type); --  and (not Self.is_Importing);
   begin
--        log ("register_Mirror ~ " & the_c_Type.name & " is_a_new_Type: " & Boolean'Image (is_a_new_Type));

      do_c_Type :
      begin
         Self.swig_type_Map_of_c_type.insert (+the_swig_Type,    the_c_Type);
         Self.name_Map_of_c_type     .insert (proxy_Name,  the_c_Type);
      end do_c_Type;


      do_level_1_indirection :
      declare
      begin
         if create_array_Type
         then      -- add associated array
            declare
               array_swigType : constant doh_swigType'Class := to_DOH ("a." & (+the_swig_Type));    -- swigtype_add_Array (doh_copy (the_swig_Type), to_DOH (""));
               my_array_Type  : constant c_Type.view        := Self.name_Map_of_c_type.Element (the_c_Type.Name & "[]");
            begin
               Self.swig_type_Map_of_c_type.insert (+array_swigType,    my_array_Type);
               Self.name_Map_of_c_type     .insert (proxy_Name & "[]",  my_array_Type);
            end;
         end if;

         declare         -- add associated pointer
            pointer_swigType : constant doh_swigType'Class := swigtype_add_Pointer (doh_copy (the_swig_Type));
            my_view_Type     : constant c_Type.view        := Self.name_Map_of_c_type.Element (the_c_Type.Name & "*");
         begin
            Self.swig_type_Map_of_c_type.insert (+pointer_swigType,  my_view_Type);
            Self.name_Map_of_c_type     .insert (proxy_Name & "*",   my_view_Type);

            declare      -- register pointer to 'const'
               the_pointer_to_const_swigType : constant doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Qualifier (doh_copy (the_swig_Type), to_Doh ("const")));
            begin
               Self.swig_type_Map_of_c_type.insert (+the_pointer_to_const_swigType,
                                                    my_view_Type);
               Self.name_Map_of_c_type     .insert ("const " & proxy_Name & "*",
                                                    my_view_Type);
            end;

            declare      -- add associated reference
               reference_swigType   : constant doh_swigType'Class := SwigType_add_reference (doh_copy (the_swig_Type));
            begin
               Self.swig_type_Map_of_c_type.insert (+reference_swigType, my_view_Type);
               Self.name_Map_of_c_type     .insert (proxy_Name & "&",    my_view_Type);

               declare   -- register reference to 'const'
                  the_reference_to_const_swigType : constant doh_swigType'Class := SwigType_add_reference (swigtype_add_Qualifier (doh_copy (the_swig_Type), to_Doh ("const")));
               begin
                  Self.swig_type_Map_of_c_type.insert (+the_reference_to_const_swigType,  my_view_Type);
                  Self.name_Map_of_c_type     .insert ("const " & proxy_Name & "&",       my_view_Type);
               end;
            end;
         end;
      end do_level_1_indirection;


      do_level_2_indirection :
      begin
--           the_c_type_pointer_Pointer := c_type.new_type_Pointer    (the_c_Type.nameSpace,
--                                                                     the_c_Type.Name & "**",
--                                                                     accessed_type => the_c_type_Pointer);
         if create_array_Type
         then      -- add associated array
            declare
               array_of_pointers_swigType : constant doh_swigType'Class := to_DOH ("a." & (+swigtype_add_Pointer (doh_copy (the_swig_Type))));
               my_view_array_Type         : constant c_Type.view        := Self.name_Map_of_c_type.Element (the_c_Type.Name & "*[]");
            begin
               Self.swig_type_Map_of_c_type.insert (+array_of_pointers_swigType,
                                                    my_view_array_Type);
            end;
         end if;

         declare   -- add pointer pointer
            pointer_to_pointer_swigType : constant doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Pointer (doh_copy (the_swig_Type)));
            my_view_view_Type           : constant c_Type.view        := Self.name_Map_of_c_type.Element (the_c_Type.Name & "**");
         begin
            Self.swig_type_Map_of_c_type.insert (+pointer_to_pointer_swigType,
                                                 my_view_view_Type);
         end;


--           declare   -- register pointer pointer to 'const'
--              the_pointer_to_pointer_to_const_swigType : doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Pointer (swigtype_add_Qualifier (doh_copy (the_swig_Type), to_Doh ("const"))));
--              my_const_view_view_Type                  : c_Type.view        := Self.name_Map_of_c_type.Element ("const " & proxy_Name & "**");
--           begin
--              Self.swig_type_Map_of_c_type.insert (+the_pointer_to_pointer_to_const_swigType,
--                                                   my_const_view_view_Type);
--           end;
      end do_level_2_indirection;


--        if add_level_3_Indirection then
--           do_level_3_indirection:
--           declare
--           begin
--              if create_array_Type then   -- add associated array
--                 declare
--                    array_of_pointer_pointers_swigType : doh_swigType'Class := to_DOH ("a." & (+swigtype_add_Pointer (swigtype_add_Pointer (doh_copy (the_swig_Type)))));
--                 begin
--                    Self.swig_type_Map_of_c_type.insert (+array_of_pointer_pointers_swigType,
--                                                         the_c_type.my_view_Type.my_view_Type.my_array_Type); --_pointer_pointer_Array);
--                 end;
--              end if;
--
--
--              declare   -- add pointer pointer
--                 pointer_to_pointer_pointer_swigType : doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Pointer (swigtype_add_Pointer (doh_copy (the_swig_Type))));
--              begin
--                 Self.swig_type_Map_of_c_type.insert (+pointer_to_pointer_pointer_swigType,
--                                                      the_c_type.my_view_Type.my_view_Type.my_view_Type); --_pointer_pointer_Pointer);
--              end;
--           end do_level_3_indirection;
--
--        end if;

   end register_mirror;



   procedure associate (Self : access Item;   the_ada_Type : in ada_Type.view;
                                              with_c_Type  : in c_Type  .view)
   is
   begin
--        log ("associate ada type '" & the_ada_Type.qualified_Name & "'");
--        log ("     with c   type '" & with_c_Type .qualified_Name & "'");

      Self.c_type_Map_of_ada_type.insert (with_c_Type, the_ada_Type);
   end associate;



   function current_Module (Self : access Item) return swig_Module.swig_Module_view
   is
      the_Module : swig_Module.swig_Module_view;
   begin
      if exists (Self.current_c_Node)
      then
         --  return Self.name_Map_of_module.Element (+owner_module_Name_of (Self.current_c_Node));

         declare
            the_Node   : doh_Node'Class renames doh_Node'Class (Self.current_c_Node);
            the_Parent : doh_Node'Class      := parent_Node (the_Node);
            parent_node_Type : unbounded_String;
         begin

            while exists (the_Parent)
            loop
               parent_node_Type := +node_Type (the_Parent);
--                 log ("***parent node type: " & parent_node_Type);

               if parent_node_Type = "import"
               then
                  declare
                     --  parent_Name : String := +get_Attribute (the_Parent, -"name");
                     parent_module_Name : constant String := +get_Attribute (the_Parent, -"module");
                     --                     the_Head    : String := Head (parent_Name,  Index (parent_Name, ".") - 1);
                  begin
--                       log ("parent_module_Name: " & parent_module_Name);
                     the_Module := Self.demand_Module (+parent_module_Name);
                     --  the_Package := old_demand_Package (Self, the_Head);
                     exit;
                  end;

               elsif parent_node_Type = "top"
               then
                  the_Module := Self.Module_top'Access;
                  exit;
               end if;

               the_Parent := parent_Node (the_Parent);
            end loop;
         end;

      else
         the_Module := Self.Module_core'Access;   -- raise constraint_Error;   -- the_Kind := Core;
      end if;

      --        log ("returning module: " & the_Module.Name);

      return the_Module;
   end current_Module;



   function fetch_ada_Type (Self : access Item;   Named : in unbounded_String) return ada_Type.view
   is
   begin
      return Self.name_Map_of_ada_type.Element (Named);
   end fetch_ada_Type;



   function fetch_c_Type (Self : access Item;   Named : in unbounded_String) return c_Type.view
   is
   begin
      return Self.name_Map_of_c_type.Element (Named);
   end fetch_c_Type;



   function demand_c_Type_for (Self : access Item;   the_doh_swig_Type : in doh_swigType'Class) return c_Type.view
   is

      the_Type           : c_Type.view;
--        swig_Type_stripped : constant doh_swigType'Class :=  SwigType_strip_qualifiers (doh_Copy (the_doh_swig_Type));   -- tbd: stripping is redundant
      --        ada_type_Name      : unbounded_String   := +Swig_typemap_lookup       (-"adatype",  swig_Type_stripped,  null_Doh, null_Wrapper);

   begin
--        log ("'demand_c_Type' - doh_swig_Type: '" & String'(+the_doh_swig_Type) & "'");

      the_Type := Self.swig_type_Map_of_c_type.Element (+the_doh_swig_Type);
      return the_Type;

   exception
      when Constraint_Error =>   -- no element in map
         if the_Type = null
         then   -- c type has not yet been declared, so create it as an 'unknown' c type.
            declare
--                 the_Descriptor : constant unbounded_String := Self.to_Descriptor (swig_Type_stripped);
            begin
--                 log ("descriptor: '" & the_Descriptor & "'");
               the_Type := c_type.new_unknown_Type;        -- 'Unknown' type is a mutable variant record, so it can be morphed.

               the_Type.nameSpace_is (Self.current_c_Namespace);
               the_Type.Name_is      (+the_doh_swig_Type);

               Self.register (the_Type, the_doh_swig_Type);
            end;
         end if;

         return the_Type;
   end demand_c_Type_for;



   function demand_Module (Self : access Item;   Named : in unbounded_String) return swig_Module.swig_Module_view
   is
      the_Module : swig_Module.swig_Module_view;
   begin
--        log ("demand_Module - named: '" & Named & "'");

      the_Module := Self.name_Map_of_module.Element (Named);
      return the_Module;

   exception
      when Constraint_Error =>   -- no element in map
         declare
--              the_Descriptor : constant unbounded_String := Self.to_Descriptor (to_Doh (to_String (Named)));
         begin
--              log ("descriptor: '" & the_Descriptor & "'");

            the_Module := new swig_Module.item;
            the_Module.define (Named, Self.Package_standard); --           the_Module.Name := Named;

            Self.name_Map_of_module.insert (Named, the_Module);
            Self.new_Modules       .append (the_Module);
         end;

         return the_Module;
   end demand_Module;



   function current_c_Namespace (Self : access Item) return c_nameSpace.view
   is
   begin
      return Self.c_namespace_Stack.last_Element;
   end current_c_Namespace;



   function current_c_Class (Self : access Item) return c_Type.view
   is
   begin
      return Self.c_class_Stack.last_Element;
   end current_c_Class;



   function to_Descriptor (Self : access Item;   swig_Type : in doh_swigType'Class) return unbounded_String
   is
      --  the_Name       : unbounded_String := +swig_Type;
      the_Name       : constant unbounded_String := Self.my_stripped (swig_Type);
      the_Descriptor :          unbounded_String := class_Prefix_in (the_Name);
   begin
--        log ("NAME: '" & the_Name & "'");

      if the_Descriptor = "" then
         the_Descriptor := the_Name;
      end if;

      replace_all (the_Descriptor,   ").",  "_ret_");
      replace_all (the_Descriptor,   "f(",  "f_");
      replace_all (the_Descriptor,   "p.",  "p_");
      replace_all (the_Descriptor,   "r.",  "r_");
      replace_all (the_Descriptor,   ",",  "_");

      replace_all (the_Descriptor,   ".",  "_");

      replace_all (the_Descriptor,   "<",  "_");
      replace_all (the_Descriptor,   ">",  "");
      replace_all (the_Descriptor,   "(",  "");
      replace_all (the_Descriptor,   ")",  "");
      replace_all (the_Descriptor,   " ",  "");

      return the_Descriptor;
   end to_Descriptor;



   function my_stripped (Self : access Item;   swig_Type : in doh_swigType'Class) return unbounded_String
   is
      stripped_swig_Type     : unbounded_String := +SwigType_strip_qualifiers (swig_Type);
   begin
      --      log ("'my_stripped'  ~  swig_Type: '" & String'(+swig_Type) & "'");

      strip_enum_Prefix                     (stripped_swig_Type);
      --      log ("stripped_swig_Type: '" & to_String (stripped_swig_Type) & "'");

      strip_leading_global_namespace_Prefix (stripped_swig_Type); -- tbd: add this below in demand_Type also ?!
      --      log ("stripped_swig_Type: '" & to_String (stripped_swig_Type) & "'");

      --  Strip namespace Prefix, if any.
      --
      declare
         Cursor : namespace_Sets.Cursor := First (Self.a_Namespaces);
      begin
         while has_Element (Cursor)   -- Loop til there are no more namespaces left.
         loop
            declare
               the_Namespace   : constant String  := to_String (Element (Cursor)) & "::";
               namespace_Index : constant Natural := Index     (stripped_swig_Type,  the_Namespace);
            begin
               --               log ("the_Namespace: '" & the_Namespace &"'");

               if namespace_Index /= 0 then
                  delete (stripped_swig_Type,  namespace_Index,  namespace_Index + the_Namespace'Length - 1);
                  --                  log ("stripped_swig_Type: '" & to_String (stripped_swig_Type) & "'");
                  Cursor := First (Self.a_Namespaces);  -- restart
               else
                  next (Cursor);
               end if;
            end;
         end loop;
      end;

      --  Strip array bounds, if any.
      --
      declare
         bounds_Start : Natural;
         bounds_End   : Natural;
      begin
         loop
            bounds_Start := Index (stripped_swig_Type,  "a(");
            exit when bounds_Start = 0;                              -- loop repeatedly til there are no more array bounds left
            bounds_End   := Index (stripped_swig_Type,  ")", from => bounds_Start);

            delete (stripped_swig_Type,  bounds_Start + 1,  bounds_End);
            --            log ("stripped_swig_Type: '" & to_String (stripped_swig_Type) & "'");
         end loop;
      end;

--        log ("final stripped swig_Type: '" & to_String (stripped_swig_Type) & "'");

      return stripped_swig_Type;
   end my_stripped;



   function current_class_namespace_Prefix (Self : access Item) return unbounded_String
   is
   begin
      if Self.c_class_Stack.Is_Empty
      then
         return null_unbounded_String;
      else
         declare
            Name : constant String := +Self.c_class_Stack.last_Element.Name;
         begin
            if Name = "std"
            then
               return null_unbounded_String;
            else
               return +Name & "::";
            end if;
         end;
      end if;

--        if Self.current_class_Record = null
--        then
--           return null_unbounded_String;
--        else
--           declare
--              package_Name : constant unbounded_String := Text_after_first_dot (Self.current_class_Record.declaration_Package.qualified_Name);
--           begin
--              return package_Name & "::";
--           end;
--        end if;
   end current_class_namespace_Prefix;



   procedure add_Namespace (Self : access Item;   Named : in unbounded_String)
   is
      --      Cursor : namespace_Sets.Cursor := First (Self.a_Namespaces);
   begin
      --        while has_Element (Cursor) loop
      --
      --           log ("existing namespace: " & Element (Cursor));
      --
      --           next (Cursor);
      --        end loop;

      insert (Self.a_Namespaces, Named);

   exception
      when Constraint_Error => log ("attempt to add namespace '" & to_String (Named) & "' twice ... ignoring !"); --
   end add_Namespace;



   function get_overloaded_Name (Self : access Item;   for_Node : in doh_Node'Class) return String
   is
      pragma Unreferenced (Self);
      the_Name : constant String := +get_Attribute (for_Node,  -"sym:name");
   begin
      if exists (get_Attribute (for_Node,  -"sym:overloaded")) then
         return  the_Name & (+get_Attribute (for_Node,  -"sym:overname"));       -- add overload suffix
      else
         return  the_Name;
      end if;

      --      convert_to_ada_Identifier (overloaded_name);
   end get_overloaded_Name;



   function to_ada_subProgram (Self : access Item;   the_c_Function : in c_Function.view) return ada_subProgram.View
   is
      the_ada_subProgram : ada_subProgram.view;
   begin
--        log ("to_ada_subProgram ~ the_c_Function.return_Type: '" & the_c_Function.return_Type.qualified_Name & "'");

      the_ada_subProgram := new_ada_subProgram (ada_Utility.to_ada_Identifier (the_c_Function.Name),
                                                Self.c_type_Map_of_ada_type.Element (the_c_Function.return_Type));
      --        the_ada_subProgram.Parameters  := Self.to_ada_Parameters (the_c_function.Parameters);
      the_ada_subProgram.link_Symbol := the_c_Function.link_Symbol;
      the_ada_subProgram.is_Virtual  := the_c_Function.is_Virtual;

      the_ada_subProgram.is_Constructor  := the_c_Function.is_Constructor;

      return the_ada_subProgram;
   end to_ada_subProgram;



   function to_ada_Variable (Self : access Item;   the_c_Variable : in c_Variable.view) return ada_Variable.view
   is
      the_ada_variable : ada_Variable.view;
   begin
--        log ("to_ada_Variable ~ the_c_Variable.my_Type: '" & the_c_Variable.my_Type.Name & "'");
      the_ada_variable := new_ada_Variable (ada_Utility.to_ada_Identifier       (the_c_Variable.Name),
                                            Self.c_type_Map_of_ada_type.Element (the_c_Variable.my_Type),
                                            the_c_Variable.Value);

      for Each in 1 .. Integer (the_c_Variable.array_Bounds.Length)
      loop
         the_ada_Variable.array_Bounds.append (the_c_Variable.array_Bounds.Element (Each));
      end loop;

      return the_ada_Variable;
   end to_ada_Variable;



   function makeParameterName (Self : access Item;   parameter_List : in doh_parmList'Class;
                                                     the_Parameter  : in doh_Parm    'Class;
                                                     arg_num        : in Integer) return String
   is
      pragma Unreferenced (Self, arg_num);
      the_Name : constant String             := +get_Attribute (the_Parameter,  -"name");
      Count    : Natural            := 0;
      plist    : doh_parmList'Class := parameter_List;            -- tbd: better name
   begin
      --  Use C parameter name unless it is a duplicate or an empty parameter name
      --
      while exists (plist)
      loop
         if the_Name = String'(+get_Attribute (plist, -"name")) then
            Count := Count + 1;
         end if;

         plist := next_Sibling (plist);
      end loop;

      if the_Name = ""  or  Count > 1 then
         return  the_Name  &  "arg_"  &  trim (Natural'Image (Count), ada.strings.Left);
      else
         return  the_Name;
      end if;
   end makeParameterName;



   procedure freshen_current_module_Package (Self : access Item;   for_Node : in doh_Node'Class)
   is
      pragma Unreferenced (Self);
--        current_module_Name : String := owner_module_Name_of (for_Node);
   begin
      null; -- tbd: Self.current_module_Package := Self.old_fetch_Package (named => current_module_Name);
   end freshen_current_module_Package;



   function to_c_Parameters (Self : access Item;   swig_Parameters : in doh_ParmList'Class) return c_parameter.Vector
   is
      the_gnat_Parameters : c_parameter.Vector;
   begin
--        log ("'to_c_Parameters'");

      Swig_typemap_attach_parms (-"in",                 swig_Parameters, null_Wrapper);    -- attach the non-standard typemaps to the parameter list
      Swig_typemap_attach_parms (-"adatype",            swig_Parameters, null_Wrapper);    --
      Swig_typemap_attach_parms (-"adain",              swig_Parameters, null_Wrapper);    --
      Swig_typemap_attach_parms (-"imtype",             swig_Parameters, null_Wrapper);    --
      Swig_typemap_attach_parms (-"link_symbol_code",   swig_Parameters, null_Wrapper);    --

      declare
         num_arguments : constant Integer        := emit_num_arguments (swig_Parameters);
         the_Parameter :          doh_Parm'Class := swig_Parameters;
         Index         :          Integer        := 0;
      begin
         emit_mark_varargs (swig_Parameters);

--           log ("num_arguments: " & Integer'Image (num_arguments));

         while exists (the_Parameter)
         loop
            if check_Attribute (the_Parameter,  -"varargs:ignore",  -"1")
            then
               the_Parameter := next_Sibling (the_parameter);                            -- ignored varargs

            elsif check_Attribute (the_Parameter,  -"tmap:in:numinputs",  -"0")
            then
               the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");         -- Ignored parameters

            else
               if not (Self.variable_wrapper_flag  and  Index = 0)
               then   -- Ignore the 'this' argument for variable wrappers.
                  declare
                     use c_Parameter.Vectors;
                     param_swigType : doh_SwigType'Class  := doh_Copy (get_Attribute (the_parameter,  -"type"));
                  begin
                     strip_all_qualifiers (param_swigType);

                     if not (String'(+param_swigType) = "")
                     then   -- guard against an empty parameter list
--                          log ("to_c_Parameters ~ param_swigType: '" & to_String (+param_swigType) & "'");

                        strip_all_qualifiers (doh_swigType (param_swigType));

                        --                          if SwigType_isqualifier (param_swigType) /= 0 then   -- strip 'const' qualifier
                        --                             param_swigType := SwigType_del_qualifier   (param_swigType);
                        --                             log ("param_swigType ~ qualifer has been stripped: '" & String'(+param_swigType) & "'");
                        --                          end if;

                        if SwigType_isarray (param_swigType) /= 0
                        then   -- transform the c array to its equivalent c pointer
                           param_swigType := SwigType_del_array   (param_swigType);
                           param_swigType := SwigType_add_pointer (param_swigType);
--                             log ("param_swigType ~ array transformed to pointer: '" & String'(+param_swigType) & "'");
                        end if;

                        declare
                           arg            : constant unbounded_String := to_unbounded_String (Self.makeParameterName (swig_Parameters, the_Parameter, Index));
                           new_Parameter  : constant c_Parameter.view := new_c_Parameter     (arg,  Self.swig_type_Map_of_c_type.Element (+param_swigType));
                           --                             new_Parameter  : c_Parameter.view := new_c_Parameter  (arg,  Self.demand_Type (the_Node, param_swigType));
                        begin
                           new_Parameter.link_symbol_Code := +get_Attribute       (the_Parameter,  -"tmap:link_symbol_code");
                           new_Parameter.is_Pointer       :=         SwigType_isreference (param_swigType) /= 0
                                                             or else SwigType_ispointer   (param_swigType) /= 0;

--                             log ("adding new parameter: " & new_Parameter.Name
--                                  & " type: " & new_parameter.my_type.name
--                                  & "  is pointer : " & Boolean'Image (new_parameter.is_Pointer));

                           append (the_gnat_Parameters,  new_Parameter);
                        end;
                     end if;
                  end;
               end if;

               the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");
            end if;


            Index := Index + 1;
         end loop;
      end;

      return the_gnat_Parameters;
   end to_c_Parameters;



   function to_ada_Parameters (Self : access Item;   the_c_Parameters : in c_parameter.Vector) return ada_Parameter.vector
   is
      use c_parameter.Vectors;

      the_ada_Parameters : ada_Parameter.vector;

      Cursor            : c_Parameter.Cursor := the_C_Parameters.First;
      the_c_Parameter   : c_Parameter.view;
   begin
      while has_Element (Cursor)
      loop
         the_c_Parameter := Element (Cursor);
--           log ("to_ada_Parameters ~ the_c_Parameter.typeName: '" & the_c_Parameter.my_Type.qualified_Name & "'");

         declare
            the_ada_Parameter : constant ada_Parameter.view
              := new_ada_Parameter (the_c_Parameter.Name,
                                    Self.c_type_Map_of_ada_type.Element (the_c_Parameter.my_Type));
         begin
--              log ("to_ada_Parameters ~ the_ada_Parameter.typeName: '" & the_ada_Parameter.my_Type.qualified_Name & "'");
            the_ada_Parameters.append (the_ada_Parameter);
         end;

         next (Cursor);
      end loop;

      return the_ada_Parameters;
   end to_ada_Parameters;



   function new_c_Function (Self : access Item;   the_Node       : in     doh_Node'Class;
                                                  function_name  : in     unbounded_String;
                                                  nameSpace      : in     c_nameSpace.view;
                                                  is_Constructor : in     Boolean         := False) return c_function.view
   is
      use c_parameter.Vectors;

      the_swigType               : doh_swigType'Class   := doh_Copy (get_Attribute (the_Node,  -"type"));
--        swigType_resolved          : doh_swigType'Class   := SwigType_typedef_resolve_all (the_swigType);
      --  swigType_resolved          : doh_swigType'Class   := doh_Copy (the_swigType);

      parameter_list             : doh_ParmList'Class   := get_Attribute (the_Node,  -"parms");
      the_Parameters             : c_parameter.Vector;

      the_return_type            : c_Type.view;

      return_by_Reference        : constant Boolean              := SwigType_isreference (the_swigType) /= 0;
      return_by_Pointer          : constant Boolean              := SwigType_ispointer   (the_swigType) /= 0;

   begin
--        log ("'new_Function'    name: '" & function_name & "'     swig_type: '" & String'(+the_swigType) & "'");
      Self.current_c_Node := doh_Node (the_Node);

--        Self.current_Node := doh_Node (the_Node);

      freshen_current_module_Package (Self, the_Node);

      if String'(+get_Attribute (the_Node, -"overload:ignore")) /= "" then   return null;   end if;     -- wrappers not wanted for some methods where the parameters cannot be overloaded in Ada

      --  parameters
      --

      if exists (parameter_list) then

         if SwigType_type (get_Attribute (parameter_list, -"type")) = T_VOID then
            parameter_list := next_Sibling (parameter_list);
         end if;

      end if;

--        if         Self.current_class_Record /= null
      if         not Self.c_class_Stack.is_Empty
        and then     Self.c_class_Stack.Last_Element.Name /= "std"
        and then not Self.static_flag
        and then not is_Constructor
      then    -- add the class 'Self' controlling parameter.
         declare
            self_Parameter : constant c_Parameter.view := new_c_Parameter (the_name => to_unbounded_String ("Self"),
                                                                  the_type => Self.current_c_Class.all'Access);
         begin
            append (the_Parameters,  self_Parameter);
         end;
      end if;

      append (the_Parameters,  Self.to_c_Parameters (parameter_List));


      --  the return type
      --
      if is_Constructor then
         the_return_Type := Self.current_c_Class.all'Access;
         --           the_return_Type := Self.current_class_Record.all'access;
      else

         declare
            virtualtype : constant doh_swigType'Class := get_Attribute (the_Node,  -"virtual:type");
         begin
            if exists (virtualType) then                             -- note that in the case of polymorphic (covariant) return types, the method's
               the_return_Type := Self.swig_type_Map_of_c_type.Element (+virtualType);
               --                 the_return_Type := Self.demand_Type (the_Node, virtualtype);
               log ("covariant return types not supported in Ada ... proxy method will return " & String'(+SwigType_str (virtualtype, null_Doh)));  -- tbd: ??
            else
               strip_all_Qualifiers (the_swigType);
--                 log ("the_return_Type: '" & String'(+the_swigType) & "'");
               the_return_Type := Self.swig_type_Map_of_c_type.Element (+the_swigType);
               --                 the_return_Type := Self.demand_Type (the_Node, the_swigType);
            end if;
         end;
      end if;


      --  'throw's and exceptions (tbd)
      --
      --      generateThrowsClause (node, spec_function_code);
      --      Printf (spec_function_code, "\n\n");

      --
      --      generateThrowsClause (node, body_function_code);
      --      Printf (body_function_code,
      --              " %s  end %s;\n\n",
      --              type_map ? (const String *)
      --                       : empty_string,
      --              proxy_function_name);
      --
      --      Replaceall  (body_function_code, ".item  ", " ");    // hack to remove superfluous '.item  ' which is generated
      --                                                           // for functions returning enums
      --      */


      if not (Self.wrapping_member_flag  and  not Self.enum_constant_flag) then     -- there is no need for setter/getter functions, since the actual object is available.
         declare
            use c_nameSpace, c_Function;
            new_Function : constant c_Function.view := new_c_Function (function_name,
                                                                       the_return_type);
         begin
            new_Function.Parameters        := the_Parameters;
            new_Function.link_Symbol       := Self.current_linkage_Symbol;
            new_Function.returns_an_Access := return_by_Reference  or  return_by_Pointer;

            if    checkAttribute (the_Node, -"access",  -"public")    /= 0 then    new_Function.access_Mode := public_access;
            elsif checkAttribute (the_Node, -"access",  -"protected") /= 0 then    new_Function.access_Mode := protected_access;
            elsif checkAttribute (the_Node, -"access",  -"private")   /= 0 then    new_Function.access_Mode := private_access;
            else                                                                   new_Function.access_Mode := unknown;
            end if;

            if nameSpace = Self.nameSpace_std then
               new_Function.is_Static   := True;
            else
               new_Function.is_Static   := Self.static_flag;
               new_Function.is_Virtual  := checkAttribute (the_Node,  -"storage",  -"virtual") /= 0;
               new_Function.is_Abstract := checkAttribute (the_Node,  -"abstract", -"1")       /= 0;
            end if;

            nameSpace.add (new_Function.all'Access);
            return new_Function;
         end;
      else
         return null;
      end if;

   end new_c_Function;



   procedure add_array_Bounds_to (Self : access Item;   the_Variable   : in c_Variable.view;
                                                        from_swig_Type : in doh_swigType'Class)
   is
      use c_Variable.array_bounds_Vectors;

      swig_Type_copy             : constant doh_swigType'Class      := doh_Copy (from_swig_Type);
      the_Array                  : constant doh_SwigType'Class      := SwigType_pop_arrays (swig_Type_copy);
      dimension_Count            : constant Natural                 := SwigType_array_ndim (the_Array);
      --      element_Type               : doh_SwigType'Class      := SwigType_array_type (swig_Type_copy);
      --      element_ada_Type           : doh_String'Class        := Swig_typemap_lookup (-"record_component_array_adatype", element_Type, null_Doh, null_Doh, null_Doh, null_Doh, null_Wrapper);

      array_dimension_Expression : aliased unbounded_String;
      resolved_array_Dimension   :         Integer;

   begin
--        log ("'add_array_Bounds_to'  ~  swig_Type_copy: '" & String'(+swig_Type_copy) & "'     the_Array: '" & String'(+the_Array)
--             & "'    dimension_Count: " & Natural'Image (dimension_Count));   -- & "  element_Type: '" &  String'(+element_Type)
--        --             & "'"); --    element_ada_Type: '" & String'(+element_ada_Type) & "'");

      for Each in 1 .. dimension_Count
      loop
         array_dimension_Expression := +SwigType_array_getdim (the_Array, Each - 1);
--           log ("array_dimension_Expression: '" & array_dimension_Expression & "'");

         if array_dimension_Expression = "" then
            resolved_array_Dimension := 0;
         else
            resolved_array_Dimension := Integer (Value (resolved_c_integer_Expression (Self,  array_dimension_Expression,
              Self.symbol_value_Map,
              Self.current_class_namespace_Prefix)));
         end if;

         append (the_Variable.array_Bounds,  resolved_array_Dimension - 1);
      end loop;
   end add_array_Bounds_to;




   --------------
   --  Operations
   --

   overriding function  main_is_overridden (Self : in Item) return Boolean is begin return True; end main_is_overridden;

   overriding procedure main (Self : in out Item;   argc : in Integer;
                                                    argv : in swig_p_p_char.Item'Class)
   is
      Each : Integer := 0;
   begin
      verbosity_Level := Debug;
--        verbosity_Level := Status;

      indent_Log;
      log ("",                   Status);
      log ("Parsing C headers.", Status);

      log ("");
      log ("main");
      --  delay 25.0;           -- allow gdb time to attach

      SWIG_library_directory (new_String ("gnat"));

      --  Parse the command line
      --
      while Each < argC
      loop
         declare
            the_Command : constant String := Value (String_in (argv, Each));
         begin
            if the_Command = "-namespace"
            then
               if Each + 1 < argC
               then
--                    Self.namespace_Package := Self.old_demand_Package (named => Value (String_in (argv,  Each + 1)));
--                    Self.namespace_Package.is_global_Namespace;

                  Swig_mark_arg (Each);
                  Swig_mark_arg (Each + 1);

                  Each := Each + 1;            -- Skip the next argument, as it has just been used.
               else
                  Swig_arg_error;
               end if;

            elsif the_Command = "-noproxy"
            then
               Self.proxy_Flag := False;
               Swig_mark_arg (Each);

            elsif the_Command = "-c++"
            then
               Self.in_CPP_mode := True;
               Swig_mark_arg (Each);

            elsif the_Command = "-help"
            then
               for Each in usage_help_Text'Range loop
                  put_Line (usage_help_Text (Each).all);
               end loop;
            end if;

            Each := Each + 1;
         end;
      end loop;


      declare
         Unused : doh_item'Class := Preprocessor_define (-"SWIGGNAT 1", 0);   -- Add a symbol to the parser for conditional compilation.
         pragma Unreferenced (Unused);
      begin
         SWIG_typemap_lang (new_String ("gnat"));                             -- Add typemap definitions.
         SWIG_config_file  (-"gnat.swg");
      end;

      Self.allow_Overloading;
      Self.allow_protected_and_private_Members;

      unindent_Log;
   end main;



   overriding function top_is_overridden (Self : in Item) return Boolean is begin return True; end top_is_overridden;

   overriding function top (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node     : doh_Node'Class renames n;
--        options_Node : doh_Node'Class   := get_Attribute (get_Attribute (the_Node, -"module"),    -- get any options set in the module directive
--                                                          -"options");
      module_Name  : constant unbounded_String := +get_Attribute (the_Node, -"name");
   begin
      indent_Log;
      log ("top");

      --        -- check options
      --
      --        if exists (options_Node) then
      --           declare
      --              the_Option : doh_Node'Class := get_Attribute (the_Node, -"imclassname");
      --           begin
      --              if exists (the_Option) then
      --                 append (Self.imclass_Name,  to_String (the_Option));      -- tbd: needed ?
      --              end if;
      --           end;
      --        end if;


      --  Initialize all of the output files.
      --
      Self.f_runtime := doh_File (new_File (name => get_Attribute (the_Node, -"outfile"),
                                            mode => new_String ("w")));
      if not exists (Self.f_Runtime) then
         log ("unable to open " & to_String (get_Attribute (the_Node, -"outfile")));
         exit_with_Fail;
      end if;

      Self.f_init     :=  -("");
      Self.f_header   := to_Doh ("");
      Self.f_wrappers := to_Doh ("");
      Self.f_gnat     := to_Doh ("");

      Swig_register_filebyname (-"header",        Self.f_header);              -- register file targets with the SWIG file handler
      Swig_register_filebyname (-"wrapper",       Self.f_wrappers);
      Swig_register_filebyname (-"runtime",       Self.f_runtime);
      Swig_register_filebyname (-"init",          Self.f_init);
      Swig_register_filebyname (-"gnat_support",  Self.f_gnat);


      --  Setup the principal namespace and module package names.
      --
      Self.Module_top.define (module_Name, Self.Package_standard);

--        Self.namespace_Package := Self.old_demand_Package (named => to_String (module_Name));
--        Self.namespace_Package.is_global_Namespace;
--        Self.namespace_Package.Kind_is (Binding);
--
--        Self.binding_Package := Self.old_demand_Package (named => to_String (module_Name & "." & "Binding")); -- tbd: add command-line switch to allow this default to be modified.
--        Self.binding_Package.is_Module;
--
--        Self.types_Package := Self.old_demand_Package (named => to_String (module_Name & "." & "Types")); -- tbd: add command-line switch to allow this default to be modified.
--        Self.types_Package.is_Module;
--
--        Self.conversions_Package := Self.old_demand_Package (named => to_String (module_Name & "." & "Conversions")); -- tbd: add command-line switch to allow this default to be modified.
--        Self.conversions_Package.is_Module;


      --  Print the SWIG banner message.
      --
      Swig_banner (Self.f_runtime);

      --   Convert 'protected' and 'private' member access to public access, within the generated C runtime.
      --   This is to allow access to protected or private copy constructor and is subject to review (tbd).
      --
      print_to (Self.f_header,    "#define protected public");
      print_to (Self.f_header,    "#define private   public");
      --  and destructor, needed by the replacement 'gnat_' constructor.
      print_to (Self.f_wrappers,  "#undef protected");
      print_to (Self.f_wrappers,  "#undef private");

      --  Register names with swig core.
      --
      declare
         wrapper_Name : constant String := "Ada_%f"; -- & to_String (Self.imclass_Name);
      begin
         Swig_name_register (-"wrapper", -wrapper_Name);
         Swig_name_register (-"set",     -"set_%v");
         Swig_name_register (-"get",     -"get_%v");
         Swig_name_register (-"member",  -"%c_%m");
      end;

      print_to (Self.f_wrappers, "#ifdef __cplusplus ");
      print_to (Self.f_wrappers, "extern ""C"" {");
      print_to (Self.f_wrappers, "#endif");

      print_to (Self.f_gnat,     "#ifdef __cplusplus");
      print_to (Self.f_gnat,     "extern ""C"" {");
      print_to (Self.f_gnat,     "#endif");


      --   Do the base Language 'top' to recursively process all nodes.
      --   As each node is processed, the base 'top' will call the relevant
      --   specialised operation in our 'gnat_Language' package.
      --
      do_base_Top (Self.all, the_Node);


      print_to (Self.f_wrappers, "#ifdef __cplusplus");
      print_to (Self.f_wrappers, "}");
      print_to (Self.f_wrappers, "#endif");

      print_to (Self.f_gnat, "#ifdef __cplusplus");
      print_to (Self.f_gnat, "}");
      print_to (Self.f_gnat, "#endif");


--        verify_all_packages :
--        declare
--           Cursor : swig_type_package_Maps.Cursor := First (Self.all_Packages);
--        begin
--           log ("");
--           log ("Verifying packages.", Status);
--
--           while has_Element (Cursor) loop
--  --              log ("" & Element (Cursor).qualified_Name & " is being verified");
--              Element (Cursor).verify;
--              next    (Cursor);
--           end loop;
--
--           Self.    binding_Package.verify;
--           Self.  namespace_Package.verify;
--           Self.      types_Package.verify;
--           Self.conversions_Package.verify;
--        end verify_all_packages;


--        add_Pointers_for_all_virtual_cpp_class_Types : -- old
--        declare
--           all_Types : constant gnat_Type.Views := Self.all_types_Container.all_Types;
--        begin
--  --           log ("adding Pointers for all virtual cpp class Types");
--
--           for Each in all_Types'Range
--           loop
--              declare
--                 the_Type       : constant gnat_Type.view := all_Types (Each);
--                 new_Subprogram : gnat_Subprogram.view;
--              begin
--                 if             the_Type.c_type_Kind = c_Class
--                   and then     the_Type.is_Virtual
--                   and then not the_Type.is_Interface_Type
--                 then
--                    Self.namespace_Package.add (new_type => new_virtual_class_Pointer (declaration_Package => Self.namespace_Package,
--                                                                                       Name                => the_Type.declaration_Package.Name & "_Pointer",
--                                                                                       base_Type           => Self.all_types_Container.fetch_Type ("system.Address")));
--                    new_Subprogram := new_gnat_Subprogram (the_Name => +"to_View",
--                                                           the_Type => the_type);
--                    new_Subprogram.is_to_view_Conversion := True;
--                    Self.conversions_Package.add (new_Subprogram);
--
--
--                    new_Subprogram := new_gnat_Subprogram (the_Name => +"to_Pointer",
--                                                           the_Type => Self.all_types_Container.fetch_Type ("system.Address"));
--                    new_Subprogram.Parameters.append (new_gnat_Parameter (+"Self", the_Type));
--                    new_Subprogram.is_to_pointer_Conversion := True;
--                    Self.conversions_Package.add (new_Subprogram);
--                 end if;
--              end;
--           end loop;
--        end add_Pointers_for_all_virtual_cpp_class_Types;


      --  new
      --
      process_all_Modules :
      declare
         procedure process (the_Module : in swig_Module.swig_Module_view)
         is
            new_ada_subPrograms                  : ada_subProgram.vector;
            the_ada_subprogram_Map_of_c_function : swig_Module.ada_subprogram_Maps_of_c_function.Map;
         begin
            transform_unknown_c_Types :
            declare
               use c_type.Vectors;

               Cursor : c_type.Cursor := the_Module.C.new_c_Types.First;
            begin
               while has_Element (Cursor)
               loop
                  declare
                     use c_Type, ada_Type;

                     the_c_Type       : constant c_Type.view        := Element (Cursor);
                     the_doh_swigType : constant doh_Swigtype'Class := to_Doh (to_String (the_c_Type.Name));
                     Pad              :          doh_String'Class   := doh_Copy (the_doh_swigType);
                  begin
                     if the_c_Type.is_Ignored
                     then
                        null;
--                          log ("Skipping '" & the_c_Type.Name & "'    corresponding ada_Type: '" & Self.c_type_Map_of_ada_type.Element (the_c_Type).qualified_Name & "'");

                     elsif the_c_Type.c_type_Kind = Unknown
                     then
--                          log ("Transforming 'unknown' C type: " & the_c_Type.Name & "   " & c_type.a_c_type_Kind'Image (the_c_Type.c_type_Kind));

                        if is_a_function_Pointer (the_doh_swigType)
                        then
--                             log ("Transforming function Pointer: " & the_c_Type.Name & "   " & c_type.a_c_type_Kind'Image (the_c_Type.c_type_Kind));
                           Pad := SwigType_del_pointer (Pad);
                           declare
                              raw_swigType         : constant doh_SwigType'Class := doh_Copy                (Pad);
                              the_Function         : constant doh_SwigType'Class := SwigType_pop_function   (raw_swigType);
                              function_return_Type : constant doh_SwigType'Class := doh_Copy                (raw_swigType);
                              function_Parameters  : constant doh_ParmList'Class := SwigType_function_parms (the_Function);

                              new_c_Function       : c_Function.view;
                              new_c_function_Pointer : c_Type.view;
                           begin
--                                log ("function_return_Type: '" & String'(+function_return_Type) & "'");

                              new_c_Function            := c_function.new_c_Function   (to_unbounded_String ("anonymous"),
                                                                                        Self.swig_type_Map_of_c_type.Element (+function_return_Type));
                              new_c_Function.Parameters := Self.to_c_Parameters        (function_Parameters);
                              new_c_function_Pointer    := c_type.new_function_Pointer (namespace         => Self.current_c_Namespace,
                                                                                        name              => +the_doh_swigType,
                                                                                        accessed_function => new_c_Function);
                              the_c_Type.all := new_c_function_Pointer.all;
                           end;
                        else
                           log ("Unable to transform unknown C type: " & the_c_Type.Name);
                           raise Program_Error;
                        end if;
                     end if;
                  end;

                  next (Cursor);
               end loop;
            end transform_unknown_c_Types;


            Transformer.transform (From                           => the_Module.C,
                                   Self                           => Self.all,
                                   name_Map_of_c_type             => Self.name_Map_of_c_type,
                                   name_Map_of_ada_type           => Self.name_Map_of_ada_type,
                                   c_type_Map_of_ada_type         => Self.c_type_Map_of_ada_type,
                                   incomplete_access_to_Type_i_c_pointer_List
                                                                  => Self.incomplete_access_to_Type_i_c_pointer_List,
                                   c_type_Map_of_ada_subprogram   => Self.c_type_Map_of_ada_subprogram,
                                   new_ada_subPrograms            => new_ada_subPrograms,
                                   the_ada_subprogram_Map_of_c_function
                                                                  => the_ada_subprogram_Map_of_c_function,
                                   c_namespace_Map_of_ada_Package => Self.c_namespace_Map_of_ada_Package,

                                   Result                         => the_Module.Ada);
         end process;

      begin
         --   Remember the 'std' C namespace mapping to our top level module package.
         --
         Self.c_namespace_Map_of_ada_Package.insert (Self.nameSpace_std,
                                                     Self.Module_top.Ada.Package_top);
         --  Process imported modules.
         --
         declare
            use swig_Module.module_Vectors;
            Cursor : swig_Module.module_vectors.Cursor := Self.new_Modules.first;
         begin
            while has_Element (Cursor)
            loop
               log ("Tranforming module: '" & Element (Cursor).Name & "'", Status);
               process (Element (Cursor));
               next             (Cursor);
            end loop;
         end;

         --  Process the main module.
         --
         log ("");
         log ("Tranforming the main module.", Status);
         process (Self.Module_top'Access);
      end process_all_Modules;


      --  Generate the Ada source files.
      --
      log ("");
      log ("Creating source for the main module.", Status);
      gnat_Language.source_Generator.generate (Self);


      --  Generate the C runtime.
      --
      dump                 (Self.f_header,    Self.f_runtime);
      dump                 (Self.f_wrappers,  Self.f_runtime);
      dump                 (Self.f_gnat,      Self.f_runtime);
      Wrapper_pretty_print (Self.f_init,      Self.f_runtime);
      close_File           (Self.f_runtime);

      log ("");
      log ("", Status);
      log ("Ada binding generated.", Status);
      unindent_Log;

      return SWIG_OK;
   end top;



   overriding function typemapDirective_is_overridden (Self : in Item) return Boolean  is begin return True; end typemapDirective_is_overridden;
   overriding function typemapDirective (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node     : doh_Node'Class renames n;
      --        options_Node : doh_Node'Class   := get_Attribute (get_Attribute (the_Node, -"module"),    -- get any options set in the module directive
      --                                                          -"options");

      the_Method : constant unbounded_String     := +get_Attribute (the_Node, -"method");
      the_Code   : constant unbounded_String     := +get_Attribute (the_Node, -"code");
      the_kwargs : constant unbounded_String     := +get_Attribute (the_Node, -"kwargs");

   begin
      indent_Log;
--        log ("");
--        log ("typemapDirective", Debug);

      --        log ("'typemapDirective' - method: '" & the_Method & "'      the_Code: '" & the_Code & "'   the_kwargs: '" & the_kwargs & "'");

      --        if the_method = "ctype_new" then
      --           log ("'typemapDirective' - method: '" & the_Method & "'      the_Code: '" & the_Code & "'   the_kwargs: '" & the_kwargs & "'");
      --           declare
      --              Pattern      : doh_ParmList'Class := first_Child (the_Node);
      --              pattern_Type : unbounded_String;
      --              pattern_Name : unbounded_String;
      --              new_Type     : gnat_Type.view;
      --              new_Key      : unbounded_String;
      --           begin
      --              while exists (Pattern) loop
      --                 pattern_Type := +get_Attribute (get_Attribute (Pattern, -"pattern"), -"type");
      --                 pattern_Name := +get_Attribute (get_Attribute (Pattern, -"pattern"), -"name");
      --
      --                 log ("pattern_Type: '" & pattern_Type & "'      pattern_Name: '" & pattern_Name & "'");
      --
      --                 new_Key := pattern_Type;
      --
      --                 if pattern_Name /= "" then                      -- tbd: investigate and documnet what this is for
      --                    append (new_Key, " " & pattern_Name);
      --                 end if;
      --
      --                 Self.swig_type_Map_of_c_type.insert (new_Key, Self.name_Map_of_c_type.Element (key => the_Code));
      --
      --
      --                 log ("pattern: '" & String'(+get_Attribute (get_Attribute (Pattern, -"pattern"), -"type")) & "'");
      --                 log ("name:    '" & String'(+get_Attribute (get_Attribute (Pattern, -"pattern"), -"name")) & "'");
      --
      --                 Pattern := next_Sibling (Pattern);
      --              end loop;
      --           end;
      --
      --        end if;

      if the_method = "adatype_new" then
--           log ("'typemapDirective' - method: '" & the_Method & "'      the_Code: '" & the_Code & "'   the_kwargs: '" & the_kwargs & "'");
         declare
            --  Pattern      : doh_ParmList'Class := get_Attribute (the_Node, -"firstChild");
            Pattern : doh_ParmList'Class := first_Child (the_Node);
            pattern_Type : unbounded_String;
            pattern_Name : unbounded_String;
--              new_Type     : ada_Type.view;
            new_Key      : unbounded_String;
         begin
            while exists (Pattern)
            loop
               pattern_Type := +get_Attribute (get_Attribute (Pattern, -"pattern"), -"type");
               pattern_Name := +get_Attribute (get_Attribute (Pattern, -"pattern"), -"name");

--                 log ("pattern_Type: '" & pattern_Type & "'      pattern_Name: '" & pattern_Name & "'");

               new_Key := pattern_Type;

               if pattern_Name /= "" then                      -- tbd: investigate and documnet what this is for
                  append (new_Key, " " & pattern_Name);
               end if;

--                 log ("ZZZZZZZZZZZZZZZ: '" & Self.swig_type_Map_of_c_type.Element (key => pattern_Type).qualified_Name & "'");
--                 log ("MMMMMMMMMMMMMMM: '" & Self.name_Map_of_ada_type   .Element (key => the_Code    ).qualified_Name & "'");

               Self.c_type_Map_of_ada_type.insert (Self.swig_type_Map_of_c_type.Element (key => pattern_Type),
                                                   Self.name_Map_of_ada_type.Element (key => the_Code));


--                 log ("pattern: '" & String'(+get_Attribute (get_Attribute (Pattern, -"pattern"), -"type")) & "'");
--                 log ("name:    '" & String'(+get_Attribute (get_Attribute (Pattern, -"pattern"), -"name")) & "'");


               Pattern := next_Sibling (Pattern);
            end loop;
         end;

      end if;


      --  old ...
      --
      declare
--           method_Name  : unbounded_String     := +get_Attribute (the_Node, -"method");
         ada_type_Name  : constant unbounded_String     := +get_Attribute (the_Node, -"code");
--           kwargs         : unbounded_String     := +get_Attribute (the_Node, -"kwargs");
      begin
         if the_Method = "adatype" then
            --              log ("'typemapDirective' - method: '" & the_Method & "'      ada_type_Name: '" & ada_type_Name & "'   kwargs: '" & kwargs & "'");
            --              log ("'typemapDirective' - method: '" & the_Method & "'      the_Code: '" & the_Code & "'   the_kwargs: '" & the_kwargs & "'");
            declare
               --  Pattern      : doh_ParmList'Class := get_Attribute (the_Node, -"firstChild");
               Pattern : doh_ParmList'Class := first_Child (the_Node);
               pattern_Type : unbounded_String;
               pattern_Name : unbounded_String;
--                 new_Type     : gnat_Type.view;
               new_Key      : unbounded_String;
            begin
               while exists (Pattern) loop
                  pattern_Type := +get_Attribute (get_Attribute (Pattern, -"pattern"), -"type");
                  pattern_Name := +get_Attribute (get_Attribute (Pattern, -"pattern"), -"name");

--                    log ("pattern_Type: '" & pattern_Type & "'      pattern_Name: '" & pattern_Name & "'");

                  new_Key := pattern_Type;

                  if pattern_Name /= "" then
                     append (new_Key, " " & pattern_Name);
                  end if;

                  declare
                     the_package_Name        : constant String           := Text_before_last_dot (to_String (ada_type_Name));
--                       the_declaration_Package : gnat_Package.view;
                     the_Name                : unbounded_String;
                  begin
                     if the_package_Name = "" then -- parent package is 'Standard'
--                          the_declaration_Package := Self.standard_Package;
                        the_Name                := ada_type_Name;
                     else
--                          the_declaration_Package := Self.old_demand_Package (the_package_Name);
                        the_Name                := to_unbounded_String (Text_after_last_dot (to_String (ada_type_Name)));
                     end if;


--                       if Swigtype_ispointer (-pattern_Type) /= 0 then
--                          new_Type := new_type_Pointer (declaration_package => the_declaration_Package,
--                                                        name                => the_Name,
--                                                        accessed_type       => Self.all_types_Container.fetch_Type (Swigtype_del_Pointer (-new_Key)));
--
--                          if new_Type.accessed_Type = null then
--                             log ("the pointed to type for '" & new_Key & "' does not exist ... please add it to the swig interface ('.i') file ... exiting.");
--                             exit_with_Fail;
--                          end if;
--
--                          new_type.accessed_Type.my_view_Type_is (new_Type);
--
--                       elsif Swigtype_isreference (-pattern_Type) /= 0 then
--                          new_Type := new_type_Pointer (declaration_package => the_declaration_Package,
--                                                        name                => the_Name,
--                                                        accessed_type       => Self.all_types_Container.fetch_Type (Swigtype_del_Reference (-new_Key)));
--
--                          if new_Type.accessed_Type = null then
--                             log ("the referred to type for '" & new_Key & "' does not exist ... please add it to the swig interface ('.i') file ... exiting.");
--                             exit_with_Fail;
--                          end if;
--
--                          --  new_type.accessed_Type.my_view_Type_is (new_Type);
--
--
--                       elsif Swigtype_isarray (-pattern_Type) /= 0 then
--                          new_Type := new_array_Type (declaration_package => the_declaration_Package,
--                                                      name                => the_Name,
--                                                      element_type        => Self.all_types_Container.fetch_Type (Swigtype_del_Array (-new_Key)));
--
--                          if new_Type.element_Type = null then
--                             log ("the element type for '" & new_Key & "' does not exist ... please add it to the swig interface ('.i') file ... exiting.");
--                             exit_with_Fail;
--                          end if;
--
--                          new_type.add_array_Dimension           (upper_bound => -1);     -- '-1' indicates an unconstrained array. (tbd: use a constant)
--                          new_type.element_Type.my_array_Type_is (new_Type);
--
--                          --                    elsif pattern_Type = "bool" then
--                          --                       new_Type := new_Enum (declaration_package => the_declaration_Package,
--                          --                                             name                => the_Name);
--
--                       else -- must be a basic type
--                          new_Type := new_standard_c_Type (declaration_package => the_declaration_Package,
--                                                           name                => the_Name);
--                       end if;


                  end;

--                    Self.all_types_Container.add_primal_c_Type (new_Key, new_Type);

--                    log ("pattern: '" & String'(+get_Attribute (get_Attribute (Pattern, -"pattern"), -"type")) & "'");
--                    log ("name:    '" & String'(+get_Attribute (get_Attribute (Pattern, -"pattern"), -"name")) & "'");

                  Pattern := next_Sibling (Pattern);
               end loop;
            end;

         end if;
      end;

      unindent_Log;

      return do_base_typemapDirective (Self.all, the_Node);
   end typemapDirective;



   overriding
   function moduleDirective_is_overridden (Self : in Item) return Boolean is begin   return True;   end moduleDirective_is_overridden;

   overriding
   function moduleDirective
     (Self : access Item;
      n    : in     doh_Node'Class) return Integer
   is
      the_Node : doh_Node'Class   renames n;

      the_Name           : constant unbounded_String  := +get_Attribute (the_Node, -"name");
--        new_module_Package : constant gnat_Package.view := Self.old_demand_Package (named => to_String (the_Name));
   begin
      indent_Log;
      log ("");
      log ("moduleDirective: '" & to_String (the_Name) & "'",  Debug);

--        set_Kind_for (new_module_Package, from_node => the_Node);

      --      Self.current_module_Package := new_module_Package;

      unindent_Log;
      return SWIG_OK;
   end moduleDirective;



   overriding
   function includeDirective_is_overridden (Self : in Item) return Boolean   is begin   return True;   end includeDirective_is_overridden;

   overriding
   function includeDirective (Self : access Item;   n : in  doh_Node'Class) return Integer
   is
      the_Node : doh_Node'Class   renames n;

--        the_Name            : unbounded_String  := +get_Attribute (the_Node, -"name");
      --      current_module_Name : String            := sibling_module_Name_of (the_Node);
   begin
      indent_Log;
      --      log ("'includeDirective'     - the_Name : '" & to_String (the_Name) & "'"); --      current_module_Name: '" & current_module_Name & "'");

      --        append (Self.module_Packages,  new_module_Package);
      --
      --
      --        if get_importMode /= 0 then
      --           new_module_Package.is_Import;
      --        end if;

      --      Self.current_module_Package := Self.old_fetch_Package (named => current_module_Name);

      do_base_includeDirective (Self.all, n);

      unindent_Log;
      return SWIG_OK;
   end includeDirective;



   overriding
   function namespaceDeclaration_is_overridden (Self : in Item) return Boolean is begin   return True;   end namespaceDeclaration_is_overridden;

   overriding
   function namespaceDeclaration
     (Self : access Item;
      n    : in     doh_Node'Class) return Integer
   is
      the_Node : doh_Node'Class   renames n;

      the_Name : constant unbounded_String      := +get_Attribute (the_Node, -"name");
      sym_Name : constant unbounded_String      := +get_Attribute (the_Node, -"sym:name");
   begin
      indent_Log;
      log ("");
      log ("namespaceDeclaration: '" & to_String (the_Name) & "'", Debug);
--        log ("sym_Name:             '" & to_String (sym_Name) & "'", Debug);

      if the_Name /= "" then
         Self.add_Namespace (named => the_Name);
      end if;

      do_base_namespaceDeclaration (Self.all, n);

      unindent_Log;
      return SWIG_OK;
   end namespaceDeclaration;



   overriding
   function classforwardDeclaration_is_overridden (Self : in Item) return Boolean is begin   return True;   end classforwardDeclaration_is_overridden;

   overriding
   function classforwardDeclaration (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node                   : doh_Node'Class renames n;

      node_Type                  : constant doh_swigType'Class := get_Attribute               (the_Node, -"name");  -- Swig 'forward declaration' nodes do not have a 'type' attribute, so
      the_class_Name             : constant String             := +get_Attribute              (the_Node, -"name");  -- we are using 'name' instead.
--        the_current_Module_Package : constant gnat_Package.view  := Self.current_module_Package (the_Node);

--        the_Package                : gnat_Package.view;
      the_swig_Type              : unbounded_String;

      is_a_Struct                : constant Boolean        := String'(+get_Attribute (the_Node,  -"kind"))  =  "struct";
      new_c_Class                : c_Type.view;
   begin
      indent_Log;
      log ("");
      log ("'ClassforwardDeclaration'   node_Type: '" & String'(+node_Type) & "'");

      Self.current_c_Node := doh_Node (the_Node);

      if Self.swig_type_Map_of_c_type.contains (+node_Type)
      then
         unindent_Log;
         return SWIG_OK; -- class has already been partially or fully declared, so do nothing.

--           new_c_Class := Self.swig_type_Map_of_c_type.Element (+node_Type);              -- get the 'unknown' c type
--
--           if is_a_Struct then
--              new_c_Class.all := c_Type.c_opaque_Struct_construct (namespace => Self.current_c_Namespace,      -- morph it to a c class
--                                                                   name      => +the_class_Name);
--           else
--              new_c_Class.all := c_Type.c_incomplete_Class_construct (namespace => Self.current_c_Namespace,      -- morph it to a c class
--                                                                      name      => +the_class_Name);
--           end if;
      else
         if is_a_Struct then
            new_c_Class := c_Type.new_opaque_Struct (namespace => Self.current_c_nameSpace,
                                                     name      => +the_class_Name);
         else
            new_c_Class := c_Type.new_incomplete_Class (namespace => Self.current_c_nameSpace,
                                                        name      => +the_class_Name);
         end if;
         Self.register (new_c_Class, node_Type);
      end if;

      --        Self.name_Map_of_c_type.insert (+the_class_Name, new_c_Class);
      --        Self.new_c_Types       .append (new_c_Class);

      --        Self.register (new_c_Class, node_Type);


      --  old ...
      --

--        Self.current_Node := doh_Node (the_Node);

      freshen_current_module_Package (Self, the_Node);

      --  the_swig_Type := the_current_module_Package.qualified_Name & "::" & String'(+node_Type);
      the_swig_Type := +node_Type;
--        the_Package   := Self.fetch_Package (swig_type => -the_swig_Type);

--        if the_Package = null then
--           --         the_Package := Self.demand_Package (swig_type => -(Self.current_module_Package.qualified_Name & "::" & String'(+node_Type)));
--  --           log ("creating new opaque");
--
--           declare
--              new_item_Type : gnat_Type.view := Self.all_Types_Container.fetch_Type (node_Type);
--           begin
--              if new_item_Type = null then
--                 if is_a_Struct then
--                    new_item_Type := new_opaque_Struct (declaration_Package => the_current_Module_Package, -- Self.namespace_Package,   -- Self.types_Package, -- the_Package,
--                                                        Name                => +the_class_Name); -- to_unbounded_String ("Item"));
--                 else -- must be a Class
--                    new_item_Type := new_incomplete_Class (declaration_Package => the_current_Module_Package,  -- Self.namespace_Package,  -- Self.types_Package, -- the_Package,
--                                                           Name                => +the_class_Name); -- to_unbounded_String ("Item"));
--                 end if;
--
--                 Self.all_Types_Container.add (node_Type,     new_item_Type.all'Access);
--                 Self.all_Packages.insert     (the_swig_Type, the_current_Module_Package);  -- Self.namespace_Package);  -- Self.types_Package);
--              else
--                 log ("ignoring existing class '" & String'(+node_Type) & "'");
--              end if;
--           end;
--        end if;


      --  new ...
      --

      Self.prior_c_Declaration := new_c_Class.all'Access;

      unindent_Log;
      return SWIG_OK;
   end classforwardDeclaration;



   overriding
   function nativeDirective_is_overridden (Self : in Item) return Boolean is begin   return True;   end nativeDirective_is_overridden;

   overriding
   function nativeDirective
     (Self : access Item;
      n    : in     doh_Node'Class) return Integer
   is
      the_Node       : doh_Node'Class          renames n;
      wrap_Name      : constant doh_String'Class := get_Attribute (the_Node, -"wrap:name");
      Status         : Integer;
   begin
      indent_Log;
      log ("");
      log ("'nativeDirective'");

      if Self.addSymbol (wrap_Name, the_Node) = 0 then
         return SWIG_ERROR;
      end if;


      if exists (get_Attribute (the_Node, -"type")) then
         Swig_save_1 (new_String ("nativeWrapper"),  the_Node,  new_String ("name"));
         set_Attribute (the_Node,  -"name",  wrap_Name);

         Self.native_function_Flag := True;
         Status := functionWrapper (Self, the_Node);                   -- delegate to functionWrapper
         Swig_restore (the_Node);
         Self.native_function_Flag := False;
      else
         log ("No return type for node: '" & String'(+wrap_Name));
      end if;


      unindent_Log;
      return SWIG_OK;
   end nativeDirective;



   --  tbd: addThrows is deferred til exceptions are dealt with.

   --    void
   --    GNAT::
   --    addThrows (      Node*      n,
   --               const String*    typemap,
   --                     Node*      parameter)
   --    {
   --      // Get the comma separated throws clause - held in "throws" attribute in the typemap passed in
   --      String *throws_attribute = NewStringf("%s:throws", typemap);
   --      String *throws = Getattr (parameter,throws_attribute);
   --
   --      if (throws) {
   --        String *throws_list = Getattr (n,"ada:throwslist");
   --        if (!throws_list) {
   --          throws_list = NewList();
   --          Setattr (n,"ada:throwslist", throws_list);
   --        }
   --
   --        // Put the exception classes in the throws clause into a temporary List
   --        List *temp_classes_list = Split(throws,',',INT_MAX);
   --
   --        // Add the exception classes to the node throws list, but don't duplicate if already in list
   --        if (temp_classes_list && Len(temp_classes_list) > 0) {
   --          for (Iterator cls = First(temp_classes_list); cls.item; cls = Next(cls)) {
   --            String *exception_class = NewString(cls.item);
   --            Replaceall (exception_class," ","");  // remove spaces
   --            Replaceall (exception_class,"\t",""); // remove tabs
   --            if (Len(exception_class) > 0) {
   --              // $adaclassname substitution
   --              SwigType *pt = Getattr (parameter,"type");
   --              substituteClassname (pt, exception_class);
   --
   --              // Don't duplicate the Ada exception class in the throws clause
   --              bool found_flag = false;
   --              for (Iterator item = First(throws_list); item.item; item = Next(item)) {
   --                if (Strcmp(item.item, exception_class) == 0)
   --                  found_flag = true;
   --              }
   --              if (!found_flag)
   --                Append(throws_list, exception_class);
   --            }
   --            Delete (exception_class);
   --          }
   --        }
   --        Delete (temp_classes_list);
   --      }
   --      Delete (throws_attribute);
   --    }




   overriding
   function functionWrapper_is_overridden (Self : in Item) return Boolean is begin   return True;   end functionWrapper_is_overridden;

   overriding
   function functionWrapper (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node : doh_Node'Class   renames n;
   begin
      indent_Log;
      log ("");
      log ("functionWrapper: '" & to_String ((get_Attribute (the_Node,  -"sym:name"))) & "'");

      Self.current_c_Node := doh_Node (the_Node);
--        Self.current_Node   := doh_Node (the_Node);

      freshen_current_module_Package (Self, the_Node);

      if check_Attribute (the_Node,  -"access", -"private") then     -- skip private functions (tnd: still needed ?)
         log ("skipping private function");
         unindent_Log;
         return SWIG_OK;
      end if;

      declare
         sym_Name   : constant doh_String'Class   := get_Attribute (the_Node,  -"sym:name");
         swig_Type  : constant doh_swigType'Class := get_Attribute (the_Node,  -"type");
      begin

         if not exists (get_Attribute (the_Node, -"sym:overloaded")) then
            if Self.addSymbol (get_Attribute (the_Node, -"sym:name"),  the_Node) = 0 then
               return SWIG_ERROR;
            end if;
         end if;

         --  The rest of this function deals with generating the intermediary package wrapper function (which wraps
         --  a c/c++ function) and generating the c code. Each Ada wrapper function has a matching c function call.
         --
         declare
            the_function_Wrapper : constant Wrapper.item'Class := newWrapper;
            wrapper_Def          : constant doh_String'Class   := the_function_Wrapper.get_Def;
            wrapper_Code         : constant doh_String'Class   := the_function_Wrapper.get_Code;

            overloaded_Name      : unbounded_String   := to_unbounded_String      (Self.get_overloaded_Name (the_Node));
            wrapper_Name         : constant String             := +Swig_name_wrapper       (-overloaded_name);

            the_Parameters       : constant doh_parmList'Class := get_Attribute            (the_Node,   -"parms");

            c_return_Type        : unbounded_String   := +Swig_typemap_lookup (-"ctype",   the_Node,  -"",  null_Wrapper);
            im_return_Type       : constant unbounded_String   := +Swig_typemap_lookup (-"imtype",  the_Node,  -"",  null_Wrapper);

            is_void_return       : constant Boolean            := (c_return_Type = "void");

            the_imclass_Code     : unbounded_String;     -- tbd: rename better

            Num_arguments        : Natural             := 0;
            Num_required         : Natural             := 0;

            argout_Code          : unbounded_String;
            cleanup_Code         : unbounded_String;

         begin
--              log ("overloaded_Name: '" & to_String (overloaded_Name));

            Swig_typemap_attach_parms (-"ctype",  the_Parameters, the_function_Wrapper);  -- attach the non-standard typemaps to the parameter list.
            Swig_typemap_attach_parms (-"imtype", the_Parameters, the_function_Wrapper);  --


            if c_return_Type /= "" then
               replace_All (c_return_Type,  "$c_classname", +swig_type);
            else
               log ("no ctype typemap defined for " & String'(+swig_Type));
            end if;


            if im_return_Type = "" then
               log ("no imtype typemap defined for " & String'(+swig_Type));
            end if;


            if not is_void_return then
               Wrapper_add_local_2 (the_function_Wrapper,  -"jresult",
                                    new_String (to_String (c_return_type)),
                                    new_String ("jresult"));                     -- was formerly "jresult = 0"
            end if;

            Print_to (wrapper_Def,  to_String (" DllExport " & c_return_type & " SWIGSTDCALL " & wrapper_Name & " ("));

            Self.current_linkage_Symbol := to_unbounded_String (wrapper_Name);



            --  emit_Args            (swig_Type,      the_Parameters,  the_function_Wrapper);     -- emit all local variables for holding arguments.
            emit_parameter_variables (the_Parameters,  the_function_Wrapper);                   -- emit all local variables for holding arguments.
            emit_return_variable     (the_Node, swig_Type, the_function_Wrapper);               --


            emit_attach_parmMaps (the_Parameters, the_function_Wrapper);                      -- Attach the standard typemaps


            --  parameter overloading
            --
            set_Attribute (the_Node,  -"wrap:parms",  the_Parameters);
            set_Attribute (the_Node,  -"wrap:name",   -wrapper_Name);

            if exists (get_Attribute (the_Node,  -"sym:overloaded")) then   -- wrappers not wanted for some methods where the parameters cannot be overloaded in Ada
               Swig_overload_check (the_Node);                                -- emit warnings for the few cases that can't be overloaded in Ada and give up on generating wrapper

               if exists (get_Attribute (the_Node, -"overload:ignore")) then
                  unindent_Log;
                  return SWIG_OK;
               end if;
            end if;


            if is_void_return then
               append (the_imclass_Code, "  procedure " & overloaded_name);
            else
               append (the_imclass_Code, "  function  " & overloaded_name);
            end if;


            --  get number of required and total arguments
            --
            num_arguments := emit_num_arguments (the_Parameters);
            num_required  := emit_num_required  (the_Parameters);

            if num_arguments > 0 then
               append (the_imclass_Code,  " (");
            end if;


            --  now walk the function parameter list and generate code to get arguments
            --
            do_Parameters :
            declare
               the_Parameter : doh_Parm'Class := the_Parameters;
               gen_semicolon : Boolean        := False;
            begin

               for Each in 0 .. Num_arguments - 1 loop

                  while check_Attribute (the_Parameter,  -"tmap:in:numinputs", -"0") loop   -- tbd: what is this for ?
                     the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");
                  end loop;


                  declare
                     param_swigType : constant doh_swigType'Class := get_Attribute (the_Parameter,  -"type");
                     l_Name         : constant doh_String'Class   := get_Attribute (the_Parameter,  -"lname");
                     arg            : constant String             := "j" & (+l_Name);
                     param_c_Type   : unbounded_String   := +get_Attribute (the_Parameter, -"tmap:ctype");
                     param_im_Type  : constant String             := +get_Attribute (the_Parameter, -"tmap:imtype");

                  begin

                     if param_c_Type /= "" then
                        replace_All (param_c_Type,  "$c_classname", +param_swigType);

                        replace_All (param_c_Type,  "(", " ");        -- tbd: hack to remove parentheses from template arguments
                        replace_All (param_c_Type,  ")", " ");
                     else
                        log ("no ctype typemap defined for " & String'(+param_swigType));
                     end if;

                     if param_im_Type = "" then
                        log ("no imtype typemap defined for " & String'(+param_swigType));
                     end if;

                     --  add parameter to 'intermediary' package sub-program
                     --
                     if gen_semicolon then
                        append (the_imclass_Code,  ";" & NL);
                     end if;

                     append (the_imclass_Code,  arg & " : " & param_im_Type);

                     if gen_semicolon then
                        Print_to (wrapper_Def,  "," & NL);
                     end if;

                     Print_to (wrapper_Def,  to_String (param_c_Type & " " & arg));        -- add parameter to C function

                     gen_semicolon := True;

                     --  get typemap for this argument
                     --
                     declare
                        the_typeMap : unbounded_String := +get_Attribute (the_Parameter,  -"tmap:in");
                     begin
                        if the_typeMap /= ""
                        then
                           --  addThrows (the_Node, "tmap:in", parameter);  -- tbd: add this back in for exception handling !!

                           replace_All (the_typeMap,  "$source", Arg);     -- deprecated
                           replace_All (the_typeMap,  "$target", +l_Name);      -- deprecated
                           replace_All (the_typeMap,  "$arg",    Arg);      -- deprecated ?
                           replace_All (the_typeMap,  "$input",  Arg);      -- deprecated

                           set_Attribute (the_Parameter,  -"emit:input", -Arg);

                           print_to (wrapper_Code,  the_typeMap & NL);

                           the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");
                        else
                           log ("unable to use type " & String'(+param_swigType) & " as a function argument.");
                           the_Parameter := next_Sibling (the_Parameter);
                        end if;
                     end;
                  end;
               end loop;

            end do_Parameters;


            --      /* Insert constraint checking code */
            --      for (parameter = parameter_list;  parameter; )
            --      {
            --        if ((type_map = Getattr (parameter, "tmap:check")))
            --        {
            --          addThrows (node, "tmap:check", parameter);
            --          Replaceall (type_map,"$target",Getattr (parameter,"lname")); /* deprecated */
            --          Replaceall (type_map,"$arg",Getattr (parameter,"emit:input")); /* deprecated? */
            --          Replaceall (type_map,"$input",Getattr (parameter,"emit:input"));
            --          Printv (f->code, type_map, "\n", NIL);
            --          parameter = Getattr (parameter,"tmap:check:next");
            --        }
            --        else
            --        {
            --          parameter = nextSibling (parameter);
            --        }
            --      }
            --


            --  Insert cleanup code.
            --
            declare
               the_Parameter : doh_Parm'Class := the_Parameters;
            begin
               while exists (the_Parameter)
               loop
                  declare
                     the_typeMap : unbounded_String := +get_Attribute (the_Parameter,  -"tmap:freearg");
                  begin
                     if the_typeMap /= ""
                     then
                        --  addThrows (node, "tmap:freearg", parameter);    -- tbd: deferred til exceptions done.

                        --  Replaceall (type_map, "$source", Getattr (parameter, "emit:input")); /* deprecated */
                        --  Replaceall (type_map, "$arg",    Getattr (parameter, "emit:input")); /* deprecated? */
                        replace_All (the_typeMap, "$input",  +get_Attribute (the_Parameter, -"emit:input"));

                        append (cleanup_Code,  the_typeMap & NL);

                        the_Parameter := get_Attribute (the_Parameter,  -"tmap:freearg:next");
                     else
                        the_Parameter := next_Sibling (the_Parameter);
                     end if;
                  end;
               end loop;
            end;


            --  Insert argument output code
            --
            declare
               the_Parameter : doh_Parm'Class := the_Parameters;
            begin
               while exists (the_Parameter)
               loop
                  declare
                     the_typeMap : unbounded_String := +get_Attribute (the_Parameter,  -"tmap:argout");
                  begin
                     if the_typeMap /= ""
                     then
                        --  addThrows (node, "tmap:argout", parameter);    -- tbd: deferred til exceptions done.

                        --  Replaceall (type_map, "$source", Getattr (parameter, "emit:input")); /* deprecated */
                        --  Replaceall (type_map, "$target", Getattr (parameter, "lname"));      /* deprecated */
                        replace_All (the_typeMap, "$arg",    +get_Attribute (the_Parameter, -"emit:input"));    -- deprecated ?
                        replace_All (the_typeMap, "$input",  +get_Attribute (the_Parameter, -"emit:input"));
                        replace_All (the_typeMap, "$result", "jresult");

                        append (argout_Code,  the_typeMap & NL);

                        the_Parameter := get_Attribute (the_Parameter,  -"tmap:argout:next");
                     else
                        the_Parameter := next_Sibling (the_Parameter);
                     end if;
                  end;
               end loop;
            end;


            --      // Get any Ada exception classes in the throws typemap
            --      //
            --      ParmList*      throw_parm_list = NULL;
            --
            --      if (throw_parm_list = Getattr (node, "throws"))
            --      {
            --        Swig_typemap_attach_parms ("throws", throw_parm_list, f);
            --        for (parameter = throw_parm_list;  parameter;  parameter = nextSibling (parameter))
            --        {
            --          if (type_map = Getattr (parameter, "tmap:throws"))
            --            addThrows (node, "tmap:throws", parameter);
            --        }
            --      }


            if String'(+node_Type (the_Node)) = "constant"
            then
               Swig_save_1 (to_C ("functionWrapper"),  the_Node,  to_C ("wrap:action"));      -- Wrapping a constant hack; (tbd: this is usual swig hack)

               declare      -- below based on Swig_VargetToFunction()
                  the_Type : constant doh_swigType'Class := Swig_wrapped_var_type (get_Attribute       (the_Node, -"type"),
                                                                                   use_naturalvar_mode (the_Node));
               begin
                  set_Attribute (the_Node,   -"wrap:action",
                                 -String'("result = ("  &  (+SwigType_lstr (the_Type, null_Doh))  &  ") "  &  (+get_Attribute (the_Node, -"value"))  &  ";" & NL));
               end;
            end if;


            --  Determine C type (for contructors)  (tbd: fix/remove this hack)
            --
            declare
               the_Type : constant doh_swigType'Class := doh_copy (get_Attribute (the_Node,  -"type"));
               void     : doh_Item;
            begin
               if SwigType_ispointer (the_Type) /= 0
               then
                  void := doh_Item (SwigType_del_pointer (the_Type));
               end if;

               Self.current_lStr := +doh_copy (SwigType_lstr (the_Type, null_DOH));
            end;


            if not Self.native_function_flag
            then
               --  emit_action (the_Node, the_function_Wrapper);            --  now write code to make the function call


               --                 if DohCmp (node_Type (the_Node), -"constant") = 0 then     -- Wrapping a constant hack
               --                    Swig_save ("functionWrapper", the_Node, "wrap:action", NIL);
               --                    declare
               --                       -- below based on Swig_VargetToFunction()
               --                       ty : SwigType.view := Swig_wrapped_var_type (Getattr (n, "type"), use_naturalvar_mode (n));
               --                    begin
               --                       Setattr(n, "wrap:action", NewStringf("result = (%s) %s;", SwigType_lstr(ty, 0), Getattr(n, "value")));
               --                    end;
               --                 end if;


               --  Now write code to make the function call
               --
               Swig_director_emit_dynamic_cast (n, the_function_Wrapper);   -- tbd: probably obsolete

               declare
                  actioncode : constant doh_String'Class := emit_action (n);
                  tm         : constant doh_String       := doh_String (Swig_typemap_lookup_out (-"out", n, -"result", the_function_Wrapper, actioncode));
               begin
                  --  Handle exception classes specified in the "except" feature's "throws" attribute
                  --  Self.addThrows (n, "feature:except", n);


                  --                 if Cmp (nodeType (n), "constant") == 0 then
                  --                    Swig_restore (n);
                  --                 end if;


                  --  Return value if necessary

                  if Doh_item (tm) /= null_Doh
                  then
                     --                     Self.addThrows (n, "tmap:out", n);

                     --                         Replaceall(tm, "$result", "jresult");

                     --                       if DohGetFlag (n, -"feature:new") /= 0 then
                     --                          replace_All (tm, "$owner", "1");
                     --                       else
                     --                          replace_All (tm, "$owner", "0");
                     --                       end if;

                     null;

                     --                       Print_to (the_function_Wrapper.get_code, String'(+tm));
                     --
                     --                       if Length (+tm) /= 0 then
                     --                          Print_to (the_function_Wrapper.get_code, "\n");
                     --                       end if;
                  else
                     Swig_warning (WARN_TYPEMAP_OUT_UNDEF,  -Value (get_input_file),  get_line_number,
                       new_String ("Unable to use return type" & (+SwigType_str (node_Type (the_Node), null_Doh))
                         & " in function "             & (+Get_attribute (n, -"name"))
                         & ".\n"));
                  end if;

                  --  emit_return_variable (n, node_Type (the_Node), the_function_Wrapper);
               end;
            end if;


            if String'(+node_Type (the_Node)) = "constant"
            then
               Swig_restore (the_Node);
            end if;


            if not Self.native_function_flag
            then     -- return 'result' value if necessary
               declare
                  the_typeMap : unbounded_String :=  +Swig_typemap_lookup (-"out", the_Node, -"result", null_Wrapper);
               begin

                  if the_typeMap /= ""
                  then
                     --  addThrows  (node, "tmap:out", node);      -- tbd: deffered for the moment.
                     replace_All (the_typeMap, "$result", "jresult");
                     print_to (wrapper_Code,  the_typeMap & NL);

                  elsif not is_void_return
                  then
                     log ("unable to use return type " & String'(+swig_Type) & " in function " & String'(+get_Attribute (the_Node, -"name")) & NL);
                  end if;
               end;
            end if;


            print_to (wrapper_Code,  argOut_Code);       -- output argument output code
            print_to (wrapper_Code,  cleanup_Code);      -- output cleanup code


            if exists (get_Attribute (the_Node, -"feature:new"))
            then   -- look to see if there is any newfree cleanup code
               declare
                  the_typeMap : constant unbounded_String :=  +Swig_typemap_lookup (-"newfree", the_Node, -"result", null_Wrapper);
               begin
                  if the_typeMap /= ""
                  then
                     --  addThrows  (node, "tmap:newfree", node);
                     print_to (wrapper_Code,  the_typeMap & NL);
                  end if;
               end;
            end if;


            if not Self.native_function_flag
            then   -- see if there is any return cleanup code
               declare
                  the_typeMap : constant unbounded_String :=  +Swig_typemap_lookup (-"ret", the_Node, -"result", null_Wrapper);
               begin
                  if the_typeMap /= ""
                  then
                     --  replace_All (the_typeMap, "$source", "result");   -- deprecated
                     print_to (wrapper_Code,  the_typeMap & NL);
                  end if;
               end;
            end if;


            --  Finish C function and intermediary class function definitions.
            --
            if num_arguments > 0 then
               append (the_imclass_Code,  ")");
            end if;

            if not is_void_return then
               append (the_imclass_Code,  " return " & im_return_Type);
            end if;


            --  generateThrowsClause (node, the_imclass_Code);        -- tbd: deferred for the moment


            append      (the_imclass_Code,  ";" & NL & NL);
            append      (the_imclass_Code,  "   pragma Import (C, " & overloaded_name & ", ""Ada_");
            replace_All (overloaded_name,   "_SWIG_",  "__SWIG_");
            append      (the_imclass_Code,  overloaded_name & """);" & NL & NL & NL);

            print_to (wrapper_Def,  ")" & NL & "{" & NL);

            if not is_void_return then
               print_to (wrapper_Code,  "    return jresult;" & NL);
            end if;

            print_to    (wrapper_Code,  "}" & NL);
            doh_replace_All (wrapper_Code,  -"$cleanup",               -cleanup_Code);                      -- substitute the cleanup code
            doh_replace_All (wrapper_Code,  -"SWIG_contract_assert(",  -"SWIG_contract_assert($null, ");    -- contract macro modification

            if not is_void_return then
               doh_replace_All (wrapper_Code,  -"$null",  -"0");
            else
               doh_replace_All (wrapper_Code,  -"$null",  -"");
            end if;


            if not Self.native_function_flag then
               Wrapper_print (the_function_Wrapper, Self.f_wrappers);      -- Dump the function out
            end if;

--              log ("HERE !!!!!!!!!!!!!!!!!!!!!!!!!  Self.proxy_flag: " & Boolean'image (Self.proxy_flag));

            if    not (     Self.proxy_flag
                       and  Self.is_wrapping_class /= 0)   -- ignore class member functions
              and not Self.enum_constant_flag
            then
               declare
                  the_new_Function : c_Function.view; -- := Self.new_c_Function (the_Node,
                                                      --                     +sym_Name,
                                                      --                   current_nameSpace);  -- Self.nameSpace_std);
               begin
                  the_new_Function := Self.new_c_Function (the_Node,
                                                           +sym_Name,
                                                           Self.nameSpace_std);

                  Self.current_Module.C.new_c_Functions   .append (the_new_Function);
                  Self.current_Module.C.new_c_Declarations.append (the_new_Function.all'Access);

                  Self.prior_c_Declaration := the_new_Function.all'Access;
               end;
            end if;

            delWrapper (the_function_Wrapper);
         end;
      end;

      unindent_Log;
      return SWIG_OK;
   end functionWrapper;



   overriding
   function globalvariableHandler_is_overridden (Self : in Item) return Boolean is begin   return True;   end globalvariableHandler_is_overridden;

   overriding
   function globalvariableHandler
     (Self : access Item;
      n    : in doh_Node'Class) return Integer
   is
      the_Node           :          doh_Node'Class   renames n;

      the_Name           :          unbounded_String      := +get_Attribute     (the_Node,  -"sym:name");
      the_swig_Type      :          doh_swigType'Class    := doh_Copy           (get_Attribute (the_Node,  -"type"));
      is_Pointer         : constant Boolean               := SwigType_ispointer (the_swig_Type) /= 0;

   begin
      indent_Log;
      log ("");
      log ("'globalvariableHandler'");

      Self.current_c_Node := doh_Node (the_Node);
--        Self.current_Node   := doh_Node (the_Node);

      freshen_current_module_Package (Self, the_Node);


      strip_Namespaces       (the_Name);
--        strip_const_Qualifiers (the_swig_type_Name);
      strip_all_qualifiers   (the_swig_Type);

      declare
         use c_Variable, c_Variable.array_Bounds_Vectors;

         new_Variable       : constant c_Variable.view  := new_c_Variable (name    => the_Name,
                                                                           of_type => null);   -- Self.demand_Type (the_swig_Type));
      begin
         new_Variable.is_Static        := True;
         new_Variable.is_class_Pointer := is_Pointer;                                         -- tbd: simplify these 'is_pointer' variables
         new_Variable.is_Pointer       := SwigType_isreference (the_swig_type) /= 0;

         if swigtype_isArray (the_swig_type) /= 0 then
--              log ("array member detected");

            Self.add_array_Bounds_to (new_Variable, the_swig_Type);

            --              if Element (new_Variable.array_Bounds,  Integer (Length (new_Variable.array_Bounds))) = -1 then  -- handle unconstrained arrays.
            --                 --new_Variable.my_Type := new_Variable.my_Type.element_Type.my_view_Type;
            --                 declare
            --                    --new_swig_Type  : doh_swigType'Class := doh_Copy (the_swig_Type);
            --                    the_Array      : doh_SwigType'Class := SwigType_pop_arrays (the_swig_Type);  -- strip the array part from 'the_swig_Type'.
            --                 begin
            --                    the_swig_Type        := swigType_add_pointer (the_swig_Type);
            --                    --new_Variable.my_Type := Self.demand_Type (the_swig_Type);
            --                    clear (new_Variable.array_Bounds);
            --                 end;
            --              end if;

         end if;

         declare
            Pad                : constant doh_swigType'Class := doh_Copy (the_Swig_type);
            the_swig_type_Name : constant unbounded_String   := strip_array_Bounds (Pad);
         begin
--              log ("the_swig_type: '" & String'(+the_swig_type) & "'   type name: '" & to_String (the_swig_type_Name) & "'");
            new_Variable.my_Type := Self.swig_type_Map_of_c_type.Element (the_swig_type_Name);
         end;

--           log ("the_swig_type: '" & String'(+the_swig_type) & "'");

--           Self.binding_Package.add (new_Variable.all'access);
--           Self.current_c_namespace.add (new_Variable);
         Self.Module_top.C.new_c_Variables.append (new_Variable);

         --  tbd: Self.prior_c_Declaration := new_Variable.all'access;

         unindent_Log;
         return SWIG_OK;
      end;
   end globalvariableHandler;



   overriding
   function enumDeclaration_is_overridden (Self : in Item) return Boolean is begin   return True;   end enumDeclaration_is_overridden;

   overriding
   function enumDeclaration
     (Self : access Item;
      n    : in     doh_Node'Class) return Integer
   is
      use dispatcher.AccessMode;

      the_Node        : doh_Node    'Class   renames  n;
      doh_swig_Type   : doh_swigType'Class        :=  get_Attribute (the_Node,  -"enumtype");
      unnamed_Synonym : constant unbounded_String := +get_Attribute (the_Node,  -"unnamed");

      --  new ...
      --
      new_c_Enum : c_Type.view;

   begin
      indent_Log;
      log ("");
      log ("enumDeclaration - '" & String'(+doh_swig_Type) & "'");

      if    exists (Self.getCurrentClass)
        and Self.get_cplus_mode /= accessMode.PUBLIC
      then
         return SWIG_NOWRAP;
      end if;

      Self.current_c_Node := doh_Node (the_Node);

      declare
         the_Name          : unbounded_String := +get_Attribute (the_Node,  -"sym:name");   -- nb: will be null string for an anonymous enum
         the_doh_swig_Type : doh_swigType     :=  doh_swigType (doh_Copy (doh_swig_Type));
      begin
--           log ("the_Name: '" & the_Name & "'");

         if the_Name = "" then
            Self.anonymous_c_enum_Count := Self.anonymous_c_enum_Count + 1;
            the_Name          := "anonymous_enum_" & (+Image (Self.anonymous_c_enum_Count));
            the_doh_swig_Type := to_Doh (to_String (the_Name));
         end if;

--           log ("the_Name: '" & the_Name & "'");
--           log ("the current_c_Namespace: '" & Self.current_c_Namespace.Name & "'");

         new_c_Enum := c_type.new_Enum (namespace => Self.current_c_Namespace,
                                        name      => the_Name);
         Self.register (new_c_Enum,
                        the_doh_swig_Type);

         Self.current_c_Enum        := new_c_Enum;
         Self.last_c_enum_rep_value := -1;
      end;


      --  old ...
      --

--        Self.current_Node             := doh_Node (the_Node);
      Self.enum_rep_clause_required := False;
--        Self.last_enum_rep_value      := -1;

      freshen_current_module_Package (Self, the_Node);


      if String'(+doh_swig_Type) = "enum "
      then   -- handle anonymous enums
         Self.is_anonymous_Enum    := True;
         Self.anonymous_enum_Count := Self.anonymous_enum_Count + 1;

         declare
            new_enum_Name : constant String := "anonymous_enum_" & Image (Self.anonymous_enum_Count);
         begin
            set_Attribute (the_Node,  -"type",      -("enum " & new_enum_Name));
            set_Attribute (the_Node,  -"sym:name",  -new_enum_Name);
            set_Attribute (the_Node,  -"name",      -new_enum_Name);
            set_Attribute (the_Node,  -"enumtype",  -new_enum_Name);

            doh_swig_Type := get_Attribute (the_Node,  -"enumtype");

            --              unnamed_Synonym := +get_Attribute (the_Node,  -"unnamed");
         end;

      else
         Self.is_anonymous_Enum := False;

         declare
            sym_Name                : constant unbounded_String := trim_Namespace (+get_Attribute (the_Node,  -"sym:name"));
            the_Name                : unbounded_String;
--              the_declaration_Package : gnat_Package.view;
         begin

            if Self.proxy_flag  and  Self.is_wrapping_class /= 0 then
               the_Name                := sym_Name;
--                 the_declaration_Package := Self.current_Package;
            else
               the_Name                := sym_Name;  -- to_unbounded_String ("Item");
               --                 the_declaration_Package := Self.demand_Package (swig_Type => -(Self.current_module_Package.qualified_Name & "::" & String'(+doh_swig_Type)));
               --
               --                 the_declaration_Package.Name_is (to_String (sym_Name));

               --  the_declaration_Package := Self.namespace_Package;   -- Self.types_Package;
--                 the_declaration_Package := Self.current_Module_Package (for_node => Self.current_Node);   -- Self.types_Package;
            end if;


--              Self.current_Enum := Self.all_Types_Container.fetch_Type (doh_swig_Type);   -- see if the enum has been forward declared (probably due to an uninstantiated template usage).
--
--              if Self.current_Enum = null then   -- the enum has been not been forward declared
--                 Self.current_Enum := new_Enum (declaration_Package => the_declaration_Package,
--                                                Name                => the_Name);
--
--                 Self.all_Types_Container.add (doh_swig_Type,  Self.current_Enum);            -- add the new type to all_Types.
--
--              else     -- has been forward declared, so replace the Unknown gnat_Type with an Enum gnat_Type.
--
--                 pragma Assert (Self.current_Enum.c_type_Kind = Unknown);
--
--                 Self.current_Enum.all := Enum_construct (declaration_Package => the_declaration_Package,
--                                                          Name                => the_Name,
--                                                          my_view_Type        => Self.current_Enum.my_view_Type,
--                                                          my_array_Type       => Self.current_Enum.my_array_Type);
--
--                 update_Name_for_any_associated_Types_of (Self.current_Enum);
--
--
--                 declare
--                    the_view_Type : constant gnat_Type.view := Self.all_Types_Container.fetch_Type (SwigType_add_pointer (doh_Copy (doh_swig_Type)));
--                 begin
--                    the_view_Type.declaration_Package_is (the_declaration_Package);             -- handle associated View (pointer/reference) type
--
--                    if Self.current_Enum.Name = "Item" then
--                       the_view_Type.Name_is (to_unbounded_String ("View"));
--                    else
--                       the_view_Type.Name_is (Self.current_Enum.Name & "_view");
--                    end if;
--                 end;
--
--              end if;


--              if String'(+get_Attribute (the_Node, -"allows_typedef")) = "1" then
--                 declare
--                    tdName : constant doh_String'Class := get_Attribute (the_Node,  -"tdname");
--                 begin
--                    if String'(+doh_swig_Type) /= String'(+tdName) then                                           -- tbd: add design note
--                       Self.all_types_Container.add_Synonym (swig_type => get_Attribute (the_Node,  -"tdname"),
--                                                             ada_type  => Self.current_Enum);
--                    end if;
--                 end;
--              end if;


--              if unnamed_Synonym /= "" then
--                 Self.all_types_Container.add_Synonym (swig_type => -("enum " & unnamed_Synonym),   -- tbd: 'enum ' part is probly obsolete
--                                                       ada_type  => Self.current_Enum);
--              end if;
--
--
--              set_Kind_for (the_declaration_Package, from_node => the_Node);
         end;

      end if;


      do_base_enumDeclaration (Self.all, the_Node);            -- process each enum element (ie the enum literals)


      --  new ...
      --
      Self.current_c_Enum := null;
      Self.prior_c_Declaration := new_c_Enum.all'Access;

      unindent_Log;
      return SWIG_OK;
   end enumDeclaration;



   overriding
   function enumvalueDeclaration_is_overridden (Self : in Item) return Boolean is begin   return True;   end enumvalueDeclaration_is_overridden;

   overriding
   function enumvalueDeclaration
     (Self : access Item;
      n    : in doh_Node'Class) return Integer
   is
      use dispatcher.AccessMode;

      the_Node      :          doh_Node'Class      renames n;
      symname       : constant unbounded_String := +get_Attribute (the_Node,  -"sym:name");

      --  old ...
      --
      full_symname  : constant unbounded_String := +get_Attribute (the_Node,  -"value");                            -- the full symname is in the 'value' attribute ?!
      value_Text    : aliased  unbounded_String := +get_Attribute (the_Node,  -"feature:ada:constvalue");   -- check for the %adaconstvalue feature

   begin
      indent_Log;
      log ("enumvalueDeclaration - '" & String'(+get_Attribute (the_Node, -"name")) & "'");


      --  new ...
      --
      declare
         enum_value_Text : constant unbounded_String := +get_Attribute (the_Node,  -"enumvalue");
      begin
         if enum_value_Text = "" then
            Self.last_c_enum_rep_value := Self.last_c_enum_rep_value + 1;
         else
--              log ("value_Text: '" & to_String (enum_value_Text) & "'");

            Self.last_c_enum_rep_value      := Value (resolved_c_integer_Expression (Self,  enum_value_Text, Self.symbol_value_Map, Self.current_class_namespace_Prefix));
            --              Self.enum_rep_clause_required := True;
         end if;

         --           log ("inserting '" & full_symname & "' to the symbol_value_Map ... Value: " & long_long_Integer'Image (Self.last_c_enum_rep_value));
--           insert (Self.symbol_value_Map,  full_symname,  to_Integer (Self.last_c_enum_rep_value));
         insert (Self.symbol_value_Map,  symName,  to_Integer (Self.last_c_enum_rep_value));


         Self.current_c_Enum.add_Literal (name  => symName,
                                          value => to_Integer (Self.last_c_enum_rep_value));
      end;


      --  old ...
      --
      if    exists (Self.getCurrentClass)
        and Self.get_cplus_mode /= accessMode.PUBLIC
      then
         return SWIG_NOWRAP;
      end if;  -- tbd: redundant (ie check is done in parent node) ?


      if value_Text = "" then
         value_Text := +get_Attribute (the_Node,  -"enumvalue");
      end if;


      if Self.is_anonymous_Enum
      then
         null;
--           if value_Text = ""
--           then
--              Self.last_enum_rep_Value := Self.last_enum_rep_Value + 1;
--           else
--  --              log ("value_Text: '" & to_String (value_Text) & "'");
--              --  Self.last_enum_rep_Value := long_long_Integer (to_huge_Natural (Self.resolved_c_integer_Expression (value_Text, Self.symbol_value_Map, Self.current_class_namespace_Prefix)));
--              Self.last_enum_rep_Value := Value (resolved_c_integer_Expression (Self,
--                                                                                value_Text,
--                                                                                Self.symbol_value_Map,
--                                                                                Self.current_class_namespace_Prefix));
--              --  Self.last_enum_rep_Value      := Self.to_enum_rep_Value (value_Text);
--           end if;


--           log ("inserting '" & full_symname & "' to the symbol_value_Map ... Value: " & long_long_Integer'Image (Self.last_enum_rep_Value));
--           insert (Self.symbol_value_Map,  full_symname,  to_Integer (Self.last_enum_rep_Value));

--           declare
--              new_Variable : constant gnat_Variable.view := new_gnat_Variable (the_name => symname,
--                                                                               the_type => Self.demand_Type (the_Node, -"int"));
--           begin
--              new_variable.is_Constant := True;
--              new_variable.Value       := +Long_Long_Integer'Image (Self.last_enum_rep_Value);
--
--              if Self.current_Package = null then
--                 Self.binding_Package.add (new_Variable);
--              else
--                 Self.current_Package.add (new_Variable);
--              end if;
--           end;

      else
         null;
--           declare
--              Literal_is_transformed : Boolean := False;
--           begin
--              if value_Text = ""
--              then
--                 Self.last_enum_rep_Value := Self.last_enum_rep_Value + 1;
--
--              elsif     Self.current_Enum.contains_Literal             (named => to_String (value_Text))    -- we have a duplicate valued Literal,
--                or else Self.current_Enum.contains_transformed_Literal (named => value_Text)    -- so we transform the Literal to a constant variable
--              then
--                 Literal_is_transformed := True;
--
--                 declare
--                    new_Variable : constant gnat_Variable.view := new_gnat_Variable (the_name => symname,
--                                                                                     the_type => Self.current_Enum.all'Access);
--                 begin
--                    new_variable.is_Constant := True;
--                    new_variable.Value       := value_Text;
--
--                    Self.current_Enum.declaration_Package.add (new_Variable);
--                    Self.current_Enum.add_transformed_Literal (literal_name => symname);     -- let the enum type know about the transformation
--                 end;
--
--              else
--  --                 log ("value_Text: '" & to_String (value_Text) & "'");
--                 --  log (Self.symbol_value_Map);
--
--                 Self.last_enum_rep_Value      := Value (resolved_c_integer_Expression (Self,  value_Text, Self.symbol_value_Map, Self.current_class_namespace_Prefix));
--                 --               Self.last_enum_rep_Value      := Self.to_enum_rep_Value (value_Text);
--                 Self.enum_rep_clause_required := True;
--              end if;
--
--              --              insert (Self.symbol_value_Map,  full_symname,  to_Integer (Self.last_enum_rep_Value));
--
--  --              log ("inserting '" & full_symname & "' to the symbol_value_Map ... Value: " & Long_Long_Integer'Image (Self.last_enum_rep_Value));
--
--              if not Literal_is_transformed then
--                 Self.current_Enum.add_Literal (name  => symName,
--                                                value => to_Integer (Self.last_enum_rep_Value));
--              end if;
--           end;
      end if;


      if not exists (get_Attribute (parent_Node (the_Node),  -"enumvalues")) then
         set_Attribute (parent_Node (the_Node),  -"enumvalues",  -symname);
      end if;

      --      Swig_restore (the_Node);


      --  new ...
      --
      --  tbd: Self.prior_c_Declaration := new_enum_Value.all'access;

--        log ("end 'enumvalueDeclaration';'");
      unindent_Log;
      return SWIG_OK;
   end enumvalueDeclaration;



   overriding
   function constantWrapper_is_overridden (Self : in Item) return Boolean is begin   return True;   end constantWrapper_is_overridden;

   overriding
   function constantWrapper (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node     : doh_Node'Class         renames n;
      the_Name     : constant unbounded_String      := +get_Attribute (the_Node,  -"sym:name");

      the_swigType : constant doh_swigType'Class := get_Attribute                   (the_Node,     -"type");
      the_Type     : c_Type.view; --        := Self.name_Map_of_c_type.Element (+the_swigType);

      new_c_Constant : c_Variable.view; -- := c_variable.new_c_Variable (--namespace => Self.current_c_Namespace,
      --                           name    => the_Name,
      --                         of_type => the_Type            );

   begin
      indent_Log;
      log ("");
      log ("'constantWrapper' -   Name: '" & the_Name & "'    swigType: '" & String'(+the_swigType) & "'");

      Self.current_c_Node := doh_Node (the_Node);

      the_Type       := Self.swig_type_Map_of_c_type.Element (+the_swigType);

      new_c_Constant := c_variable.new_c_Variable ( -- namespace => Self.current_c_Namespace,
                                                   name    => the_Name,
                                                   of_type => the_Type);

      declare
         value_Text : unbounded_String := +get_Attribute (the_Node,  -"value");
      begin
         if not (new_c_Constant.my_Type.qualified_Name = "Character"
                 or else new_c_Constant.my_Type.qualified_Name = "interfaces.c.strings.chars_ptr")
         then   -- is numeric
            declare
               the_Value : gmp.discrete.Integer;
            begin
               the_Value := resolved_c_integer_Expression (Self,
                                                           Value_Text,
                                                           Self.symbol_value_Map,
                                                           Self.current_class_namespace_Prefix);
               if    Slice (value_Text, 1, 2) = "0x" then
                  value_Text := +hex_Image (the_Value);

               elsif Slice (value_Text, 1, 1) = "0" then
                  value_Text := +oct_Image (the_Value);
               else
                  value_Text := +Image (the_Value);
               end if;

               --  new_Constant.Value := +Integer'Image (Self.to_enum_rep_Value (the_Value));

--                 log ("inserting '" & the_Name & "' into the symbol_value_Map ... value: " & String'(Image (the_Value)));
               insert (Self.symbol_value_Map,  the_Name,  the_Value);

            exception
               when others =>    -- constraint_Error =>
                  strip_c_integer_literal_qualifiers_in (value_Text);

                  if        the_Type.Name = "float"
                    or else the_Type.Name = "double"
                  then
                     replace_integer_with_float (value_Text);
                  end if;

                  new_c_Constant.Value := value_Text;
            end;
         end if;


         declare
            --           the_base_Type : c_Type.view := Self.name_Map_of_c_type.Element (the_swig_Type);
         begin
            new_c_Constant.Value := value_Text;
            --           Self.name_Map_of_c_type.insert (the_type_Name, new_c_typeDef);
            Self.current_Module.C.new_c_Variables   .append (new_c_Constant);
            Self.current_Module.C.new_c_Declarations.append (new_c_Constant.all'Access);

            --  return SWIG_OK;
         end;
      end;


      --  old ...
      --
--        Self.current_Node := doh_Node (the_Node);

      freshen_current_module_Package (Self, the_Node);

      if Self.addSymbol (-the_Name, the_Node) = 0 then   return SWIG_ERROR;   end if;

      declare
         the_swigType : doh_swigType'Class := get_Attribute (the_Node,  -"type");
         is_enum_item : constant Boolean            := (String'(+node_Type (the_Node)) = "enumitem");
      begin

         if is_enum_item then                                                             --      adjust the enum type for the Swig_typemap_lookup.
            the_swigType := get_Attribute (parent_Node (the_Node),  -"enumtype");         --      we want the same adatype typemap for all the enum items so we use the enum type (parent node).
            set_Attribute (the_Node,  -"type", the_swigType);
         end if;


--           declare
--              new_Constant : constant gnat_Variable.view := new_gnat_Variable (the_Name,
--                                                                      Self.demand_Type (the_Node, the_swigType));
--              value_Text   : unbounded_String   :=  +get_Attribute   (the_Node,  -"value");
--           begin
--              new_Constant.is_Static   := True;
--              new_Constant.is_Constant := True;
--
--              if        new_Constant.my_Type.qualified_Name = "Character"
--                or else new_Constant.my_Type.qualified_Name = "interfaces.c.strings.chars_ptr"
--              then
--                 new_Constant.Value := Value_Text;
--              else
--
--                 declare
--                    the_Value : discrete.Integer;
--                 begin
--                    the_Value          := resolved_c_integer_Expression (Self,  Value_Text,  Self.symbol_value_Map, Self.current_class_namespace_Prefix);
--                    new_Constant.Value := +Image (the_Value);
--                    --  new_Constant.Value := +Integer'Image (Self.to_enum_rep_Value (the_Value));
--
--  --                    log ("inserting '" & the_Name & "' into the symbol_value_Map ... value: " & String'(Image (the_Value)));
--                    insert (Self.symbol_value_Map,  the_Name,  the_Value);
--
--                 exception
--                    when others =>    -- constraint_Error =>
--                       strip_c_integer_literal_qualifiers_in (value_Text);
--                       new_Constant.Value := value_Text;
--                 end;
--
--              end if;
--
--
--              if Self.proxy_flag  and  Self.is_wrapping_class /= 0 then
--                 Self.current_Package.add (new_Constant.all'Access);
--              else
--                 Self.binding_Package.add  (new_Constant.all'Access);
--              end if;
--           end;

      end;

      --  new ...
      --
      Self.prior_c_Declaration := new_c_Constant.all'Access;

      unindent_Log;
      return SWIG_OK;
   end constantWrapper;



   overriding
   function classHandler_is_overridden (Self : in Item) return Boolean is begin   return True;   end classHandler_is_overridden;

   overriding
   function classHandler
     (Self : access Item;
      n    : in     doh_Node'Class) return Integer
   is
      the_Node   :          doh_Node'Class renames  n;
      node_Type  : constant doh_swigType'Class  :=  get_Attribute (the_Node, -"name");   -- use sym:name ???
      --        class_Name : String              := +node_Type;    -- get_Attribute (the_Node, -"sym:name");
      class_Name : constant String              := +get_Attribute (the_Node, -"sym:name");
      new_c_Class :         c_Type.view;

   begin
      indent_Log;
      log ("");
      log ("classHandler - '" & class_Name & "'");

      Self.current_c_Node := doh_Node (the_Node);

      if Self.swig_type_Map_of_c_type.contains (+node_Type)
      then   -- the class has been 'forward' declared
         new_c_Class     := Self.swig_type_Map_of_c_type.Element (+node_Type);                    -- get the 'unknown' c type
         new_c_Class.all := c_Type.c_Class_construct (namespace => Self.current_c_Namespace,      -- morph it to a c class
                                                      name      => new_c_Class.Name); --+class_Name);
      else
         new_c_Class := c_Type.new_c_Class (namespace => Self.current_c_Namespace,
                                            name      => +class_Name);
         Self.register (new_c_Class, node_Type);
      end if;

      if String'(+get_Attribute (the_Node, -"kind")) = "union" then
         new_c_Class.is_Union;
      end if;

--        Self.current_c_Class := new_c_Class;
      Self.c_class_Stack    .append (new_C_Class);
      Self.c_namespace_Stack.append (new_C_Class.nameSpace.all'Access);

      new_c_Class.nameSpace.models_cpp_class_Type (new_c_Class);


      --  old ...
      --

--        Self.current_Node := doh_Node (the_Node);

      freshen_current_module_Package (Self, the_Node);

      --        Self.current_class_swig_Type := Self.current_module_Package (the_Node).qualified_Name & "::" & String'(+node_Type);
--        Self.current_class_swig_Type := +node_Type;


--        Self.current_class_swig_classType := +get_Attribute (the_Node, -"classtype");      -- store these for use by child nodes
      --        Self.current_class_swig_Type      := +get_Attribute (the_Node, -"name");           -- (tbd: obsolete ?!)

      --        Self.current_Package      := Self.demand_Package                 (-(Self.current_module_Package.qualified_Name & "::" & String'(+node_Type)));
--        Self.current_class_Record := Self.all_types_Container.fetch_Type (node_Type); -- see if the class already exists (via a 'forward declaration').


--        if Self.current_class_Record = null then   -- the class does not exist as yet, so build it
--
--           Self.current_Package      := Self.demand_Package (-Self.current_class_swig_Type);
--           Self.current_class_Record := gnat_type.new_c_Class (declaration_Package => Self.current_Package,
--                                                               Name                => to_unbounded_String ("Item"));
--
--           Self.all_Types_Container.add (node_Type,  Self.current_class_Record);
--  --           log ("inserted new class type -   classname: '" & class_Name & "'    node_Type: '" & String'(+node_Type) & "'");
--
--
--        elsif Self.current_class_Record.c_type_Kind = Unknown then   -- must be 'forward referred', so do completions
--
--           --           Self.namespace_Package.rid (Self.current_class_Record);
--           --           Self.namespace_Package.rid (Self.current_class_Record.my_view_Type);
--           --           Self.namespace_Package.rid (Self.current_class_Record.my_array_Type);
--
--           --  Self.all_Packages.delete   (the_swig_Type);
--           Self.current_Package := Self.demand_Package (-Self.current_class_swig_Type);
--
--           Self.current_class_Record.all := c_Class_construct (declaration_Package => Self.current_Package,
--                                                               Name                => to_unbounded_String ("Item"),
--                                                               my_view_Type        => Self.current_class_Record.my_view_Type,
--                                                               my_array_Type       => Self.current_class_Record.my_array_Type);
--
--           update_Name_for_any_associated_Types_of (Self.current_class_Record);
--
--           Self.current_Package.add (Self.current_class_Record);
--           Self.current_Package.add (Self.current_class_Record.my_view_Type);
--           Self.current_Package.add (Self.current_class_Record.my_array_Type);
--
--           --           declare
--           --              the_view_Type : gnat_Type.view := Self.all_Types_Container.fetch_Type (SwigType_add_pointer (doh_Copy (node_Type)));
--           --           begin
--           --              the_view_Type.declaration_Package_is (Self.current_Package);        -- handle the associated View type (c pointer/reference)
--           --              Self.current_Package.add             (the_view_Type);               --
--           --           end;
--           --
--           --           declare
--           --              the_array_Type : gnat_Type.view := Self.all_Types_Container.fetch_Type (-("a." & unbounded_String'(+node_Type)));
--           --           begin
--           --              the_array_Type.declaration_Package_is (Self.current_Package);        -- handle the associated 'Items' type (c array)
--           --              Self.current_Package.add              (the_array_Type);               --
--           --           end;
--
--
--        elsif Self.current_class_Record.c_type_Kind = opaque_Struct         -- a forward declared struct or class
--          or  Self.current_class_Record.c_type_Kind = incomplete_Class      --
--        then
--           --           Self.namespace_Package.rid (Self.current_class_Record);
--           --           Self.namespace_Package.rid (Self.current_class_Record.my_view_Type);
--           --           Self.namespace_Package.rid (Self.current_class_Record.my_array_Type);
--
--           begin
--  --              log ("Self.current_class_swig_Type: '" & to_String (Self.current_class_swig_Type) & "'");
--              Self.all_Packages.delete   (Self.current_class_swig_Type);
--              --           exception
--              --              when constraint_Error =>
--              --                 null; --- tbd: investigate;
--           end;
--
--           Self.current_Package := Self.demand_Package (-Self.current_class_swig_Type);
--
--           Self.current_class_Record.all := c_Class_construct (declaration_Package => Self.current_Package,
--                                                               Name                => to_unbounded_String ("Item"),
--                                                               my_view_Type        => Self.current_class_Record.my_view_Type,
--                                                               my_array_Type       => Self.current_class_Record.my_array_Type);
--
--
--
--           update_Name_for_any_associated_Types_of (Self.current_class_Record);
--
--           Self.current_Package.add (Self.current_class_Record);
--           Self.current_Package.add (Self.current_class_Record.my_view_Type);
--           Self.current_Package.add (Self.current_class_Record.my_array_Type);
--        else
--           raise Program_Error;    -- this should not occur !
--        end if;

      --        Self.current_Package.add (Self.current_class_Record);
      --        Self.current_Package.add (Self.current_class_Record.my_view_Type);
      --        Self.current_Package.add (Self.current_class_Record.my_array_Type);

--        Self.current_Package.models_cpp_class_Type (Self.current_class_Record);


      if Self.proxy_Flag then
         --         Self.current_Package.Name_is (class_Name); -- tbd: redundant ?!

         if Self.addSymbol (-class_Name, the_Node) = 0 then   return SWIG_ERROR;   end if;

--           if class_Name = Self.binding_Package.Name then
--              log ("Class name cannot be equal to the 'Binding' package: " & class_name);
--              exit_with_Fail;
--           end if;

         --           if class_Name = Self.types_Package.Name then
         --              log ("Class name cannot be equal to the 'Types' package: " & class_name);
         --              exit_with_Fail;
         --           end if;

         Self.have_default_constructor_flag := False;
      end if;


--        set_Kind_for (Self.current_Package, from_node => the_Node);


--        if String'(+get_Attribute (the_Node, -"kind")) = "union" then
--           Self.current_class_Record.is_Union;
--        end if;


      do_base_classHandler (Self.all, the_node);           -- process all class elements


      if Self.proxy_Flag then    -- handle base classes
         declare
            base_List     : constant doh_List'Class     := get_Attribute (the_Node, -"allbases"); -- -"bases");
            the_Iterator  : doh_Iterator'Class := doh_First (base_List);
         begin
--              log ("!!! ***** base_class_package: ");

            while exists (get_Item (the_Iterator)) loop
               declare
                  base_Name          : constant String            := +get_Attribute      (get_Item (the_Iterator), -"sym:name");  -- formerly ... getProxyName (c_baseclassname));
--                    base_class_Package : constant gnat_Package.view := Self.old_demand_Package (to_String (Self.current_module_Package (the_Node).qualified_Name & "." & base_Name));
               begin
--                    log ("!!! ***** base_class_package: '" & to_String (Self.current_module_Package (the_Node).qualified_Name & "." & base_Name));

--                    Self.current_class_Record.add_Base (base_class_Package.cpp_class_Type);   -- old

                  Self.current_c_Class.add_Base (Self.name_Map_of_c_type.Element (+base_Name));

                  the_Iterator := doh_Next (the_Iterator);
               end;
            end loop;

         end;
      end if;


--        Self.current_Package      := null;  -- Self.binding_Package;
--        Self.current_class_Record := null;

--        Self.current_class_swig_classType := null_unbounded_String;
--        Self.current_class_swig_Type      := null_unbounded_String;


      --  new ...
      --
--        Self.current_c_Class     := null;         -- tbd: use a stack, instead of a single pointer to handle nested classes.
      Self.c_class_Stack    .delete_Last;
      Self.c_namespace_Stack.delete_Last;

      Self.prior_c_Declaration := new_c_Class.all'Access;

      unindent_Log;
      return SWIG_OK;
   end classHandler;



   overriding
   function memberfunctionHandler_is_overridden (Self : in Item) return Boolean is begin   return True;   end memberfunctionHandler_is_overridden;

   overriding
   function memberfunctionHandler
     (Self : access Item;
      n    : in     doh_Node'Class) return Integer
   is
      the_Node : doh_Node'Class renames n;
   begin
      indent_Log;
      log ("");
      log ("memberfunctionHandler");

      Self.current_c_Node := doh_Node (the_Node);
      do_base_memberfunctionHandler (Self.all, the_Node);
--        Self.current_Node   := doh_Node (the_Node);

      if Self.proxy_Flag
      then
         declare
--              overloaded_name            : String               := Self.get_overloaded_Name (the_Node);
--              the_new_Function           : gnat_Subprogram.view := Self.new_Function (the_Node       => the_Node,
--                                                                                      function_Name  => +get_Attribute (the_Node,  -"sym:name"), --Self.get_overloaded_Name (the_Node),
--                                                                                      parent_Package => Self.current_c_Class.);
         begin
            null;   -- work done in new_Function
         end;

         declare
--              overloaded_name  : String               := Self.get_overloaded_Name (the_Node);
            the_new_Function : c_Function.view; -- := Self.new_c_Function (the_Node,
            --                     +sym_Name,
            --                   current_nameSpace);  -- Self.nameSpace_std);
         begin
--              log ("Self.current_c_Class.nameSpace.Name: " & Self.current_c_Class.nameSpace.Name);

            the_new_Function := Self.new_c_Function (the_Node,
                                                     +get_Attribute (the_Node,  -"sym:name"),
                                                     Self.current_c_Class.nameSpace.all'Access);

            Self.prior_c_Declaration := the_new_Function.all'Access;
         end;
      end if;


      --  new ...
      --
      --  tbd: Self.prior_c_Declaration := new_Constant.all'access;

      unindent_Log;
      return SWIG_OK;
   end memberfunctionHandler;



   overriding
   function staticmemberfunctionHandler_is_overridden (Self : in Item) return Boolean is begin   return True;   end staticmemberfunctionHandler_is_overridden;

   overriding
   function staticmemberfunctionHandler
     (Self : access Item;
      n    : in     doh_Node'Class) return Integer
   is
      the_Node   : doh_Node'Class      renames n;
   begin
      indent_Log;
      log ("");
      log ("'staticmemberfunctionHandler'");

      Self.current_c_Node := doh_Node (the_Node);
      Self.static_Flag    := True;
      do_base_staticmemberfunctionHandler (Self.all, the_Node);
--        Self.current_Node   := doh_Node (the_Node);

--        if Self.proxy_flag
--        then
--           declare
--              --              intermediary_function_name : String                     := +Swig_name_member (classname => -Self.current_package.Name,
--              --                                                                                            mname     => -Self.get_overloaded_Name (the_Node));
--              the_new_Function           : gnat_Subprogram.view := Self.new_Function (the_Node       => the_Node,
--                                                                                      function_Name  => +get_Attribute (the_Node,  -"sym:name"),
--                                                                                      parent_Package => Self.current_Package);
--           begin
--              null; -- work done in new_Function
--           end;
--        end if;

      Self.static_flag := False;


      --  new ...
      --
      --  tbd: Self.prior_c_Declaration := new_Constant.all'access;

      unindent_Log;
      return SWIG_OK;
   end staticmemberfunctionHandler;



   overriding
   function constructorHandler_is_overridden (Self : in Item) return Boolean is begin   return True;   end constructorHandler_is_overridden;

   overriding
   function constructorHandler
     (Self : access Item;
      n    : in     doh_Node'Class) return Integer
   is
      the_Node : doh_Node'Class renames n;
   begin
      indent_Log;
      log ("constructorHandler");

      if not Self.in_cpp_Mode then
         unindent_Log;
         return SWIG_OK;
      end if;

      if check_Attribute (the_Node,  -"access",  -"private") then
         unindent_Log;
         return SWIG_OK;
      end if;

      Self.current_c_Node := doh_Node (the_Node);
--        Self.current_Node := doh_Node (the_Node);

      if not (   check_Attribute (the_node,  -"access",  -"protected")
              or check_Attribute (the_Node,  -"access",  -"private"))
      then
         do_base_constructorHandler (Self.all, the_Node);
      end if;

      if exists (get_Attribute (the_Node,  -"overload:ignore")) then     -- wrappers not wanted for some methods where the parameters cannot be overloaded in Ada
         unindent_Log;
         return SWIG_OK;
      end if;

      if Self.proxy_Flag
      then
         declare
            overloaded_name     : constant String             := Self.get_overloaded_Name (the_Node);

            constructor_Symbol  : unbounded_String;    -- we need to build our own 'c' construction call   (tbd: move all this to functionWrapper)
            construct_Call      : unbounded_String;    -- since the default swig constructor returns a pointer to class
            construct_call_Args : unbounded_String;    -- instead of an actual solid class object.

            parameter_List      : constant doh_parmList'Class := get_Attribute (the_Node, -"parms");
            the_Parameter       : doh_Parm'Class     := parameter_list;
            Index               : Natural            := 0;
            gencomma            : Boolean            := False;

         begin
            append (constructor_Symbol,  String'("gnat_" & (+Swig_name_construct (-overloaded_name))));
            append (construct_Call,      "extern "  & Self.current_lStr & "    " & constructor_Symbol & "(");

            Swig_typemap_attach_parms (-"ctype",   parameter_List, null_Wrapper);    -- attach the non-standard typemaps to the parameter list
            Swig_typemap_attach_parms (-"in",      parameter_List, null_Wrapper);    --

            emit_mark_varargs (parameter_List);

            while exists (the_Parameter)
            loop
               --  log ("the_Parameter: '" & (+the_Parameter) & "'");

               if check_Attribute (the_Parameter,  -"varargs:ignore",  -"1") then         -- ignored varargs
                  the_Parameter := next_Sibling (the_Parameter);

               elsif check_Attribute (the_Parameter,  -"tmap:in:numinputs",  -"0") then   -- ignored parameters
                  the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");

               else
                  declare
                     pt         : constant doh_swigType'Class := get_Attribute     (the_Parameter, -"type");   -- tbd: rename
                     the_c_Type : unbounded_String   := +get_Attribute     (the_Parameter, -"tmap:ctype");
                     arg        : constant String             := Self.makeParameterName (the_Node, the_Parameter, Index);
                  begin
                     --  log ("pt: '" & (+pt));

                     if gencomma then
                        append (construct_Call,        ",   ");
                        append (construct_call_Args,   ",   ");
                     end if;

                     if the_c_Type /= "" then
                        replace_All (the_c_Type,  "$c_classname",  +pt);

                        append (construct_Call,       String'(+SwigType_lstr (pt, null_DOH)  &   "   "  &  arg));
                        append (construct_call_Args,  String'(+SwigType_rcaststr (pt, -arg)));
                     else
                        log ("no ctype typemap defined for "  &  String'(+pt));
                     end if;

                     gencomma      := True;
                     the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");
                     Index         := Index + 1;
                  end;
               end if;
            end loop;

            append (construct_Call,  ")" & NL & "{");

--              if Self.in_cpp_Mode then
            append (construct_Call,  NL  &  "  return "  &  Self.current_lStr  &  "("  &  construct_call_Args  &  ");"  & NL);
--              else
--                 append (construct_Call,   NL  &  "  "  &  Self.current_lStr  & "        a_"  &  Self.current_lStr  &  ";"
--                         & NL  &  "  return a_"  &  Self.current_lStr  &  ";" & NL);
--              end if;

            append (construct_Call,  "}" & NL);


            if not gencomma then
               Self.have_default_constructor_flag := True;
            end if;

--              set_Attribute (the_Node,  -"type",  -Self.current_Package.qualified_Name);


            --  new
            --
            declare
               the_Constructor : constant c_Function.view := Self.new_c_Function (the_Node,
                                                                           to_unbounded_String ("construct"),
                                                                           Self.current_c_Class.Namespace.all'Access,
                                                                           is_constructor => True);
            begin
               the_Constructor.is_Constructor     := True;
               the_Constructor.is_Static          := True;
               the_Constructor.constructor_Symbol := constructor_Symbol;
            end;

            if not (    check_Attribute (the_Node,  -"access",  -"protected")
                    or  check_Attribute (the_Node,  -"access",  -"private"))
            then
               print_to (Self.f_gnat,  construct_Call & NL);
            end if;
         end;
      end if;


      --  new ...
      --
      --  tbd: Self.prior_c_Declaration := new_Constant.all'access;

      unindent_Log;
      return SWIG_OK;
   end constructorHandler;



   overriding
   function destructorHandler_is_overridden (Self : in Item) return Boolean is begin   return True;   end destructorHandler_is_overridden;

   overriding
   function destructorHandler
     (Self : access Item;
      n    : in     doh_Node'Class) return Integer
   is
      the_Node   : doh_Node'Class      renames n;
   begin
      indent_Log;
      Self.current_c_Node := doh_Node (the_Node);
--        Self.current_Node := doh_Node (the_Node);

      if not (check_Attribute (the_Node,  -"access",  -"protected")  or  check_Attribute (the_Node,  -"access",  -"private")) then
         do_base_destructorHandler (Self.all,  the_node);
      end if;

      declare
--           use gnat_Parameter.Vectors;
         symname               : constant String  := +get_Attribute (the_Node,  -"sym:name");
         name                  : constant String  := +get_Attribute (the_Node,  -"name");
         is_default_Destructor : constant Boolean := symname /= name;
      begin
--           if        Self.proxy_flag
--             and not is_default_Destructor
--           then
--              declare
--                 return_Type    : constant String               := "void";
--                 the_Destructor : constant gnat_Subprogram.view := new_gnat_Subprogram (to_unbounded_String ("destruct"),
--                                                                               Self.demand_Type (the_Node, -return_Type));
--              begin
--                 the_Destructor.is_Destructor := True;
--                 append (the_Destructor.Parameters,  new_gnat_Parameter (the_Name => to_unbounded_String ("Self"),
--                                                                         the_Type => Self.current_class_Record.all'Access));
--
--                 Self.current_Package.add (the_Destructor.all'Access);
--              end;
--           end if;

         --  new ...
         --
         --  tbd: Self.prior_c_Declaration := new_Constant.all'access;

         unindent_Log;
         return SWIG_OK;
      end;
   end destructorHandler;



   overriding
   function membervariableHandler_is_overridden (Self : in Item) return Boolean is begin   return True;   end membervariableHandler_is_overridden;

   overriding
   function membervariableHandler
     (Self : access Item;
      n    : in     doh_Node'Class) return Integer
   is
      the_Node           :          doh_Node'Class renames n;

      swig_Type          :          doh_swigType'Class := doh_Copy (get_Attribute      (the_Node,  -"type"));
      swig_Type_is_array : constant Boolean            := SwigType_isarray   (swig_Type) /= 0;
      is_Pointer         : constant Boolean            := SwigType_ispointer (swig_Type) /= 0;
      variable_Name      : constant unbounded_String   := +get_Attribute     (the_Node,  -"sym:name");
--        ada_type_Name      : unbounded_String;
   begin
      indent_Log;
      log ("");
      log ("'memberVariableHandler':    Name => " & variable_Name & "     swig_Type: '" & String'(+swig_Type));

      strip_all_qualifiers (swig_Type);

      Self.current_c_Node := doh_Node (the_Node);

      if Self.is_smart_pointer = 0
      then    -- don't add a new member variable during smart pointer resolution.
         declare
            use c_Variable;
            new_Variable :          c_Variable.view;
            bit_Field    : constant String         := +get_Attribute (the_Node,  -"bitfield");
         begin
            if swig_Type_is_array
            then
               declare
--                    array_element_swigType       : doh_SwigType'Class := SwigType_del_array (doh_Copy (swig_Type));
                  unconstrained_array_swigType : constant unbounded_String   := strip_array_Bounds (doh_Copy (swig_Type));
               begin
--                    log ("unconstrained_array_swigType: '" & unconstrained_array_swigType & "'");
                  new_Variable := new_c_Variable (variable_Name,
                                                  Self.swig_type_Map_of_c_type.Element (unconstrained_array_swigType));
                  --                                                    Self.swig_type_Map_of_c_type.Element (+array_element_swigType));

               end;
            else
               new_Variable := new_c_Variable (variable_Name,
                                               Self.demand_c_Type_for (swig_Type));
               --                                                 Self.swig_type_Map_of_c_type.Element (+swig_Type));
            end if;

            new_Variable.is_Static        := False;
            new_Variable.is_class_Pointer := is_Pointer;

            if bit_Field /= "" then
               new_Variable.bit_Field := Integer'Value (bit_Field);
            end if;


            if swig_Type_is_array then
--                 log ("array member detected");
               Self.add_array_Bounds_to (new_Variable, swig_Type);
            end if;

            Self.current_c_Class.add_Component (new_Variable);
         end;
      end if;


--        Self.current_Node := doh_Node (the_Node);

      --  tbd: Self.prior_c_Declaration := new_Constant.all'access;

      unindent_Log;
      return SWIG_OK;
   end membervariableHandler;



   overriding
   function staticmembervariableHandler_is_overridden (Self : in Item) return Boolean is begin   return True;   end staticmembervariableHandler_is_overridden;

   overriding
   function staticmembervariableHandler
     (Self : access Item;
      n    : in     doh_Node'Class) return Integer
   is
      the_Node      :          doh_Node    'Class renames n;
      the_swigType  : constant doh_SwigType'Class      := get_Attribute (the_Node, -"type");
--        static_const_member_flag : Boolean            := String'(+get_Attribute (the_Node, -"value"))  =  "";
      variable_Name : constant unbounded_String        := +get_Attribute (the_Node,  -"sym:name");
      is_Pointer    : constant Boolean                 := SwigType_ispointer (the_swigType) /= 0;

   begin
      indent_Log;
      log ("");
      log ("'staticmemberVariableHandler':    Name => " & variable_Name & "   swig_type: " & to_String (the_swigType));

      Self.current_c_Node := doh_Node (the_Node);
--        Self.current_Node   := doh_Node (the_Node);

--        declare
--           new_Variable : constant gnat_Variable.view := new_gnat_Variable (variable_Name,
--                                                                   Self.demand_Type (the_Node, the_swigType));
--        begin
--           new_Variable.is_Static        := True;
--           new_Variable.is_class_Pointer := is_Pointer;
--
--           Self.current_Package.add (new_Variable.all'Access);
--
--           if swigType_isArray (the_swigType) /= 0 then
--  --              log ("array member detected");
--
--              Self.add_array_Bounds_to (new_Variable, the_swigType);
--           end if;
--        end;


      --  new ...
      --
      --  tbd: Self.prior_c_Declaration := new_Constant.all'access;

      unindent_Log;
      return SWIG_OK;
   end staticmembervariableHandler;



   overriding
   function memberconstantHandler_is_overridden (Self : in Item) return Boolean is begin   return True;   end memberconstantHandler_is_overridden;

   overriding
   function memberconstantHandler
     (Self : access Item;
      n    : in doh_Node'Class) return Integer
   is
      the_Node : doh_Node'Class renames n;
   begin
      indent_Log;

      Self.current_c_Node := doh_Node (the_Node);
--        Self.current_Node   := doh_Node (the_Node);

      Self.wrapping_member_flag := True;
      do_base_memberconstantHandler (Self.all, the_node);
      Self.wrapping_member_flag := False;

      --  new ...
      --
      --  tbd: Self.prior_c_Declaration := new_member_Constant.all'access;

      unindent_Log;
      return SWIG_OK;
   end memberconstantHandler;



   overriding
   function insertDirective_is_overridden (Self : in Item) return Boolean is begin   return True;   end insertDirective_is_overridden;

   overriding
   function insertDirective
     (Self : access Item;
      n    : in     doh_Node'Class) return Integer
   is
      the_Node :          doh_Node    'Class renames n;
      the_Code : constant doh_swigType'Class      := get_Attribute (the_Node, -"code");
   begin
      indent_Log;
      --  doh_replace_all (the_Code,  -"$module",   -Self.binding_Package.Name);
--        doh_replace_all (the_Code,  -"$module",   -Self.namespace_Package.Name);

      unindent_Log;
      return do_base_insertDirective (Self.all, the_Node);
   end insertDirective;



   overriding
   function usingDeclaration_is_overridden (Self : in Item) return Boolean is begin   return True;   end usingDeclaration_is_overridden;

   overriding
   function usingDeclaration
     (Self : access Item;
      n    : in     doh_Node'Class)
         return Integer
   is
      pragma Unreferenced (Self, n);
   begin
      return SWIG_OK;     -- do nothing, since public/protected/private is ignored in Ada
      --  so 'using::' clauses are irrelevant (ie the 'used' members are already available).
   end usingDeclaration;



   overriding
   function typedefHandler_is_overridden (Self : in Item) return Boolean is begin   return True;   end typedefHandler_is_overridden;

   overriding
   function typedefHandler (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node          :          doh_Node'Class   renames n;
      the_doh_type_Name : constant doh_String'Class      := get_Attribute (the_Node, -"name");
   begin
      indent_Log;
      log ("");
      log ("'typedefHandler'   the_doh_type_Name: '" & String'(+the_doh_type_Name) & "'");

      Self.current_c_Node := doh_Node (the_Node);

      --  new
      --
      if        (         Self.prior_c_Declaration     /= null
                 and then Self.prior_c_Declaration.Name = String'(+the_doh_type_Name))
        or else Self.swig_type_Map_of_c_type.contains (+the_doh_type_Name)
      then
         log ("Skipping typedef"); --  to anonymous c enum");
         --  return SWIG_OK;
      else
         declare
            Name             : constant unbounded_String   := +get_Attribute (the_Node, -"name");
            the_type_Name    : constant unbounded_String   := Name;

            the_doh_swigType : constant doh_SwigType'Class :=  get_Attribute (the_Node, -"type");
            the_swig_Type    : constant swig_Type          := +the_doh_swigType;

--              new_Key          : unbounded_String;
            Pad              :          doh_swigType'Class := null_Doh;
         begin
--              log ("'typedefHandler' - name: '" & Name & "'     swig_Type: '" & to_String (the_swig_Type) & "'");

            if SwigType_isarray (the_doh_swigType) /= 0
            then
--                 log ("typedef array detected");
               declare
                  swig_Type_copy       : constant doh_swigType'Class := doh_Copy (the_doh_swigType);
                  the_Array            : constant doh_SwigType'Class := SwigType_pop_arrays (swig_Type_copy);
                  dimension_Count      : constant Natural            := SwigType_array_ndim (the_Array);
                  element_Type         : constant doh_SwigType'Class := SwigType_array_type (swig_Type_copy);
                  array_dimension_Text :          unbounded_String;
                  new_c_Array          :          c_Type.view;
               begin
                  new_c_Array := c_type.new_array_Type (namespace    => Self.current_c_Namespace,
                                                        name         => the_type_Name,
                                                        element_Type => Self.swig_type_Map_of_c_type.Element (+element_Type));
                  for Each in 1 .. dimension_Count loop
                     array_dimension_Text := +SwigType_array_getdim (the_Array,  Each - 1);

                     c_type.add_array_Dimension (new_c_Array,
                                                 upper_Bound => Integer (Value (resolved_c_integer_Expression (Self,
                                                                                                               array_dimension_Text,
                                                                                                               Self.symbol_value_Map,
                                                                                                               Self.current_class_namespace_Prefix))) - 1);
                  end loop;

                  Self.register (new_c_Array, the_doh_type_Name);
                  Self.prior_c_Declaration := new_c_Array.all'Access;
               end;

            elsif is_a_function_Pointer (the_doh_swigType)
            then
--                 log ("function pointer found");

               Pad := SwigType_del_pointer (the_doh_swigType);

               declare
                  raw_swigType         : constant doh_SwigType'Class   := doh_Copy                (the_doh_swigType);
                  the_Function         : constant doh_SwigType'Class   := SwigType_pop_function   (raw_swigType);
                  function_return_Type : constant doh_SwigType'Class   := doh_Copy                (raw_swigType);
                  function_Parameters  : constant doh_ParmList'Class   := SwigType_function_parms (the_Function);

                  new_c_Function         : c_Function.view;
                  new_c_function_Pointer : c_Type.view;
               begin
--                    log ("function_return_Type: '" & String'(+function_return_Type) & "'");

                  new_c_Function         := c_function.new_c_Function   (to_unbounded_String ("anonymous"),
                                                                         Self.swig_type_Map_of_c_type.Element (+function_return_Type));
                  new_c_function_Pointer := c_type.new_function_Pointer (namespace         => Self.current_c_Namespace,
                                                                         name              => the_type_Name,
                                                                         accessed_function => new_c_Function);
                  new_c_Function.Parameters := Self.to_c_Parameters (function_Parameters);

                  Self.register (new_c_function_Pointer, the_doh_type_Name);
                  Self.prior_c_Declaration := new_c_function_Pointer.all'Access;
               end;

            elsif Swigtype_isfunction (the_doh_swigType) /= 0
            then
--                 log ("typedef function detected");

               declare
                  the_Function         : constant doh_SwigType'Class := SwigType_pop_function   (the_doh_swigType);
                  function_return_Type : constant doh_SwigType'Class := doh_Copy (the_doh_swigType);
                  function_Parameters  : constant doh_ParmList'Class := SwigType_function_parms (the_Function);

                  new_c_Function       : constant c_Function.view    := c_function.new_c_Function   (to_unbounded_String ("anonymous"),
                                                                                                     Self.swig_type_Map_of_c_type.Element (+function_return_Type));
                  new_c_Typdef_function :         c_Type.view;
               begin
--                    log ("function_return_Type: '" & String'(+function_return_Type) & "'");

                  new_c_Function.Parameters := Self.to_c_Parameters (function_Parameters);
                  new_c_Typdef_function     := c_type.new_typedef_Function (namespace        => Self.current_c_Namespace,
                                                                            name             => the_type_Name,
                                                                            typed_Function   => new_c_Function);
                  Self.register (new_c_Typdef_function,
                                 the_doh_type_Name,
                                 create_array_type => False);

                  Self.prior_c_Declaration := new_c_Typdef_function.all'Access;
               end;

            else
               if Self.swig_type_Map_of_c_type.contains (the_swig_Type)
               then
--                    log ("swig_type_Map_of_c_type.contains " & the_swig_Type);

                  declare
                     the_base_Type : constant c_Type.view := Self.swig_type_Map_of_c_type.Element (the_swig_Type);
                  begin
                     if "_" & the_type_Name = the_swig_Type
                     then
                        register_Mirror (Self,
                                         the_Type_Name,
                                         the_base_Type,
                                         to_Doh (to_String (the_type_Name)));
                        the_base_Type.Name_is (the_type_Name);
                        Self.name_Map_of_c_type.Element (the_base_Type.Name & "[]").Name_is (the_type_Name & "_array");
                     else
--                          log ("current_c_Namespace: " & to_String (Self.current_c_Namespace.Name));
                        declare
                           new_c_typeDef : constant c_Type.view := c_Type.new_Typedef (namespace => Self.current_c_Namespace,
                                                                                       Name      => the_type_Name,
                                                                                       base_Type => the_base_Type);
                        begin
                           if Self.c_class_Stack.is_Empty then
                              Self.register (new_c_typeDef, the_doh_type_Name);
                           else
                              Self.register (new_c_typeDef, to_Doh (to_String (Self.current_c_Class.Name & "::" & to_String (the_doh_type_Name))));
                           end if;

                           Self.prior_c_Declaration := new_c_typeDef.all'Access;
                        end;
                     end if;
                  end;

               else
                  if the_type_Name = the_swig_Type
                  then   -- Handle case:  'typedef struct  foo foo;'
                     declare
                        new_c_Class : c_Type.view;
                     begin
                        new_c_Class := c_Type.new_opaque_Struct (namespace => Self.current_c_nameSpace,
                                                                 name      => the_type_Name);
                        Self.register (new_c_Class, the_doh_type_Name);
                        Self.prior_c_Declaration := new_c_Class.all'Access;
                     end;

                  else   -- Handle case:  'typedef struct foo foo_t;'
                     declare
                        new_c_Class : c_Type.view;
                        class_Name  : doh_swigType'Class := doh_Copy (to_Doh (to_String (the_swig_Type)));
                     begin
                        strip_all_qualifiers (class_Name);
                        new_c_Class := c_Type.new_opaque_Struct (namespace => Self.current_c_nameSpace,
                                                                 name      => +class_Name); -- the_swig_Type           );
                        Self.register (new_c_Class, the_doh_swigType);

                        if "_" & the_type_Name = the_swig_Type
                        then
                           register_Mirror (Self,
                                            the_Type_Name,
                                            new_c_Class,
                                            to_Doh (to_String (the_type_Name)));
                           new_c_Class.Name_is (the_type_Name);

                           Self.name_Map_of_c_type.Element (new_c_Class.Name & "[]").Name_is (new_c_Class.Name & "_array");
                        else
                           declare
                              new_c_typeDef : constant c_Type.view := c_Type.new_Typedef (namespace => Self.current_c_Namespace,
                                                                                          Name      => the_type_Name,
                                                                                          base_Type => new_c_Class);
                           begin
                              Self.register (new_c_typeDef, the_doh_type_Name);
                              Self.prior_c_Declaration := new_c_typeDef.all'Access;
                           end;
                        end if;
                     end;
                  end if;

               end if;

            end if;
         end;
      end if;

      unindent_Log;
      return SWIG_OK;
   end typedefHandler;



   -----------
   --  Utility
   -----------

   function is_a_function_Pointer (Self : in doh_swigType'Class) return Boolean
   is
      swig_Type : constant doh_swigType'Class := doh_Copy (Self);
   begin
      return     SwigType_ispointer  (swig_Type)                         /= 0
        and then SwigType_isfunction (SwigType_del_pointer (swig_Type))  /= 0;
   end is_a_function_Pointer;


end gnat_Language;





--  Design Notes:
--

--  1) - for this case:     typedef struct Pointf
--                                 {
--                                   double     x, y;
--                                 } Pointf;
--
--      the struct type part has already been created by the time the typedef part is evaluated.
--
--    - so we can safely ignore the typedef declaration, as the (same named) class type itself should suffice.
--
--    - same applies for equivalent 'Class Pointf' cases.
--
--    - sampe applied for anonymous enum declarations, which have been typedef'ed.





--  Old - kept for reference
--

--     function package_Kind (for_Node   : in doh_Node'Class) return gnat_Package.a_Kind
--     is
--        the_Kind : gnat_Package.a_Kind;
--     begin
--        if exists (for_Node)
--        then
--           declare
--              the_Node         : doh_Node'Class renames for_Node;
--              the_Parent       : doh_Node'Class      := the_Node;  -- parent_Node (the_Node);
--              parent_node_Type : unbounded_String;
--           begin
--              while exists (the_Parent)
--              loop
--                 parent_node_Type := +node_Type (the_Parent);
--                 --               log ("parent node type: " & parent_node_Type);
--
--                 if parent_node_Type = "import"
--                 then
--                    declare
--                       parent_Name : constant String := +get_Attribute (the_Parent, -"name");
--                       the_Tail    : constant String := Tail (parent_Name,  2);
--                    begin
--                       if    the_Tail = ".i" then   the_Kind := module_Import;
--                       elsif the_Tail = ".h" then   the_Kind := header_Import;
--                       else                         raise Program_Error;         -- Should not occur.
--                       end if;
--
--                       exit;
--                    end;
--
--                 elsif parent_node_Type = "top"
--                 then
--                    the_Kind := Binding;  -- Core;
--                    exit;
--                 end if;
--
--                 the_Parent := parent_Node (the_Parent);
--              end loop;
--           end;
--
--        else
--           the_Kind := Core;
--        end if;
--
--        return the_Kind;
--     end package_Kind;




   -----------------------
   --  all_types_Container                     tbd: put in separate package ?
   -----------------------

--     package body all_types_Container
--     is
--
--        procedure Owner_is (Self : access Item;
--                            Now  : in     gnat_Language.view)
--        is
--        begin
--           Self.Owner := Now;
--        end Owner_is;
--
--
--
--        function stripped (Self      : access Item;
--                           swig_Type : in     doh_swigType'Class) return unbounded_String
--        is
--           stripped_swig_Type : unbounded_String := +SwigType_strip_qualifiers (swig_Type);
--        begin
--
--           strip_enum_Prefix                     (stripped_swig_Type);
--           strip_leading_global_namespace_Prefix (stripped_swig_Type); -- tbd: add this below in demand_Type also ?!
--
--           --  strip namespace Prefix, if any
--           --
--           declare
--              Cursor : namespace_Sets.Cursor := First (Self.owner.a_Namespaces);
--           begin
--              while has_Element (Cursor)
--              loop   -- Loop til there are no more namespaces left.
--                 declare
--                    the_Namespace   : constant String  := to_String (Element (Cursor)) & "::";
--                    namespace_Index : constant Natural := Index     (stripped_swig_Type,  the_Namespace);
--                 begin
--                    if namespace_Index /= 0 then
--                       delete (stripped_swig_Type,  namespace_Index,  namespace_Index + the_Namespace'Length - 1);
--                       Cursor := First (Self.owner.a_Namespaces);   -- Restart.
--                    else
--                       next (Cursor);
--                    end if;
--                 end;
--              end loop;
--           end;
--
--           --  Strip array bounds, if any.
--           --
--           declare
--              bounds_Start : Natural;
--              bounds_End   : Natural;
--           begin
--              loop
--                 bounds_Start := Index (stripped_swig_Type,  "a(");
--                 exit when bounds_Start = 0;                              -- loop repeatedly til there are no more array bounds left
--                 bounds_End   := Index (stripped_swig_Type,  ")",
--                                        from  => Index (stripped_swig_Type,
--                                                        ".",
--                                                        from => bounds_Start),
--                                        going => backward);
--
--                 delete (stripped_swig_Type,  bounds_Start + 1,  bounds_End);
--              end loop;
--           end;
--
--  --           log ("stripped swig_Type: '" & to_String (stripped_swig_Type));
--
--           return stripped_swig_Type;
--        end stripped;
--
--
--
--        procedure add_primal_c_Type (Self     : access Item;
--                                     new_Key  : in     unbounded_String;
--                                     new_Type : in     gnat_Type.view)
--        is
--        begin
--  --           log ("'add_primal_c_Type'   ~   new_Key: '" & new_Key & "'    new_Type: '" & new_Type.qualified_Name & "'");
--           insert (Self.a_all_Types,  Self.stripped (-new_Key),  new_Type);
--        end add_primal_c_Type;
--
--
--
--        procedure add (Self      : access Item;
--                       swig_Type : in     doh_swigType'Class;
--                       ada_Type  : in     gnat_Type.view)
--        is
--           stripped_swig_Type : constant unbounded_String := Self.stripped (swig_Type);
--        begin
--  --           log ("'all_types_Container.add' ~ stripped_swig_Type: '" & stripped_swig_Type & "'");
--
--           insert (Self.a_all_Types, stripped_swig_Type,  ada_Type);
--  --           log ("inserted new type");
--           ada_Type.declaration_Package.add (ada_Type);
--
--
--           if ada_Type.c_type_Kind /= standard_c_Type
--           then
--  --              log ("adding array type");
--
--              declare -- add the associated 'Items' type which acts as an c array for the 'ada_Type'.
--                 function the_array_type_Name return unbounded_String
--                 is
--                 begin
--                    if ada_Type.Name = "Item"
--                    then
--                       return to_unbounded_String ("Items");
--                    else
--                       return ada_Type.Name & "_array";
--                    end if;
--                 end the_array_type_Name;
--
--                 the_array_Type : constant gnat_Type.view := new_array_Type (declaration_Package => ada_Type.declaration_Package,
--                                                                             Name                => the_array_type_Name,
--                                                                             element_Type        => ada_Type);
--              begin
--                 the_array_Type.declaration_Package.add (the_array_Type);
--                 the_array_Type.add_array_Dimension     (upper_bound => -1);     -- -1 indicates an unconstrained array. (tbd: use a constant)
--
--                 --              insert (Self.a_all_Types, "a." & Self.stripped (swig_Type),   the_array_Type);
--                 insert (Self.a_all_Types, "a." & Self.stripped (swig_Type),   the_array_Type);
--
--                 ada_Type.my_array_Type_is (the_array_Type);
--              end;
--
--  --              log ("adding pointer type");
--
--              declare   -- add the associated 'View' type which acts as a pointer and reference to the 'ada_Type'.
--  --                 the_Pointer   : doh_swigType'Class := SwigType_add_pointer   (doh_Copy (swig_Type));
--                 the_Reference : constant doh_swigType'Class := SwigType_add_reference (doh_Copy (swig_Type));
--
--                 function the_view_type_Name return unbounded_String
--                 is
--                 begin
--                    if ada_Type.Name = "Item"
--                    then
--                       return to_unbounded_String ("View");
--                    else
--                       return ada_Type.Name & "_view";
--                    end if;
--                 end the_view_type_Name;
--
--                 the_view_Type : constant gnat_Type.view := new_type_Pointer (declaration_Package => ada_Type.declaration_Package,
--                                                                              Name                => the_view_type_Name,
--                                                                              accessed_Type       => ada_Type);
--              begin
--                 the_view_Type.declaration_Package.add (the_view_Type);
--
--                 insert (Self.a_all_Types,
--                         Self.stripped (the_Reference),
--                         the_view_Type);
--
--                 ada_Type.my_view_Type_is (the_view_Type);
--              end;
--           end if;
--
--  --           log ("end add");
--        end add;
--
--
--
--        procedure add_Synonym (Self      : access Item;
--                               swig_Type : in     doh_swigType'Class;
--                               ada_Type  : in     gnat_Type.view)
--        is
--        begin
--  --           log ("adding synonym: swig_Type: '" & String'(+swig_Type) & "'     ada_Type: '" & ada_Type.qualified_Name & "'");
--           insert (Self.a_all_Types,  Self.stripped (swig_Type),  ada_Type);
--        exception
--           when others =>    -- hack to get around old code bug
--              null;
--        end add_Synonym;
--
--
--
--        function fetch_Type (Self      : access Item;
--                             swig_Type : in     doh_swigType'Class) return gnat_Type.view
--        is
--           stripped_swig_Type : constant unbounded_String := Self.stripped (swig_Type);
--        begin
--  --           log ("'fetch_Type' - raw swig_Type: '" & String'(+swig_Type)  & "'   ... stripped: '" &  stripped_swig_Type  & "'");
--
--           if Index (String'(+swig_Type), "enum $unnamed") /= 0 then
--              return Self.fetch_Type (-"int");
--           end if;
--
--
--           if contains (Self.a_all_Types,  stripped_swig_Type) then
--              return Element (Self.a_all_Types,  stripped_swig_Type);
--           else
--              return null;
--           end if;
--        end fetch_Type;
--
--
--
--        function  fetch_Type (Self     : access Item;
--                              ada_Type : in     String) return gnat_Type.view
--        is
--           Cursor : swig_type_gnat_type_Maps.Cursor := First (Self.a_all_Types);
--        begin
--           while has_Element (Cursor) loop
--              if Element (Cursor).qualified_Name = ada_Type then
--                 return Element (Cursor);
--              end if;
--
--              next (Cursor);
--           end loop;
--
--           return null;        -- tbd: raise exception ?
--        end fetch_Type;
--
--
--
--        function contains (Self      : access Item;
--                           swig_Type : in     doh_swigType'Class) return Boolean is
--        begin
--           return contains (Self.a_all_Types,
--                            Self.stripped (swig_Type));
--        end contains;
--
--
--
--        function all_Types (Self : access Item) return gnat_Type.Views
--        is
--           Cursor    : swig_type_gnat_type_Maps.Cursor := First (Self.a_all_Types);
--           the_Types : gnat_Type.views (1 .. Integer (Length (Self.a_all_Types)));
--           Index     : Natural := 0;
--        begin
--           while has_Element (Cursor) loop
--              Index             := Index + 1;
--              the_Types (Index) := Element (Cursor);
--
--              next (Cursor);
--           end loop;
--
--           return the_Types;
--        end all_Types;
--
--
--        --  Debug
--        --
--        procedure log (Self : access Item)
--        is
--           Cursor : swig_type_gnat_type_maps.Cursor := First (Self.a_all_Types);
--        begin
--           while has_Element (Cursor)
--           loop
--  --              log (to_String ("swig_type: '" &  Key (Cursor)  & "'    gnat_Type: '" & Element (Cursor).qualified_Name & "'"));
--              next (Cursor);
--           end loop;
--        end log;
--
--     end all_types_Container;



--     procedure add_array_Bounds_to (Self           : access Item;
--                                    the_Variable   : in     gnat_Variable.view;
--                                    from_swig_Type : in     doh_swigType'Class)
--     is
--        use gnat_Variable.array_bounds_Vectors;
--
--        swig_Type_copy             : constant doh_swigType'Class      := doh_Copy (from_swig_Type);
--        the_Array                  : constant doh_SwigType'Class      := SwigType_pop_arrays (swig_Type_copy);
--        dimension_Count            : constant Natural                 := SwigType_array_ndim (the_Array);
--        --      element_Type               : doh_SwigType'Class      := SwigType_array_type (swig_Type_copy);
--        --      element_ada_Type           : doh_String'Class        := Swig_typemap_lookup (-"record_component_array_adatype", element_Type, null_Doh, null_Doh, null_Doh, null_Doh, null_Wrapper);
--
--        array_dimension_Expression : aliased unbounded_String;
--        resolved_array_Dimension   :         Integer;
--
--     begin
--  --        log ("'add_array_Bounds_to'  ~  swig_Type_copy: '" & String'(+swig_Type_copy) & "'     the_Array: '" & String'(+the_Array)
--  --             & "'    dimension_Count: " & Natural'Image (dimension_Count));   -- & "  element_Type: '" &  String'(+element_Type)
--  --        --             & "'"); --    element_ada_Type: '" & String'(+element_ada_Type) & "'");
--
--        for Each in 1 .. dimension_Count loop
--           array_dimension_Expression := +SwigType_array_getdim (the_Array, Each - 1);
--  --           log ("array_dimension_Expression: '" & array_dimension_Expression & "'");
--
--           if array_dimension_Expression = "" then
--              resolved_array_Dimension := 0;
--           else
--              resolved_array_Dimension := Integer (Value (resolved_c_integer_Expression (Self,  array_dimension_Expression,
--                Self.symbol_value_Map,
--                Self.current_class_namespace_Prefix)));
--           end if;
--
--           append (the_Variable.array_Bounds,  resolved_array_Dimension - 1);
--        end loop;
--     end add_array_Bounds_to;




--     procedure set_Kind_for (the_Package : in gnat_Package.view;
--                             from_Node   : in doh_Node'Class)
--     is
--     begin
--        the_package.Kind_is (package_Kind (from_Node));
--  --        log ("package " & the_Package.Name & " Kind is now " & gnat_package.a_Kind'Image (the_Package.Kind));
--     end set_Kind_for;



--     function current_module_Package (Self : access Item;   for_Node : in doh_Node'Class) return gnat_Package.view
--     is
--        the_Package : gnat_Package.view;
--     begin
--        if exists (for_Node)
--        then
--           declare
--              the_Node         : doh_Node'Class renames for_Node;
--              the_Parent       : doh_Node'Class      := parent_Node (the_Node);
--              parent_node_Type : unbounded_String;
--           begin
--              while exists (the_Parent)
--              loop
--                 parent_node_Type := +node_Type (the_Parent);
--                 --               log ("parent node type: " & parent_node_Type);
--
--                 if parent_node_Type = "import"
--                 then
--                    declare
--                       --  parent_Name : String := +get_Attribute (the_Parent, -"name");
--                       parent_module_Name : constant String := +get_Attribute (the_Parent, -"module");
--                       --                     the_Head    : String := Head (parent_Name,  Index (parent_Name, ".") - 1);
--                    begin
--  --                       log ("parent_module_Name: " & parent_module_Name);
--                       the_Package := old_demand_Package (Self, parent_module_Name);
--                       --  the_Package := old_demand_Package (Self, the_Head);
--                       exit;
--                    end;
--
--                 elsif parent_node_Type = "top"
--                 then
--                    the_Package := Self.namespace_Package;
--                    exit;
--                 end if;
--
--                 the_Parent := parent_Node (the_Parent);
--              end loop;
--           end;
--
--        else
--           raise Constraint_Error;   -- the_Kind := Core;
--        end if;
--
--
--        return the_Package;
--     end current_module_Package;



--     procedure update_Name_for_any_associated_Types_of (the_Type : in gnat_Type.view)
--     is
--     begin
--        if the_Type.my_view_Type /= null
--        then
--           if the_Type.Name = "Item"
--           then
--              the_Type.my_view_Type.Name_is (to_unbounded_String ("View"));
--           else
--              the_Type.my_view_Type.Name_is (the_Type.Name & "_view");
--           end if;
--
--           the_Type.my_view_Type.declaration_Package_is (the_Type.declaration_Package);
--        end if;
--
--
--        if the_Type.my_array_Type /= null
--        then
--           if the_Type.Name = "Item"
--           then
--              the_Type.my_array_Type.Name_is (to_unbounded_String ("Items"));
--           else
--              the_Type.my_array_Type.Name_is (the_Type.Name & "_array");
--           end if;
--
--           the_Type.my_array_Type.declaration_Package_is (the_Type.declaration_Package);
--        end if;
--     end update_Name_for_any_associated_Types_of;



--     function new_type_wrapper_Package (Self : access Item;   the_Node       : in     doh_Node'Class;
--                                                              class_Name     : in unbounded_String;                     -- tbd: better name or inline this in 'demand_Type'
--                                                              doh_swig_Type  : in doh_swigType'Class) return gnat_Type.view
--     is
--     begin
--  --        log ("'new_type_wrapper_Package' - classname: " &  class_Name  & "       type: " & String'(+doh_swig_Type));
--
--        declare
--           the_doh_swig_Type : constant doh_swigType'Class := doh_Copy (doh_swig_Type);
--
--           new_Class  : gnat_Package.view;
--           new_Type   : gnat_Type.view;
--
--           Pad        : doh_SwigType'Class := null_Doh;    -- only to hold unneeded returned objects.
--        begin
--           if        SwigType_ispointer   (the_doh_swig_Type) /= 0
--             or else SwigType_isreference (the_doh_swig_Type) /= 0
--           then
--              if SwigType_ispointer (the_doh_swig_Type) /= 0
--              then
--                 Pad := SwigType_del_pointer   (the_doh_swig_Type);
--              else
--                 Pad := SwigType_del_reference (the_doh_swig_Type);
--              end if;
--
--              if SwigType_isfunction (the_doh_swig_Type) /= 0
--              then
--                 declare
--                    the_Function         : constant doh_SwigType'Class   := SwigType_pop_function   (the_doh_swig_Type);
--                    function_return_Type : constant doh_SwigType'Class   := doh_Copy                (the_doh_swig_Type);
--                    function_Parameters  : constant doh_ParmList'Class   := SwigType_function_parms (the_Function);
--
--                    new_Subprogram       : constant gnat_Subprogram.view := new_gnat_Subprogram     (to_unbounded_String ("anonymous"),
--                                                                                                     Self.demand_Type (the_Node, function_return_Type));
--                 begin
--                    new_subprogram.Parameters := Self.to_gnat_Parameters (the_Node, function_Parameters);
--                    new_Type                  := new_function_Pointer    (accessed_Function => new_Subprogram);
--                 end;
--              else
--                 new_Type := new_type_Pointer (accessed_Type => Self.demand_Type (the_Node, the_doh_swig_Type));
--
--                 if Self.all_types_Container.contains (doh_swig_Type) then          -- our type has been created during 'demand_Type' (ie recursion),
--                    return Self.all_types_Container.fetch_Type (doh_swig_Type);     -- so just return it.  (tbd: clean this up)
--                 end if;
--              end if;
--
--              new_Class := Self.old_demand_Package (to_String (Self.current_module_Package (the_Node).qualified_Name & "." & class_Name));
--
--
--           elsif SwigType_isarray (the_doh_swig_Type) /= 0
--           then
--              declare
--                 the_Array       : constant doh_SwigType'Class := SwigType_pop_arrays (the_doh_swig_Type);
--                 dimension_Count : constant Natural            := SwigType_array_ndim (the_Array);
--                 element_Type    : constant doh_SwigType'Class := SwigType_array_type (the_doh_swig_Type);
--                 upper_Bound     :          Integer;
--              begin
--                 new_Type := new_array_Type (element_Type => Self.demand_Type (the_Node, element_Type));
--
--                 for Each in 1 .. dimension_Count
--                 loop
--                    upper_Bound := Integer (Value (c_expression_Resolver.resolved_c_integer_Expression (Self, unbounded_String'(+SwigType_array_getdim (the_Array,
--                      Each - 1)),
--                      Self.symbol_value_Map,
--                      Self.current_class_namespace_Prefix))  -  1);
--                    add_array_Dimension (new_Type,  upper_Bound);
--                 end loop;
--
--                 if SwigType_ispointer (the_doh_swig_Type) /= 0
--                 then
--                    Pad := SwigType_del_pointer (the_doh_swig_Type);
--                 end if;
--
--                 Pad := SwigType_del_element (the_doh_swig_Type);
--              end;
--
--              new_Class := Self.old_demand_Package (to_String (class_Name));
--
--           else
--  --              log ("'Unknown' swig type kind   ~   the_doh_swig_Type: '" & String'(+the_doh_swig_Type) & "'");
--
--              declare
--                 resolved_swigType : constant doh_SwigType'Class := SwigType_typedef_resolve_all (doh_Copy (the_doh_swig_Type));
--                 the_Type          : constant doh_SwigType'Class := doh_Copy (SwigType_pop (the_doh_swig_Type));   -- tbd: dubious !
--                 new_class_Name    :          unbounded_String   := class_Prefix_in (+doh_swig_Type);
--              begin
--  --                 log ("resolved: '" & String'(+resolved_swigType) & "'");
--
--                 if new_class_Name = ""
--                 then
--                    new_class_Name := identifier_suffix_in (+doh_swig_Type);
--                 end if;
--
--  --                 log ("new_class_Name: '" & new_class_Name & "'");
--
--  --                 log ("the_Type: '" & String'(+the_Type) & "'");
--                 new_Type := new_unknown_Type;        -- 'Unknown' type is a mutable variant record, so it can be morphed.
--
--                 new_Type.resolved_Type_is (Self.all_types_Container.fetch_Type (resolved_swigType));
--
--                 new_Class := Self.current_module_Package (the_Node);
--                 --  new_Class := Self.demand_Package (swig_type => -(Self.current_module_Package (the_Node).qualified_Name & "::" & new_class_Name));
--              end;
--           end if;
--
--  --           log ("resultant swig type: '" & String'(+the_doh_swig_Type) & "'");
--
--
--           --  new_Type.Name_is                (to_unbounded_String ("Item"));
--           new_Type.Name_is                (class_Name);
--           new_Type.declaration_Package_is (new_Class);
--
--           if Self.in_cpp_Mode then
--              new_Type.import_Convention_is (import_as_CPP);
--           else
--              new_Type.import_Convention_is (import_as_C);
--           end if;
--
--           return new_Type;
--        end;
--     end new_type_wrapper_Package;



--     function demand_Type (Self          : access Item;
--                           for_Node      : in     doh_Node'Class;
--                           doh_swig_Type : in     doh_swigType'Class) return gnat_Type.view
--     is
--        the_Type           : gnat_Type.view;
--        swig_Type_stripped : constant doh_swigType'Class :=  SwigType_strip_qualifiers (doh_swig_Type);   -- tbd: stripping is redundant
--        --        ada_type_Name      : unbounded_String   := +Swig_typemap_lookup       (-"adatype",  swig_Type_stripped,  null_Doh, null_Wrapper);
--     begin
--  --        log ("'demand_Type' - doh_swig_Type: '" & String'(+doh_swig_Type) & "'");
--
--        the_Type := Self.all_types_Container.fetch_Type (doh_swig_Type);
--
--        if the_Type /= null then
--           return the_Type;
--        end if;
--
--        declare
--           the_Descriptor : constant unbounded_String := Self.to_Descriptor (swig_Type_stripped);
--        begin
--  --           log ("descriptor: '" & the_Descriptor & "'");
--           the_Type := Self.new_type_wrapper_Package (for_Node, the_Descriptor, swig_Type_stripped);  -- tbd: inline (move) 'new_type_wrapper_Package' here ?
--
--           if Self.all_types_Container.contains (swig_Type_stripped) then     -- the type is a pointer/reference type and has been generated during 'new_type_wrapper_Package'.
--              return Self.all_types_Container.fetch_Type (swig_Type_stripped);
--           end if;
--        end;
--
--        declare
--           new_Key : unbounded_String := +swig_Type_stripped;
--        begin
--           strip_enum_Prefix (new_Key);
--
--  --           log ("adding new type: " & the_Type.qualified_Name & "    doh_swig_Type: '" & String'(+doh_swig_Type)
--  --                & "  new_Key: '" &  new_Key);
--
--           Self.all_types_Container.add (swig_type => swig_Type_stripped,
--                                         ada_type  => the_Type);
--        end;
--
--        return the_Type;
--     end demand_Type;



--     function old_demand_Package (Self  : access Item;
--                                  Named : in     String) return gnat_Package.view
--     is
--     begin
--  --        log ("'old_demand_Package' - Named: '" & Named & "'     num packages: " & Count_type'Image (Length (Self.all_Packages)));
--
--        if Named = "" then
--           return Self.standard_Package;
--        end if;
--
--        declare
--           Cursor : swig_type_package_Maps.Cursor := First (Self.all_Packages);
--        begin
--           while has_Element (Cursor) loop
--              --              log ("each package name: '" & Element (cursor).qualified_Name & "'");
--
--              if element (cursor).qualified_Name = Named then
--                 return Element (Cursor);
--              end if;
--
--              next (Cursor);
--           end loop;
--        end;
--
--        declare
--           new_Package : gnat_Package.view;
--           parent_Name : constant String          := Text_before_last_dot (Named);
--        begin
--  --           log ("parent name: '" & parent_Name & "'");
--
--           if parent_Name = "" then
--              new_Package := new_gnat_Package (name   => Named,
--                                               parent => Self.standard_Package);
--           else
--              new_Package := new_gnat_Package (name   => Text_after_last_dot (Named),
--                                               parent => old_demand_Package (Self, parent_Name));
--           end if;
--
--           set_Kind_for (new_Package, from_node => Self.current_Node);
--
--  --           log ("adding new package: " & new_Package.qualified_Name);
--
--           insert (Self.all_Packages,  to_unbounded_String (Named), new_Package);
--           return new_Package;
--        end;
--     end old_demand_Package;



--     function demand_Package (Self : access Item;   swig_Type : in doh_swigType'Class) return gnat_Package.view
--     is
--        the_swig_Type : constant unbounded_String := my_stripped (Self, swig_Type);
--     begin
--  --        log ("'demand_Package' - raw swig_Type: '" & String'(+swig_Type) & "'     the_swig_Type: '" & the_swig_Type & "'");
--
--        if contains (Self.all_Packages, the_swig_Type) then
--           return Element (Self.all_Packages, the_swig_Type);
--        end if;
--
--        declare
--           new_Package : gnat_Package.view;
--           parent_Name : constant unbounded_String          := class_Prefix_in (the_swig_Type);
--        begin
--  --           log ("parent name: '" & parent_Name & "'");
--
--           if parent_Name = "" then
--              new_Package := new_gnat_Package (name   => to_String (Self.to_Descriptor (-the_swig_Type)),    -- to_String (the_swig_Type),
--                                               parent => Self.namespace_Package);              -- tbd: shoudn't this be namespace_Package ?
--              --  parent => Self.standard_Package);              -- tbd: shoudn't this be namespace_Package ?
--           else
--              --  new_Package := new_gnat_Package (name   => to_String (identifier_Suffix_in (the_swig_Type)),
--              new_Package := new_gnat_Package (name   => to_String (Self.to_Descriptor (-identifier_Suffix_in (the_swig_Type))),
--                                               parent => Self.demand_Package (-parent_Name));
--           end if;
--
--           set_Kind_for (new_Package, from_node => Self.current_Node);
--
--  --           log ("adding new package: key ~ '" & the_swig_type & "'    " & new_Package.qualified_Name & "    brief Name: '" &  new_Package.Name & "'");
--
--           insert (Self.all_Packages,  the_swig_Type, new_Package);
--  --           log ("inserted");
--           return new_Package;
--        end;
--     end demand_Package;



--     function old_fetch_Package (Self  : access Item;
--                                 Named : in     String) return gnat_Package.view
--     is
--     begin
--  --        log ("'old_fetch_Package' - Named: " & Named);
--
--        if Named = "" then
--           return Self.standard_Package;
--        end if;
--
--        declare
--           Cursor : swig_type_package_Maps.Cursor := First (Self.all_Packages);
--        begin
--           while has_Element (Cursor)
--           loop
--              --  log ("each package name: " & Element (cursor).qualified_Name);
--
--              if element (cursor).qualified_Name = Named then
--                 return Element (Cursor);
--              end if;
--
--              next (Cursor);
--           end loop;
--        end;
--
--        return null;
--     end old_fetch_Package;



--     function fetch_Package (Self      : access Item;
--                             swig_Type : in     doh_swigType'Class) return gnat_Package.view
--     is
--        the_swig_Type : constant unbounded_String := my_stripped (Self, swig_Type);
--     begin
--  --        log ("'fetch_Package' - raw swig_Type: " & String'(+swig_Type) & "     the_swig_Type: '" & the_swig_Type & "'");
--
--        if contains (Self.all_Packages, the_swig_Type) then
--           return Element (Self.all_Packages, the_swig_Type);
--        end if;
--
--        return null;
--     end fetch_Package;





   --     -- tbd: this is a 'quick and dirty' ... only handles very simple expressions, as yet.
   --     --
   --     function to_enum_rep_Value (Self     : access Item;
   --                                 the_Text : in     unbounded_String) return Integer
   --     is
   --        text_Pad  : unbounded_String := the_Text;
   --     begin
   --        log ("'to_enum_rep_Value'  ~  the_Text: '" & the_text & "'");
   --
   --        strip_c_integer_literal_qualifiers_in (text_Pad);
   --
   --        if Index (text_Pad, "<<") /= 0 then
   --           begin
   --              return resolved_c_left_shift_Operator (text_Pad);
   --           exception
   --              when constraint_Error =>
   --                 log ("Fatal error: unable to convert to enum representation value: '" & the_Text & "'");
   --                 exit_with_Fail;
   --           end;
   --        end if;
   --
   --
   --        return to_Int (text_Pad);    -- attempt simple integer conversion - intended to fail when not a simple integer.
   --
   --     exception
   --        when constraint_Error =>   --tbd: use a custom exception or restructure all this (get rid of exception handling part)
   --
   --           declare
   --              use ada.Strings;
   --              the_Value : Integer          := 0;
   --              Operation : Character        := '+';
   --              First     : Natural;
   --              Last      : Natural;
   --
   --
   --              function resolved_Token return Integer
   --              is
   --                 use symbol_value_Maps;
   --                 the_Token : unbounded_String := unbounded_Slice (text_Pad,  First, Last);
   --              begin
   --                 if contains (Self.symbol_value_Map,  the_Token) then
   --                    return Element (Self.symbol_value_Map,  the_Token);
   --                 else
   --                    return to_Int (the_Token);
   --                 end if;
   --              end;
   --
   --
   --           begin
   --
   --              loop
   --                 find_Token (text_Pad,   to_Set ("+-"), Outside,   First, Last);
   --
   --                 case Operation is
   --                    when '+' =>   the_Value := the_Value + resolved_Token;
   --                    when '-' =>   the_Value := the_Value - resolved_Token;
   --
   --                    when others =>
   --                       log ("Fatal error: unkwown operation: '" & Operation & "'  from   '" & to_String (the_Text) & "'");
   --                       exit_with_Fail;
   --                 end case;
   --
   --                 delete (text_Pad,  First, Last);
   --
   --                 exit when text_Pad = "";
   --
   --                 Operation := Element (text_Pad, 1);
   --                 delete (text_Pad,  1, 1);
   --              end loop;
   --
   --              return the_Value;
   --           end;
   --
   --     end;





--     function new_Function (Self           : access Item;
--                            the_Node       : in     doh_Node'Class;
--                            function_name  : in     unbounded_String;
--                            parent_Package : in     gnat_Package.view;
--                            is_Constructor : in     Boolean          := False) return gnat_Subprogram.view
--     is
--        use gnat_parameter.Vectors;
--
--        the_swigType               : constant doh_swigType'Class   := get_Attribute                (the_Node,  -"type");
--  --        swigType_resolved          : doh_swigType'Class   := SwigType_typedef_resolve_all (the_swigType);
--        --  swigType_resolved          : doh_swigType'Class   := doh_Copy (the_swigType);
--
--        parameter_list             : doh_ParmList'Class   := get_Attribute (the_Node,  -"parms");
--        the_Parameters             : gnat_parameter.Vector;
--
--        the_return_type            : gnat_Type.view;
--
--        return_by_Reference        : constant Boolean              := SwigType_isreference (the_swigType) /= 0;
--        return_by_Pointer          : constant Boolean              := SwigType_ispointer   (the_swigType) /= 0;
--
--     begin
--  --        log ("'new_Function'    name: '" & function_name & "'     swig_type: '" & String'(+the_swigType) & "'");
--
--        Self.current_c_Node := doh_Node (the_Node);
--        Self.current_Node := doh_Node (the_Node);
--
--        freshen_current_module_Package (Self, the_Node);
--
--        if String'(+get_Attribute (the_Node, -"overload:ignore")) /= "" then   return null;   end if;     -- wrappers not wanted for some methods where the parameters cannot be overloaded in Ada
--
--        --  parameters
--        --
--        if exists (parameter_list)
--        then
--           if SwigType_type (get_Attribute (parameter_list, -"type")) = T_VOID
--           then
--              parameter_list := next_Sibling (parameter_list);
--           end if;
--
--        end if;
--
--        if         Self.current_class_Record /= null
--          and then not Self.static_flag
--          and then not is_Constructor
--        then    -- add the class 'Self' controlling parameter.
--           declare
--              self_Parameter : constant gnat_Parameter.view := new_gnat_Parameter (the_name => to_unbounded_String ("Self"),
--                                                                          the_type => Self.current_class_Record.all'Access);
--           begin
--              append (the_Parameters,  self_Parameter);
--           end;
--        end if;
--
--        append (the_Parameters,  Self.to_gnat_Parameters (the_Node, parameter_List));
--
--
--        --  the return type
--        --
--        if is_Constructor then
--           the_return_Type := Self.current_class_Record.all'Access;
--        else
--
--           declare
--              virtualtype : constant doh_swigType'Class := get_Attribute (the_Node,  -"virtual:type");
--           begin
--              if exists (virtualType) then                             -- note that in the case of polymorphic (covariant) return types, the method's
--                 the_return_Type := Self.demand_Type (the_Node, virtualtype);
--                 log ("covariant return types not supported in Ada ... proxy method will return " & String'(+SwigType_str (virtualtype, null_Doh)));
--              else
--                 the_return_Type := Self.demand_Type (the_Node, the_swigType);
--              end if;
--           end;
--        end if;
--
--
--        --  'throw's and exceptions (tbd)
--        --
--        --      generateThrowsClause (node, spec_function_code);
--        --      Printf (spec_function_code, "\n\n");
--
--        --
--        --      generateThrowsClause (node, body_function_code);
--        --      Printf (body_function_code,
--        --              " %s  end %s;\n\n",
--        --              type_map ? (const String *)
--        --                       : empty_string,
--        --              proxy_function_name);
--        --
--        --      Replaceall  (body_function_code, ".item  ", " ");    // hack to remove superfluous '.item  ' which is generated
--        --                                                           // for functions returning enums
--        --      */
--
--
--        if not (        Self.wrapping_member_flag
--                and not Self.enum_constant_flag)
--        then     -- there is no need for setter/getter functions, since the actual object is available.
--           declare
--              new_Function : constant gnat_Subprogram.view := new_gnat_Subprogram (function_name,
--                                                                          the_return_type);
--           begin
--              new_Function.Parameters        := the_Parameters;
--              new_Function.link_Symbol       := Self.current_linkage_Symbol;
--              new_Function.returns_an_Access := return_by_Reference  or  return_by_Pointer;
--
--              if    checkAttribute (the_Node, -"access",  -"public")    /= 0 then    new_Function.access_Mode := public_access;
--              elsif checkAttribute (the_Node, -"access",  -"protected") /= 0 then    new_Function.access_Mode := protected_access;
--              elsif checkAttribute (the_Node, -"access",  -"private")   /= 0 then    new_Function.access_Mode := private_access;
--              else                                                                   new_Function.access_Mode := unknown;
--              end if;
--
--              if parent_Package = Self.binding_Package then
--                 new_Function.is_Static   := True;
--              else
--                 new_Function.is_Static   := Self.static_flag;
--                 new_Function.is_Virtual  := checkAttribute (the_Node,  -"storage",  -"virtual") /= 0;
--                 new_Function.is_Abstract := checkAttribute (the_Node,  -"abstract", -"1")       /= 0;
--              end if;
--
--              parent_Package.add (new_Function.all'Access);
--              return new_Function;
--           end;
--        else
--           return null;
--        end if;
--
--     end new_function;






--     function to_gnat_Parameters (Self            : access Item;
--                                  the_Node        : in     doh_Node'Class;
--                                  swig_Parameters : in     doh_ParmList'Class) return gnat_parameter.Vector
--     is
--        the_gnat_Parameters : gnat_parameter.Vector;
--     begin
--  --        log ("'to_gnat_Parameters'");
--
--
--        Swig_typemap_attach_parms (-"in",                 swig_Parameters, null_Wrapper);    -- attach the non-standard typemaps to the parameter list
--        Swig_typemap_attach_parms (-"adatype",            swig_Parameters, null_Wrapper);    --
--        Swig_typemap_attach_parms (-"adain",              swig_Parameters, null_Wrapper);    --
--        Swig_typemap_attach_parms (-"imtype",             swig_Parameters, null_Wrapper);    --
--        Swig_typemap_attach_parms (-"link_symbol_code",   swig_Parameters, null_Wrapper);    --
--
--
--        declare
--           num_arguments : constant Integer        := emit_num_arguments (swig_Parameters);
--           the_Parameter : doh_Parm'Class := swig_Parameters;
--           Index         : Integer        := 0;
--        begin
--           emit_mark_varargs (swig_Parameters);
--
--  --           log ("num_arguments: " & Integer'Image (num_arguments));
--
--           while exists (the_Parameter) loop
--
--              if check_Attribute (the_Parameter,  -"varargs:ignore",  -"1") then
--                 the_Parameter := next_Sibling (the_parameter);                            -- ignored varargs
--
--              elsif check_Attribute (the_Parameter,  -"tmap:in:numinputs",  -"0") then
--                 the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");         -- Ignored parameters
--
--              else
--                 if not (Self.variable_wrapper_flag  and  Index = 0) then                  -- ignore the 'this' argument for variable wrappers
--                    declare
--                       use gnat_Parameter.Vectors;
--                       param_swigType : constant doh_SwigType'Class  := get_Attribute (the_parameter,  -"type");
--                    begin
--                       if not (String'(+param_swigType) = "") then -- guard against an empty parameter list
--                          declare
--                             arg            : constant unbounded_String    := to_unbounded_String (Self.makeParameterName (swig_Parameters, the_Parameter, Index));
--                             new_Parameter  : constant gnat_Parameter.view := new_gnat_Parameter  (arg,  Self.demand_Type (the_Node, param_swigType));
--                          begin
--                             new_Parameter.link_symbol_Code := +get_Attribute       (the_Parameter,  -"tmap:link_symbol_code");
--                             new_Parameter.is_Pointer       :=         SwigType_isreference (param_swigType) /= 0
--                               or else SwigType_ispointer   (param_swigType) /= 0;
--
--  --                             log ("adding new parameter: " & new_Parameter.Name
--  --                                  & " type: " & new_parameter.my_type.name
--  --                                  & "  is pointer : " & Boolean'Image (new_parameter.is_Pointer));
--
--
--                             append (the_gnat_Parameters,  new_Parameter);
--                          end;
--                       end if;
--                    end;
--                 end if;
--
--                 the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");
--              end if;
--
--
--              Index := Index + 1;
--           end loop;
--
--        end;
--
--
--        return the_gnat_Parameters;
--     end to_gnat_Parameters;
