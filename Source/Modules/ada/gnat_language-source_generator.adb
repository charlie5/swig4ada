with
     ada_type.a_Subtype,
     ada_Type.elementary.scalar.discrete.enumeration,
     ada_Type.elementary.an_access.to_type.interfaces_c_pointer,
     ada_Type.elementary.an_access.to_subProgram,
     ada_Type.composite.an_array,
     ada_Type.composite.a_record;


--  old ...
--
with a_Namespace;                  use a_Namespace;

with ada.strings.Maps.constants;   use ada.strings.Maps.constants;
with Ada.Characters.Handling;      use Ada.Characters.Handling;

with ada_Context;            use ada_Context;

with swigg_Module;            use swigg_Module;
with Dispatcher;              use Dispatcher;
with Wrapper;                 use Wrapper;

with ada_Utility;            use ada_Utility;
with swig_p_Doh;
with ada.strings.Maps;        use ada.strings.Maps;
with ada.text_IO;             use ada.text_IO;
with ada_Variable;            use ada_Variable;
with ada_Type;                use ada_Type;
with Ada.Unchecked_Conversion;


package body gnat_Language.source_Generator
is
   use ada_Type.composite.a_record,
       ada.Strings,
       ada_Package;

   use type swig_p_Doh.item;



   function "+" (Self : in String) return unbounded_String
                 renames to_unbounded_String;

   function "+" (Self : in unbounded_String) return String
                 renames to_String;
   pragma Unreferenced ("+");



   subtype subType_view         is ada_Type.a_subType.view;
   subtype subType_class        is ada_Type.a_subType.item'Class;

   subtype Access_to_Type_view  is ada_Type.elementary.an_access.to_type.view;
   subtype Access_to_Type_class is ada_Type.elementary.an_access.to_type.item'Class;

   subtype an_Array_view        is ada_Type.composite.an_array.view;
   subtype an_Array_class       is ada_Type.composite.an_array.item'Class;

   subtype a_Record_view        is ada_Type.composite.a_record.view;
   subtype a_Record_class       is ada_Type.composite.a_record.item'Class;

   subtype ic_Pointer_view      is ada_Type.elementary.an_access.to_type.interfaces_c_pointer.view;
   subtype ic_Pointer_class     is ada_Type.elementary.an_access.to_type.interfaces_c_pointer.Item'Class;

   NL : constant String := portable_new_line_Token;


   function depends_on (Self          : access ada_Type.Item'Class;
                        a_Type        : in     ada_Type.view;
                        the_Gnat_Lang : access gnat_Language.item)    return Boolean
   is
      pragma Unreferenced (the_Gnat_Lang);
      --        my_Depends : ada_Type.views := required_Types (Self, the_Gnat_Lang);
      my_Depends : constant ada_Type.views := Self.required_Types;

   begin
      for Each in my_Depends'Range
      loop
         if my_Depends (Each) = a_Type
         then
            return True;
         end if;
      end loop;

      return False;
   end depends_on;


   function ada_Record_public_declaration_Text (Self : ada_Type.composite.a_record.view) return String
   is
      use ada_type.Vectors,
          ada.Containers;

      the_Source              :          unbounded_String;
      union_variant_type_Name : constant unbounded_String := Self.Name & "_variant";

      base_Classes            : constant ada_type.Vector := Self.base_Classes;

   begin
      append (the_Source,  NL  &  "type "  &  Self.Name);

      if Self.is_Union
      then
         append (the_Source,  " (union_Variant : " &  union_variant_type_Name & " := " & union_variant_type_Name & "'First)");
      end if;

      append (the_Source,  " is ");


      if not is_Empty (base_Classes)
      then
         if Self.is_Limited
         then
            append (the_Source,  "limited ");
         end if;

         append (the_Source,  "new ");

         declare
            Cursor : ada_type.Cursor := First (base_Classes);
         begin
            while has_Element (Cursor)
            loop
               if Cursor /= First (base_Classes)
               then
                  append (the_Source,  NL & "                and ");
               end if;

               append (the_Source,  Element (Cursor).declaration_package.Name & ".item");
               next   (Cursor);
            end loop;
         end;

         if Self.is_tagged_Type  or  Length (base_Classes) > 1
         then
            append (the_Source,  " with private");
         end if;

      else
         if Self.is_interface_Type
         then
            append (the_Source,  " limited interface");

         elsif Self.virtual_member_function_Count > 0
         then
            if Self.pure_virtual_member_function_Count > 0
            then
               append (the_Source,  " abstract");
            end if;

            append (the_Source,  " tagged limited private");

         else
            append (the_Source,  " private");
         end if;
      end if;

      append (the_Source,  ";");

      return to_String (the_Source);
   end ada_Record_public_declaration_Text;

   pragma Unreferenced (ada_Record_public_declaration_Text);


   function ada_Record_private_declaration_Text (Self : in ada_Type.composite.a_record.view) return String
   is
      use ada_type.Vectors,
          ada.Containers;

      the_Source              :          unbounded_String;
      union_variant_type_Name : constant unbounded_String := Self.Name & "_variant";

      base_Classes            : constant ada_type.Vector  := Self.base_Classes;

   begin
      if Self.is_interface_Type then
         return "";
      end if;


      if Self.requires_Interfaces_C_Int_use
      then
         append (the_Source, "   use type interfaces.C.int;"   & NL & NL);
      end if;

      if Self.requires_Interfaces_C_Unsigned_use
      then
         append (the_Source, "   use type interfaces.C.Unsigned;"   & NL & NL);
      end if;

      if Self.requires_Interfaces_C_Unsigned_Char_use
      then
         append (the_Source, "   use type interfaces.C.Unsigned_Char;"   & NL & NL);
      end if;

      if Self.requires_Interfaces_C_Extensions_bool_use
      then
         append (the_Source, "   use type interfaces.C.extensions.bool;"   & NL & NL);
      end if;


      if Self.is_Union
      then
         append (the_Source,    NL & NL & "type " & union_variant_type_Name & " is (");

         declare
            the_Component : access ada_variable.item'Class;
         begin
            for Each in 1 .. Self.component_Count
            loop
               the_Component := Self.Components (Each);

               append (the_Source,  the_Component.Name  & "_variant");

               if Each /= Self.component_Count
               then
                  append (the_Source,  ", ");
               end if;

            end loop;
         end;

         append (the_Source,  ");" & NL);
      end if;


      append (the_Source,  NL  &  "type "  &  Self.Name);

      if Self.is_Union
      then
         append (the_Source,  " (union_Variant : " &  union_variant_type_Name & " := " & union_variant_type_Name & "'First)");
      end if;

      append (the_Source,  " is ");


      if not is_Empty (base_Classes)
      then
         if Self.is_Limited
         then
            append (the_Source,  "limited ");
         end if;

         append (the_Source,  "new ");

         declare
            Cursor : ada_type.Cursor := First (base_Classes);
         begin
            while has_Element (Cursor)
            loop
               if Cursor /= First (base_Classes)
               then
                  append (the_Source,  NL & "                and ");
               end if;

               append (the_Source,  Element (Cursor).declaration_package.Name & ".item");
               next   (Cursor);
            end loop;
         end;

         append (the_Source,  " with");

      else
         if Self.is_interface_Type
         then
            append (the_Source,  " limited interface");

         elsif Self.virtual_member_function_Count > 0
         then
            if Self.pure_virtual_member_function_Count > 0
            then
               append (the_Source,  " abstract");
            end if;

            append (the_Source,  " tagged limited");
         end if;
      end if;


      if not Self.is_interface_Type
      then
         declare
            has_Components : constant Boolean := False;
         begin
            append (the_Source,  NL & "      record");

            --  member variables (ie components)
            --
            if Self.component_Count = 0
            then
               if not has_Components
               then
                  append (the_Source,   NL & "          null;");
               end if;

            else
               if Self.is_Union
               then
                  append (the_Source,  NL & "      case union_Variant is");
               end if;

               declare
                  use ada_Variable.array_bounds_Vectors;

                  the_Component : access ada_variable.item'Class;
                  type_Modifier :        unbounded_String;
                  type_Name     :        unbounded_String;
               begin
                  for Each in 1 .. Self.component_Count
                  loop
                     the_Component := Self.Components (Each);

                     if Self.is_Union
                     then
                        append (the_Source,  NL & "         when " & the_component.Name & "_variant =>");
                     end if;

                     if         the_Component.my_Type.all in ada_type.a_Subtype.Item'Class
                       and then ada_type.a_Subtype.view (the_Component.my_Type).base_Type.all in ada_Type.elementary.an_access.to_type.item'Class
                       and then ada_Type.elementary.an_access.to_type.view (ada_type.a_Subtype.view (the_Component.my_Type).base_Type).accessed_Type = Self.all'Access
                     then
                        type_Modifier := to_unbounded_String ("access");
                        type_Name     := Self.qualified_Name;

                     elsif      the_Component.my_Type.all in ada_type.a_Subtype.Item'Class
                       and then ada_type.a_Subtype.view (the_Component.my_Type).base_Type.all in ic_Pointer_Class
                     then
                        type_Modifier := to_unbounded_String ("access");
                        type_Name     := ada_Type.elementary.an_access.to_type.view (ada_type.a_Subtype.view (the_Component.my_type).base_type).accessed_Type.qualified_Name;

                     elsif      the_Component.my_type.resolved_Type.all in ada_Type.elementary.an_access.to_type.item'Class
                       and then ada_Type.elementary.an_access.to_type.view (the_Component.my_type.resolved_Type).accessed_Type.qualified_Name /= "Character"
                     then
                        type_Modifier := to_unbounded_String ("access");
                        type_Name     := ada_Type.elementary.an_access.to_type.view (the_Component.my_type.resolved_Type).accessed_Type.qualified_Name;

                     else
                        if the_Component.bit_Field = -1
                        then   -- Components, which have bit fields specified, cannot be aliased.
                           type_Modifier := to_unbounded_String ("aliased");
                        end if;

                        type_Name := the_Component.my_type.qualified_Name;
                     end if;

                     append (the_Source,  NL & "         " & the_Component.Name  & " : " & type_Modifier & " " & type_Name);


                     if not is_Empty (the_component.array_Bounds)
                     then
                        append (the_Source, " (");

                        for Each in 1 .. Integer (Length (the_component.array_Bounds))
                        loop
                           if Each > 1
                           then
                              append (the_Source, ",");
                           end if;

                           append (the_Source, "0 .." & Natural'Image (Element (the_component.array_Bounds, Each)));
                        end loop;

                        append (the_Source, ")");
                     end if;


                     if         the_Component.bit_Field /= -1
                       and then the_Component.my_Type.all in ada_type.elementary.scalar.discrete.Enumeration.item'Class
                     then
                        declare
                           ultimate_base_Type_Name : constant unbounded_String := to_unbounded_String (to_Lower (to_String (the_Component.my_Type.resolved_Type.Name)));
                        begin
                           if         Index (ultimate_base_Type_Name, "unsigned") = 0
                             and then Index (ultimate_base_Type_Name, "bool")     = 0
                           then   -- Must be signed.
                              append (the_Source,   " range -2**" & Natural'Image (the_Component.bit_Field - 1)
                                      & " .. 2**"     & Natural'Image (the_Component.bit_Field - 1) & " - 1");
                           else   -- Must be unsigned.
                              append (the_Source,   " range 0 .. 2**" & Natural'Image (the_Component.bit_Field) & " - 1");
                           end if;
                        end;
                     end if;

                     append (the_Source,  ";");
                  end loop;
               end;


               if Self.is_Union
               then
                  append (the_Source,  NL & "      end case;");
               end if;
            end if;

            append (the_Source,  NL & "      end record");
         end;
      end if;

      append (the_Source,  ";" & NL & NL);


      if Self.is_Union
      then
         append (the_Source,  "   pragma unchecked_Union (" & Self.Name & ");" & NL & NL);
      end if;

      return to_String (the_Source);
   end ada_Record_private_declaration_Text;





   --  nb: the size of a 'subtype enumeration_type_subtype is enumeration_type' is different to the size of the enumeration_type itSelf !!
   --     (tbd: add design note !!!)
   --     (tbd: should we try to force the subtype to the same size as its base enumeration type ?

   function Enum_declaration_Text (Self : ada_Type.elementary.scalar.discrete.enumeration.view) return String
   is
      use ada_Type.elementary.scalar.discrete.enumeration.enum_literal_Vectors;

      the_Source   : unbounded_String;
      the_Literals : ada_Type.elementary.scalar.discrete.enumeration.enum_literal_Vectors.Vector := Self.Literals;

      function "<" (Left, Right : in ada_Type.elementary.scalar.discrete.enumeration.enum_Literal) return Boolean
      is
      begin
         return Value (Left.Value) < Value (Right.Value);
      end "<";

      package Sorter is new ada_Type.elementary.scalar.discrete.enumeration.enum_literal_Vectors.Generic_Sorting ("<");

   begin
      Sorter.sort (the_Literals);

      append (the_Source,  "   type " & Self.Name & " is (");

      if is_Empty (Self.Literals)
      then
         append (the_Source,  " nil");
      else
         for Each in 1 .. Natural (Length (Self.Literals))
         loop
            if not (         Each > 1
                    and then Element (the_Literals,  Each).Value = Element (the_Literals,  Each - 1).Value)   -- skip any with duplicate values.
            then
               if Each > 1
               then
                  append (the_Source,  "," & NL);
               end if;

               append (the_Source,  "   " & element (the_Literals,  each).Name);
            end if;
         end loop;
      end if;

      append (the_Source,   ");");


      --  nb: enumeration representation clauses and pragmas need to be done immediately after the type's declaration
      --     (and not in the private part, as usual), since they may be used as variables or record components prior
      --     to the packages private part.
      --
      append (the_Source,  NL & NL & "   for " & Self.Name & " use (");

      if is_Empty (the_Literals)
      then
         append (the_Source,  " nil => 0");
      else
         for Each in 1 .. Natural (Length (the_Literals))
         loop
            if not (         Each > 1
                    and then Element (the_Literals,  Each).Value = Element (the_Literals,  Each - 1).Value)   -- skip any with duplicate values.
            then
               if Each > 1
               then
                  append (the_Source,  "," & NL);
               end if;

               append (the_Source,  "   " & element (the_Literals, each).Name  &  " => "  &  Image (element (the_Literals, each).Value));
            end if;
         end loop;
      end if;

      append (the_Source,   ");");
      append (the_Source,   NL & NL & "   pragma Convention (C, " & Self.Name &  ");" & NL);


      return to_String (the_Source);
   end Enum_declaration_Text;


   function  representation_Text (Self : in ada_Type.view) return String
   is
      the_Source : unbounded_String;

   begin
      if Self.all in ada_Type.composite.a_record.item'Class
      then
         declare
            the_Record : constant ada_Type.composite.a_record.view := ada_Type.composite.a_record.view (Self);
         begin
            if the_Record.contains_bit_Fields
            then
               append (the_Source,
                       NL & NL
                       & "   for " & the_Record.Name & " use" & NL
                       & "      record"                        );

               declare
                  the_Component : access ada_Variable.item'Class;
                  bit_Count     : Natural           := 0;
                  at_Count      : Natural           := 0;
                  First         : Natural;
                  Last          : Natural;
               begin
                  for Each in 1 .. the_Record.component_Count
                  loop
                     the_Component := the_Record.Components (Each);

                     if the_Component.bit_Field /= -1
                     then
                        First     := bit_Count;
                        bit_Count := bit_Count + the_Component.bit_Field;
                        Last      := bit_Count - 1;

                        append (the_Source,  NL & "         " & the_Component.Name & " at ");

                        if the_Record.is_Virtual
                        then
                           append (the_Source,  "system.Storage_Unit ");

                           if at_Count /= 0
                           then
                              append (the_Source,  "+" & Natural'Image (at_Count));
                           end if;
                        else
                           append (the_Source,  Natural'Image (at_Count));
                        end if;


                        append (the_Source,  " range " & Natural'Image (First) & " .. " & Natural'Image (Last) & ";");

                        if bit_Count >= system.word_Size
                        then
                           bit_Count := bit_Count - system.word_Size;                       -- tbd: check these are correct & portable
                           at_Count  := at_Count + system.word_Size / system.storage_Unit;  --
                        end if;

                     else
                        null;
                     end if;
                  end loop;
               end;

               append (the_Source,  NL & "      end record;"               & NL);
            end if;


            if             the_Record.is_Virtual
              and then not the_Record.is_interface_Type
            then
               append (the_Source,  to_String (NL & "   pragma Import (CPP, Entity => " & the_Record.Name & ");" & NL & NL));
            end if;

            return to_String (the_Source);
         end;
      end if;


      return to_String (the_Source);
   end representation_Text;



   function specification_Source (Self                : access ada_Subprogram.item'Class;
                                  declaration_Package : access ada_Package   .item'Class;
                                  using_Name          : in     unbounded_String;
                                  namespace_Prefix    : in     unbounded_String;
                                  the_Gnat_Lang       : access gnat_Language.item) return unbounded_String
   is
      pragma Unreferenced (the_Gnat_Lang);
      use ada_Parameter.Vectors;

      the_Source     :          unbounded_String;

      all_Parameters : constant ada_Parameter.Vector := Self.Parameters;
      num_Parameters : constant Natural              := Natural (all_Parameters.length);
      has_Parameters : constant Boolean              := num_Parameters > 0;

   begin
      append (the_Source,  NL & NL);

      if Self.is_Procedure
      then
         append (the_Source,  "   procedure ");
      else
         append (the_Source,  "   function  ");
      end if;

      append (the_Source, using_Name & " ");

      if has_Parameters
      then
         do_Parameters :
         declare
            parameters_Namespace : a_Namespace.item;
            Cursor               : ada_parameter.Cursor := First (all_Parameters);

         begin
            while has_Element (Cursor)
            loop
               parameters_Namespace.add_Name (Element (Cursor).Name);
               next (Cursor);
            end loop;

            append (the_Source, "(");

            Cursor := First (all_Parameters);

            while has_Element (Cursor)
            loop
               declare
                  the_Parameter          : constant        ada_Parameter.view     := Element (Cursor);
                  parameter_type_Package : constant access ada_Package.item'Class := the_Parameter.my_Type.resolved_Type.declaration_Package;
                  the_Name               : constant        a_namespace.Name_view  := parameters_Namespace.fetch_Name (the_Parameter.Name);
                  the_parameter_Name     :                 unbounded_String       := the_Parameter.Name;
                  name_is_overloaded     : constant        Boolean                := the_name.overload_Count > 1;  -- tbd: overload_Count suggests the number of times a name has been overloaded ... whereas this is the acutal number of times a name has been used
                  the_Mode               :                 unbounded_String;

                  using_access_Mode      : constant        Boolean
                    :=          the_Parameter.my_Type.resolved_Type.all in ada_type.elementary.an_Access.to_Subprogram.item'Class
                       and then to_Lower (the_Parameter.my_Type.resolved_Type.qualified_Name) /= "interfaces.c.strings.chars_ptr";

                  Type_is_from_limited_With : constant Boolean      := declaration_Package.Context.limited_Withs (parameter_type_Package);
                  limited_Pointer_base_Type : ada_Type.view;

                  is_the_self_Parameter : Boolean;


                  function returns_virtual_Class return Boolean
                  is
                  begin
                     if using_access_Mode
                     then
                        declare
                           the_accessed_Type : constant ada_Type.view := ada_Type.elementary.an_access.to_type.view (the_Parameter.my_Type).accessed_Type;
                        begin
                           if the_accessed_Type.declaration_Package.models_a_virtual_cpp_Class
                           then
                              if             the_accessed_Type.all in ada_Type.composite.a_record.item'Class
                                and then not ada_Type.composite.a_record.view (the_accessed_Type).is_interface_Type
                              then
                                 return True;
                              end if;
                           end if;
                        end;
                     end if;

                     return False;
                  end returns_virtual_Class;


               begin
                  if name_is_overloaded
                  then
                     the_name.used_Count := the_name.used_Count + 1;
                     append (the_parameter_Name,  "_" & Image (the_name.used_Count));
                  end if;

                  append (the_Source,  to_ada_Identifier (the_parameter_Name) & " : ");

                  is_the_self_Parameter := False;

                  if         the_Parameter          = Element (First (all_Parameters))     -- is 1st parameter
                    and then the_Parameter.Name     = "Self"                               -- is a class 'Self' parameter
                    and then parameter_type_Package = declaration_Package                  -- (tbd: simpler/clearer to add a flag to gnat_Parameter ?)
                  then
                     if             the_Parameter.my_Type.all in ada_Type.composite.a_record.item'Class
                       and then not ada_Type.composite.a_record.view (the_Parameter.my_Type).is_Virtual
                     then
                        append (the_Mode, "in");        -- for non-virtual C struct's and class's.
                     else
                        is_the_self_Parameter := True;

                        if Self.is_Function
                        then
                           append (the_Mode, "access");
                        else
                           append (the_Mode, "in out");
                        end if;
                     end if;

                  elsif      the_Parameter.is_Pointer
                    and then to_Lower (the_Parameter.my_Type.qualified_Name) /= "interfaces.c.strings.chars_ptr"
                  then
                     if         using_access_Mode
                       and then returns_virtual_Class
                     then
                        append (the_Source,  "in");
                     else
                        append (the_Mode,  "access");
                     end if;

                  else
                     if Type_is_from_limited_With
                     then
                        append (the_Mode,  "access");
                        limited_Pointer_base_Type := Access_to_Type_view (the_Parameter.my_Type.resolved_Type).accessed_Type;
                     else
                        append (the_Mode,  "in"); -- "access");
                     end if;
                  end if;

                  append (the_Source,  the_Mode & " ");


                  if declaration_Package.type_name_needs_Standard_prefix (to_String (the_parameter_Name),
                                                                          the_Parameter.my_Type.resolved_Type)
                  then
                     if namespace_Prefix = ""
                     then
                        append (the_Source,  "standard.");
                     else
                        append (the_Source,  namespace_Prefix);
                     end if;
                  end if;


                  if         the_Parameter.my_Type.all in ada_type.elementary.an_Access.to_Type.item'Class
                    and then to_Lower (the_Parameter.my_Type.qualified_Name) /= "interfaces.c.strings.chars_ptr"
                  then
                     if using_access_Mode
                     then
                        if returns_virtual_Class
                        then
                           append (the_Source,  qualified_Name (ada_Type.elementary.an_access.to_type.view (the_Parameter.my_Type.resolved_Type).accessed_Type.declaration_Package) & "_Pointer");
                        else
                           append (the_Source,  qualified_Name (ada_Type.elementary.an_access.to_type.view (the_Parameter.my_Type.resolved_Type).accessed_Type));
                        end if;
                     else
                        append (the_Source, qualified_Name (the_Parameter.my_Type.resolved_Type));
                     end if;

                  else
                     if limited_Pointer_base_Type = null
                     then
                        append (the_Source,  the_Parameter.my_Type.qualified_Name);
                     else
                        append (the_Source,  limited_Pointer_base_Type.qualified_Name);
                     end if;
                  end if;

                  if        is_the_self_Parameter
                    and not Self.is_Virtual
                  then
                     append (the_Source,  "'Class");
                  end if;


                  if Cursor /= Last (all_Parameters)
                  then
                     append (the_Source,  ";" & NL);
                  end if;
               end;

               next (Cursor);
            end loop;

            append (the_Source, ")");
         end do_Parameters;
      end if;


      if Self.is_Function
      then
         declare
            return_type_Package   : constant access ada_Package.item'Class := Self.return_Type.resolved_Type.declaration_Package;
            using_access_Mode     : constant        Boolean                :=          Self.return_Type.all in ada_type.elementary.an_Access.to_Type.item'Class
                                                                              and then to_Lower (Self.return_Type.qualified_Name) /= "interfaces.c.strings.chars_ptr";
            function returns_virtual_Class return Boolean
            is
            begin
               if         using_access_Mode
                 and then Self.return_Type.all in ada_Type.elementary.an_access.to_type.item'Class
               then
                  declare
                     the_accessed_Type : constant ada_Type.view := ada_Type.elementary.an_access.to_type.view (Self.return_Type).accessed_Type;
                  begin
                     if the_accessed_Type.declaration_Package.models_a_virtual_cpp_Class
                     then
                        if         the_accessed_Type.all in ada_Type.composite.a_record.item'Class
                          and then not ada_Type.composite.a_record.view (the_accessed_Type).is_interface_Type
                        then
                           return True;
                        end if;
                     end if;
                  end;
               end if;

               return False;
            end returns_virtual_Class;

         begin
            append (the_Source, " return ");

            if         using_access_Mode
              and then not returns_virtual_Class
            then
               append (the_Source,  " access ");
            end if;


            if declaration_Package.type_name_needs_Standard_prefix ("",  Self.return_Type.resolved_Type)
            then
               if namespace_Prefix = ""
               then
                  append (the_Source,  "standard.");
               else
                  append (the_Source,  namespace_Prefix);
               end if;
            end if;


            if using_access_Mode
            then
               if returns_virtual_Class
               then
                  append (the_Source,
                          qualified_Name (ada_Type.elementary.an_access.to_type.view (Self.return_Type.resolved_Type).accessed_Type.declaration_Package) & "_Pointer");
               else
                  append (the_Source,
                          qualified_Name (ada_Type.elementary.an_access.to_type.view (Self.return_Type.resolved_Type).accessed_Type));
               end if;
            else
               append (the_Source,
                       qualified_Name (Self.return_Type)); -- .resolved_Type));
            end if;


            if         return_type_Package.cpp_class_Type /= null
              and then return_type_Package.cpp_class_Type.all'Access = Self.return_Type   -- The return type is the main type of a class package.
              and then return_type_Package.cpp_class_Type.is_Virtual
              and then return_type_Package /= declaration_Package                         -- The return type is not the main type of the functions package.
            then
               append (the_Source,  "'Class");
            end if;
         end;
      end if;


      if Self.is_Abstract
      then
         append (the_Source,  " is abstract");
      end if;

      return the_Source;
   end specification_Source;



   function declaration_Text (Self : ada_Type.view;   the_Gnat_Lang : access gnat_Language.item) return String
   is
      the_Source : unbounded_String;

   begin
      if Self.all in ic_Pointer_Class
      then
         return "";

      elsif Self.all in ada_Type.elementary.an_Access.to_subProgram.item'Class
      then
         declare
            My : constant ada_Type.elementary.an_Access.to_subProgram.view := ada_Type.elementary.an_Access.to_subProgram.view (Self);
         begin
            append (the_Source,  "   type " & my.Name & " is access ");
            append (the_Source,  specification_Source (Self                => my.accessed_subProgram,
                                                       declaration_package => my.declaration_Package,
                                                       using_Name          => null_unbounded_String,
                                                       namespace_Prefix    => null_unbounded_String,
                                                       the_gnat_lang       => the_gnat_lang));
            append (the_Source,  ";");
            append (the_Source,  to_String (NL & "pragma convention (C, " & Self.Name & ");"));
         end;

      elsif Self.all in ada_Type.composite.an_array.item'Class
      then
         declare
            My : constant ada_Type.composite.an_array.view := ada_Type.composite.an_array.view (Self);
         begin
            append (the_Source,  "   type " & my.Name & " is array (");

            for Each in 1 .. my.array_dimension_Count
            loop
               if Each > 1
               then
                  append (the_Source,  ",");
               end if;

               if my.array_Dimensions_upper_Bound (Each)  =  -1
               then
                  append (the_Source,  "interfaces.C.Size_t range <>");
               else
                  append (the_Source,  "interfaces.C.Size_t range 0 .. " & Image (my.array_Dimensions_upper_Bound (Each)));
               end if;
            end loop;

            append (the_Source,  ") of aliased " & qualified_Name (my.element_Type) & ";");
         end;


      elsif Self.all in ada_Type.elementary.an_access.to_type.item'Class
      then
         declare
            Self : constant ada_Type.elementary.an_access.to_type.view := ada_Type.elementary.an_access.to_type.view (declaration_text.Self);
         begin
            if         Self.accessed_Type.all in ada_Type.composite.a_record.item'Class             -- add forward declaration of a class type,
              and then depends_on (Self.accessed_Type,  ada_Type.view (Self),  the_Gnat_Lang)       -- if that is what we reference
            then
               append (the_Source, "   type " & Self.accessed_Type.Name & ";" & NL & NL);    --
            end if;

            append (the_Source,  "   type " & Self.Name & " is access all "  &  Self.accessed_Type.qualified_Name);

            if         Self.accessed_Type.all in  ada_Type.composite.a_record.item'Class
              and then ada_Type.composite.a_record.view (Self.accessed_Type).is_tagged_Type
            then
               append (the_Source,  "'KKK_Class ");
            end if;

            append (the_Source,  ";");
         end;


      elsif Self.all in ada_Type.composite.a_record.item'Class
      then
         declare
            Self : constant ada_Type.composite.a_record.view := ada_Type.composite.a_record.view (declaration_text.Self);
         begin
            return ada_Record_private_declaration_Text (Self);
         end;


      elsif Self.all in ada_Type.elementary.scalar.discrete.enumeration.item'Class
      then
         declare
            Self : constant ada_Type.elementary.scalar.discrete.enumeration.view := ada_Type.elementary.scalar.discrete.enumeration.view (declaration_text.Self);
         begin
            return Enum_declaration_Text (Self);
         end;


      elsif Self.all in ada_Type.a_subType.item'Class
      then
         declare
            Self : constant ada_Type.a_subType.view := ada_Type.a_subType.view (declaration_text.Self);
         begin
            if Self.base_Type.all in ic_Pointer_class
            then
               return to_String ("   type "     &  Self.Name  &  " is access all " & ic_Pointer_view (Self.base_Type).accessed_Type.qualified_Name & ";");
            else
               return to_String ("   subtype "  &  Self.Name  &  " is "            &  Self.base_Type.qualified_Name   &  ";");
            end if;
         end;
      end if;

      return to_String (the_Source);
   end declaration_Text;




   function overload_resolution_Source (Self                 : access ada_subprogram.Item'Class;
                                        declaration_Package  : access ada_Package.item'Class;
                                        unique_function_Name : in     unbounded_String;
                                        namespace_Prefix     : in     unbounded_String;
                                        the_gnat_lang        : access gnat_language.item) return unbounded_String
   is
      the_Source : unbounded_String;

   begin
      --  the 'overloaded subprogram' with a unique name, which is actually imported from 'C'.
      --
      append (the_Source,  specification_Source (Self => Self,
                                                 declaration_package => declaration_Package,
                                                 using_name          => unique_function_Name,
                                                 namespace_Prefix    => namespace_Prefix,
                                                 the_gnat_lang => the_gnat_lang));
      append (the_Source,  ";" & NL & NL);


      --  provide body for public subprogram spec, by renaming the 'overloaded subprogram' with the unique name.
      --

      append (the_Source,  specification_Source (Self => Self,
                                                 declaration_package => declaration_Package,
                                                 using_name          => Self.Name,
                                                 namespace_Prefix    => namespace_Prefix,
                                                 the_gnat_lang => the_gnat_lang));

      append (the_Source,  NL & "   renames " & unique_function_Name & ";" & NL & NL);



      return the_Source;
   end overload_resolution_Source;



   procedure emit_Spec (the_Package   : access ada_Package.item'Class;
                        in_cpp_Mode   : in     Boolean;
                        the_Gnat_Lang : access gnat_Language.item)
   is
      use ada_subprogram.Vectors,
          ada_Type      .Vectors,
          ada_variable  .Vectors;

      all_Variables       : constant ada_variable.Vector   := the_Package.Variables;
      all_Subprograms     : constant ada_subprogram.Vector := the_Package.Subprograms;

      all_Types           : constant ada_Type.Vector       := the_Package.Types;
      main_Types          :          ada_Type.Vector;
      ic_pointer_Types    :          ada_Type.Vector;


      spec_Source         :          unbounded_String;
      spec_Source_private :          unbounded_String;

      use_of_iC_Int_type_Required                 : Boolean  := False;     -- 'use type interfaces.c.Int;' is required for variables with explicit signed values.
      use_of_iC_signed_Char_type_Required         : Boolean  := False;     -- ditto
      use_of_iC_unsigned_Char_type_Required       : Boolean  := False;     -- ditto
      use_of_iC_unsigned_Short_type_Required      : Boolean  := False;     -- ditto
      use_of_iC_Size_t_type_Required              : Boolean  := False;     -- ditto
      use_of_iC_Unsigned_type_Required            : Boolean  := False;     -- ditto
      use_of_iC_Long_type_Required                : Boolean  := False;     -- ditto
      use_of_iC_Double_type_Required              : Boolean  := False;     -- ditto
      use_of_iC_long_Double_type_Required         : Boolean  := False;     -- ditto
      use_of_iCe_long_Long_type_Required          : Boolean  := False;     -- ditto
      use_of_iCe_unsigned_long_Long_type_Required : Boolean  := False;     -- ditto

   begin
      log ("'emit_Spec' -    package name: '" & the_Package.qualified_Name & "'");

      if the_Package.is_Core then
         return;
      end if;


      --  Separate types.
      --
      declare
         the_Type : ada_Type.view;
         Cursor   : ada_Type.Cursor := all_Types.First;
      begin
         while has_Element (Cursor)
         loop
            the_Type := Element (Cursor);

            if         the_Package.models_a_virtual_cpp_Class
              and then (
                        the_Type.all in ic_Pointer_Class

                        or else (         the_Type.all in ada_Type.a_subType.item'Class
                                 and then ada_type.a_subType.view (the_Type).base_Type.all in ic_Pointer_Class)

                        or else (         the_Type.all in an_array_class
                                 and then an_array_view (the_Type).element_Type.all in ada_Type.a_subType.item'Class
                                 and then ada_type.a_subType.view (an_array_view (the_Type).element_Type).base_Type.all in ic_Pointer_Class)
                       )
            then
               ic_pointer_Types.append (the_Type);
            else
               main_Types.append (the_Type);
            end if;

            next (Cursor);
         end loop;
      end;

      append (spec_Source,  "-- This file is generated by SWIG. Please do *not* modify by hand." & NL &
                            "--"                                                                 & NL);

      emit_Withs :
      declare
         the_Context                              :          ada_Context.item renames the_Package.Context.all;
         with_of_swig_Required                    :          Boolean          := False;        -- Used for special case where variable of i.c.char_Array is transformed to a Swig.indefinate_char_Array.
         with_of_interfaces_c_extensions_Required : constant Boolean          := False;        -- Ditto, but for opaque stucts and incomplete classes.
         with_of_interfaces_c_Required            :          Boolean          := True;

         the_Subprogram                           :          ada_Subprogram.view;

      begin
         for Each in 1 .. Natural (Length (all_Subprograms))
         loop
            the_Subprogram := Element (all_Subprograms,  Each);

            declare  -- Add parameters.
               use ada_Parameter.Vectors;

               all_Parameters : constant ada_Parameter.Vector := the_Subprogram.Parameters;
               Cursor         :          ada_Parameter.Cursor := all_Parameters.First;

               the_Parameter  :          ada_Parameter.view;

            begin
               while has_Element (Cursor)
               loop
                  the_Parameter := Element (Cursor);

                  if    the_Parameter.is_Pointer
                    and the_Parameter.my_Type.all in ada_type.composite.a_Record.item'Class
                  then
                     the_Context.add (the_Parameter.my_Type,
                                      is_access => True);

                  elsif the_Parameter.my_Type.all in ada_type.elementary.an_Access.to_Type.item'Class
                    and the_Parameter.my_Type.qualified_Name /= "interfaces.c.strings.chars_ptr"
                  then
                     the_Context.add (ada_Type.elementary.an_Access.to_Type.view (the_Parameter.my_Type).accessed_Type,
                                      is_access => True);
                  else
                     the_Context.add (the_Parameter.my_Type,
                                      is_access => False);
                  end if;

                  next (Cursor);
               end loop;
            end;


            if the_Subprogram.is_Function
            then   -- Add return type to context.
               declare
                  the_return_Type : constant ada_Type.view := the_Subprogram.return_Type;
               begin
                  if    the_return_Type.all in ada_type.elementary.an_Access.to_Type.item'Class
                    and the_return_Type.qualified_Name /= "interfaces.c.strings.chars_ptr"
                  then
                     the_Context.add (ada_Type.elementary.an_access.to_type.view (the_Subprogram.return_Type).accessed_Type,
                                      is_access => True);
                  else
                     the_Context.add (the_Subprogram.return_Type,
                                      is_access => False);
                  end if;
               end;
            end if;

         end loop;


         for Each in 1 .. Natural (Length (all_Variables))
         loop
            declare
               the_Variable : constant ada_Variable.view := Element (all_Variables,  Each);
            begin
               the_Context.add (the_Variable.my_Type);

               if the_Variable.my_Type.resolved_Type.qualified_Name = "interfaces.c.char_Array"
               then
                  with_of_swig_Required := True;
               end if;

               if        Index (the_Variable.Value,  "+")  /= 0
                 or else Index (the_Variable.Value,  "-")  /= 0
                 or else Index (the_Variable.Value,  "*")  /= 0
                 or else Index (the_Variable.Value,  "/")  /= 0
                 or else Index (the_Variable.Value,  "**") /= 0
               then
                  if    the_Variable.my_Type.resolved_Type.qualified_Name = "interfaces.c.Int" then
                     use_of_iC_Int_type_Required                 := True;

                  elsif the_Variable.my_Type.resolved_Type.qualified_Name = "interfaces.c.signed_Char" then
                     use_of_iC_signed_Char_type_Required         := True;

                  elsif the_Variable.my_Type.resolved_Type.qualified_Name = "interfaces.c.unsigned_Char" then
                     use_of_iC_unsigned_Char_type_Required       := True;

                  elsif the_Variable.my_Type.resolved_Type.qualified_Name = "interfaces.c.unsigned_Short" then
                     use_of_iC_unsigned_Short_type_Required      := True;

                  elsif the_Variable.my_Type.resolved_Type.qualified_Name = "interfaces.c.Size_t" then
                     use_of_iC_Size_t_type_Required              := True;

                  elsif the_Variable.my_Type.resolved_Type.qualified_Name = "interfaces.c.Unsigned" then
                     use_of_iC_Unsigned_type_Required            := True;

                  elsif the_Variable.my_Type.resolved_Type.qualified_Name = "interfaces.c.long" then
                     use_of_iC_Long_type_Required                := True;

                  elsif the_Variable.my_Type.resolved_Type.qualified_Name = "interfaces.c.Double" then
                     use_of_iC_Double_type_Required              := True;

                  elsif the_Variable.my_Type.resolved_Type.qualified_Name = "interfaces.c.long_Double" then
                     use_of_iC_long_Double_type_Required         := True;

                  elsif the_Variable.my_Type.resolved_Type.qualified_Name = "swig.long_Long" then
                     use_of_iCe_long_Long_type_Required          := True;

                  elsif the_Variable.my_Type.resolved_Type.qualified_Name = "swig.unsigned_long_Long" then
                     use_of_iCe_unsigned_long_Long_type_Required := True;
                  end if;
               end if;
            end;
         end loop;


         for Each in 1 .. Natural (Length (all_Types))
         loop
            declare
               the_Type : constant ada_Type.view := Element (all_Types,  Each);
            begin
               if the_Type.all in ada_Type.composite.a_Record.item'Class
               then
                  declare
                     the_record_Type    : constant ada_Type.composite.a_record.view := a_Record_view (the_Type);
                     the_component_Type :          ada_Type.view;
                  begin
                     for Each in 1 .. the_record_Type.component_Count
                     loop
                        the_component_Type := the_record_Type.Components (Each).my_Type;

                        if not (         the_component_Type.all in subType_class                                      -- ignore Self referential pointer
                                and then                      subType_view (the_component_Type).base_Type.all            in Access_to_Type_class
                                and then Access_to_Type_view (subType_view (the_component_Type).base_Type).accessed_Type =  the_record_Type.all'Access)
                        then
                           if         the_component_Type.all                          in subType_class                -- ignore Self referential pointer
                             and then subType_view (the_component_Type).base_Type.all in Access_to_Type_class
                           then
                              the_Context.add (Access_to_Type_view (subType_view (the_component_Type).base_Type).accessed_Type,
                                               is_access => True);
                           else
                              the_Context.add (the_component_Type);
                           end if;
                        end if;
                     end loop;

                     declare
                        the_Bases : constant ada_Type.Vector := the_record_Type.base_Classes;
                        Cursor    :          ada_Type.Cursor := the_Bases.First;
                     begin
                        while has_Element (Cursor)
                        loop
                           the_Context.add (Element (Cursor));
                           next (Cursor);
                        end loop;
                     end;

                     with_of_interfaces_c_Required := True;     -- For class array index type.
                  end;

               else
                  the_Context.add (the_Type.context_required_Types);
               end if;
            end;
         end loop;


         if the_Package.cpp_class_Type /= null
         then
            declare
               the_base_Classes : constant ada_Type.vector := the_Package.cpp_class_Type.base_Classes;
            begin
               for Each in 1 .. Natural (Length (the_base_Classes))
               loop
                  the_Context.add (Element (the_base_Classes, Each),
                                   is_access => False);
               end loop;
            end;
         end if;

         append (spec_Source, to_Source (the_Context,
                                         the_Package.all'Access,
                                         null_unbounded_String));

         if with_of_swig_Required
         then   -- Ensure Swig is with'ed in case of i.c.char_Array to Swig.indefinate_Arrsy transformation.
            append (spec_Source,   "with Swig;" &  NL);                          -- tbd: may result in a redundant withing of 'Swig' package.
         end if;

         if with_of_interfaces_c_extensions_Required
         then   -- Ensure interfaces.C.extensions is with'ed in case of opaque struct's or imcomplete classes.
            append (spec_Source,   "with interfaces.C.extensions;" &  NL);       -- tbd: may result in a redundant withing of package.
         end if;

         if with_of_interfaces_c_Required
         then
            append (spec_Source,   "with interfaces.C;" &  NL);
         end if;

         if             the_Package.models_a_virtual_cpp_Class
           and then not the_Package.models_an_interface_Type
         then
            append (spec_Source,   "with System;" &  NL);
            append (spec_Source,   "private with system.Address_To_Access_Conversions;" &  NL);
         end if;

      end emit_Withs;


      -- Emit package specification.
      --
      append (spec_Source,   NL & NL & NL);

      -- tbd: This 'if' does nothing !
      --
      if the_Package.is_global_Namespace then
         append (spec_Source,   "package " & the_Package.qualified_Name & " is" & NL & NL);
      else
         append (spec_Source,   "package " & the_Package.qualified_Name & " is" & NL & NL);
         --  append (spec_Source,   "package " & namespace_Prefix & Self.qualified_Name & " is" & NL & NL);
      end if;


      --  Emit main types.
      --
      emit_main_Types :
      declare
         the_Type    : ada_Type.view;
      begin
         sort_Types_by_dependence:
         declare
            is_Sorted   : Boolean := False;

            Cursor      : ada_Type.Cursor := First (main_Types);
            test_Cursor : ada_Type.Cursor;

            the_Type    : ada_Type.view;

            type swap_Pair is
               record
                  Type_1 : ada_Type.view;
                  Type_2 : ada_Type.view;
               end record;

            function Hashed (the_Pair : swap_Pair) return ada.Containers.Hash_Type
            is
               function to_Hash is new ada.Unchecked_Conversion (ada_Type.view, ada.Containers.Hash_Type);
               use type ada.Containers.Hash_Type;
            begin
               return to_Hash (the_Pair.Type_1) + to_Hash (the_Pair.Type_2);
            end Hashed;

            function is_Equivalent (L, R : swap_Pair) return Boolean
            is
            begin
               return (    L.Type_1 = R.Type_1
                       and L.Type_2 = R.Type_2)
                 or  (     L.Type_1 = R.Type_2
                       and L.Type_2 = R.Type_1);
            end is_Equivalent;


            package swap_pair_Sets is new ada.Containers.Hashed_Sets (Element_Type        => swap_Pair,
                                                                      Hash                => Hashed,
                                                                      Equivalent_Elements => is_Equivalent,
                                                                      "="                 => "=");
            already_Swapped : swap_pair_Sets.Set;

         begin
            while     has_Element (Cursor)
              and not is_Sorted
            loop
               primary:
               while has_Element (Cursor)
               loop
                  the_Type    := Element (Cursor);
                  test_Cursor := next (Cursor);

                  while has_Element (test_Cursor)
                  loop
                     if     not already_Swapped.Contains ((the_Type,  Element (test_Cursor)))
                       and then the_Type.depends_directly_on (Element (test_Cursor), depth => 0)
                     then
                        already_Swapped.insert ((the_Type,  Element (test_Cursor)));
                        swap (main_Types,  Cursor, test_Cursor);

                        Cursor := First (main_Types);
                        exit primary;
                     end if;

                     next (test_Cursor);
                  end loop;

                  next (Cursor);

                  if not has_Element (Cursor)
                  then   -- Sorting is complete.
                     is_Sorted := True;
                  end if;
               end loop primary;
            end loop;
         end sort_types_by_dependence;


         for Each in 1 .. Natural (Length (main_Types))
         loop
            the_Type := Element (main_Types,  Each);

            if not (          the_Type.all in an_array_class                                                                              -- ignore any array types whose
                    and then (        (         an_array_view (the_Type).element_Type.all in a_Record_class         -- = c_Class       -- element type is a C class and which
                                       and then a_record_view (an_array_view (the_Type).element_Type).pure_virtual_member_function_Count > 0      )      -- is abstract, or whose
                              or else (         an_array_view (the_Type).element_Type.all in an_Array_class                               -- element type is an array, which
                                       and then an_array_view (an_array_view (the_Type).element_Type).is_Unconstrained        )      ))   -- is unconstrained.
            then
               if not (        Tail (the_Type.Name, 5) = "_view"
                       or else Tail (the_Type.Name, 6) = "_array"
                       or else the_Type.all in ic_Pointer_Class)
               then
                  append (spec_Source, "   -- " & the_Type.Name       & NL);
                  append (spec_Source, "   -- "                       & NL);
               end if;

               append (spec_Source,  declaration_Text (the_Type, the_Gnat_Lang) & NL & NL);

               declare
                  the_representation_Text : constant String := representation_Text (the_Type);
               begin
                  if the_representation_Text /= ""
                  then
                     append (spec_Source,  the_representation_Text & NL & NL & NL);
                  end if;
               end;
            end if;
         end loop;

      end emit_main_Types;


      --  emit variables  -- tbd: shift the bulk of below code to a 'declaration_Text' & 'pragma_Import_Text' functions in gnat_Variable ?
      --

      append (spec_Source,  NL & NL & NL);

      if use_of_iC_Int_type_Required                 then   append (spec_Source,  "   use type interfaces.C.int;"                           & NL & NL);   end if;
      if use_of_iC_signed_Char_type_Required         then   append (spec_Source,  "   use type interfaces.C.signed_Char;"                   & NL & NL);   end if;
      if use_of_iC_unsigned_Char_type_Required       then   append (spec_Source,  "   use type interfaces.C.unsigned_Char;"                 & NL & NL);   end if;
      if use_of_iC_unsigned_Short_type_Required      then   append (spec_Source,  "   use type interfaces.C.unsigned_Short;"                & NL & NL);   end if;
      if use_of_iC_Size_t_type_Required              then   append (spec_Source,  "   use type interfaces.C.Size_t;"                        & NL & NL);   end if;
      if use_of_iC_Unsigned_type_Required            then   append (spec_Source,  "   use type interfaces.C.Unsigned;"                      & NL & NL);   end if;
      if use_of_iC_Long_type_Required                then   append (spec_Source,  "   use type interfaces.C.Long;"                          & NL & NL);   end if;
      if use_of_iC_Double_type_Required              then   append (spec_Source,  "   use type interfaces.C.Double;"                        & NL & NL);   end if;
      if use_of_iC_long_Double_type_Required         then   append (spec_Source,  "   use type interfaces.C.long_Double;"                   & NL & NL);   end if;
      if use_of_iCe_long_Long_type_Required          then   append (spec_Source,  "   use type interfaces.c.extensions.long_Long;"          & NL & NL);   end if;
      if use_of_iCe_unsigned_long_Long_type_Required then   append (spec_Source,  "   use type interfaces.c.extensions.unsigned_long_Long;" & NL & NL);   end if;


      for Each in 1 .. Natural (Length (all_Variables))
      loop
         declare
            use ada_Variable.array_bounds_Vectors,
                ada.Containers;

            the_Variable : constant ada_Variable.view      := Element (all_Variables,  Each);

         begin
            verify (the_Variable);

            append (spec_Source,  NL & "   " & to_ada_Identifier (the_variable.Name) & " : ");


            if         the_Variable.is_Constant
              and then the_Variable.my_Type = the_Gnat_Lang.name_Map_of_ada_Type.Element (+"interfaces.c.int")
              and then the_Variable.Value  /= ""
            then
               append (spec_Source,  "constant ");

            else
               append (spec_Source,  "aliased ");

               if the_Variable.is_Constant
               then
                  append (spec_Source,  "constant ");
               end if;

               if    the_Variable.is_Pointer
                 and the_Variable.my_Type.resolved_Type.all in ada_type.elementary.scalar.discrete.enumeration.item'Class
               then
                  append (spec_Source,  " access ");
               end if;


               if  the_Variable.is_class_Pointer
               then
                  if        the_Variable.my_Type.resolved_Type.all in ada_type.elementary.scalar.discrete.enumeration.item'Class
                    or else (    to_Lower (the_Variable.my_Type.qualified_Name) /= "interfaces.c.strings.chars_ptr"
                             and the_Variable.my_Type.resolved_Type.all not in ada_type.elementary.an_access.to_subprogram.item'Class)
                  then
                     append (spec_Source,  " access ");
                  end if;
               end if;


               if the_Package.type_name_needs_Standard_prefix (to_String (the_Variable.Name),
                                                        the_Variable.my_Type.resolved_Type)
               then
                  append (spec_Source,  "standard.");
               end if;


               if         the_Variable.my_Type.all in ada_type.elementary.an_access.to_type.item'Class
                 and then to_Lower (the_Variable.my_Type.qualified_Name) /= "interfaces.c.strings.chars_ptr"
               then
                  append (spec_Source,  ada_Type.elementary.an_access.to_type.view (the_Variable.my_Type).accessed_Type.resolved_Type.qualified_Name);
               else
                  append (spec_Source,  the_Variable.my_Type.qualified_Name);
               end if;


               if not is_Empty (the_variable.array_Bounds)
               then
                  append (spec_Source, " (");

                  for Each in 1 .. Integer (Length (the_variable.array_Bounds))
                  loop
                     if Each > 1
                     then
                        append (spec_Source, ",");
                     end if;

                     if Element (the_variable.array_Bounds, Each) = -1
                     then
                        append (spec_Source, "0 .. swig.indefinite_array_Last");
                     else
                        append (spec_Source, "0 .." & Natural'Image (Element (the_variable.array_Bounds, Each)));
                     end if;
                  end loop;

                  append (spec_Source, ")");
               end if;
            end if;


            if the_Variable.is_Constant
            then
               if the_Variable.my_Type.resolved_Type.qualified_Name = "interfaces.c.strings.chars_ptr"
               then
                  append (spec_Source,  " := interfaces.c.strings.new_String (""" & the_Variable.Value & """)");

               elsif Index (the_Variable.Value, "interfaces.c.char'Val (") /= 0
               then
                  append (spec_Source,  " := " & the_Variable.Value);

               elsif the_Variable.my_Type.resolved_Type.qualified_Name = "Character"
               then
                  append (spec_Source,  " := '" & the_Variable.Value & "'");

               elsif the_Variable.my_Type.qualified_Name = "swig.bool"
               then
                  if the_Variable.Value = "false"
                  then
                     append (spec_Source,  " := 0");
                  else
                     append (spec_Source,  " := 1");
                  end if;

               else
                  if the_variable.my_Type.resolved_Type.is_ultimately_Unsigned
                  then
                     replace_All (the_Variable.Value, "U", "");          -- tbd: do we need a 'u' replace also ??
                  end if;

                  append (spec_Source,  " := " & the_Variable.Value);
               end if;
            end if;

            append (spec_Source,  ";");


            if not the_Variable.is_Constant
            then
               emit_import_Pragma :
               declare

                  function import_Convention return String
                  is
                  begin
                     if in_cpp_Mode then return "CPP";
                     else return "C";
                     end if;
                  end import_Convention;


                  function link_Symbol return unbounded_String
                  is
                  begin
                     if in_cpp_Mode
                     then                               -- tbd: need to use proper storage class ?
                        if the_Package.is_Module
                        then
                           return the_Variable.Name;
                        else
                           return "_ZN" & Image (Length (the_Package.Name))  & the_Package.Name
                             & Image (Length (the_Variable.Name)) & to_String (the_Variable.Name) & "E";
                        end if;

                     else
                        return the_Variable.Name;
                     end if;
                  end link_Symbol;

               begin
                  append (spec_Source_private,   NL & "   pragma import (" & import_Convention & ", "
                          & to_ada_Identifier (the_variable.Name) & ", """ & link_Symbol & """);");
               end emit_import_Pragma;
            end if;
         end;
      end loop;


      emit_Subprograms :
      declare
         functions_Namespace : a_Namespace.item;
         Cursor              : ada_subprogram.Cursor := First (all_Subprograms);

      begin
         while has_Element (Cursor)
         loop
            functions_Namespace.add_Name (Element (Cursor).Name);                -- build functions 'namespace' to help with overloading
            next (Cursor);
         end loop;

         Cursor := First (all_Subprograms);

         while has_Element (Cursor)
         loop
            declare
               the_Subprogram : constant ada_Subprogram.view := Element (Cursor);
            begin
               if the_Subprogram.is_to_view_Conversion
               then
                  log ("emit to view conversion subprog: '" & the_Subprogram.Name & "'");
                  declare
                     class_Type : constant ada_Type.view := the_Subprogram.return_Type;
                     class_Name : constant String         := to_String (class_Type.declaration_Package.Name);
                  begin
                     append (spec_Source,   "   function to_View    (Self : in " & class_Name & "_Pointer) return " & class_Name & ".view;"       & NL);
                  end;

               elsif the_Subprogram.is_to_pointer_Conversion
               then
                  log ("emit to pointer conversion subprog: '" & the_Subprogram.Name & "'");
                  declare
                     class_Type : constant ada_Type.view := the_Subprogram.Parameters.Element (1).my_Type;
                     class_Name : constant String        := to_String (class_Type.declaration_Package.Name);
                  begin
                     append (spec_Source,   "   function to_Pointer (Self : in " & class_Name & ".view)    return " & class_Name & "_Pointer;"       & NL);
                  end;

               else
                  declare
                     the_Name             : constant a_namespace.Name_view := functions_Namespace.fetch_Name (the_Subprogram.Name);
                     is_overloaded        : constant Boolean               := the_Name.overload_Count > 1   and then   not the_Subprogram.is_Abstract;

                     unique_function_Name :          unbounded_String;
                  begin
                     if the_Subprogram.is_Destructor
                     then
                        put_Line ("DESTUCTOR ************************");
                     end if;


                     if         the_Subprogram.access_Mode /= ada_subProgram.private_Access
                       and not (         the_Subprogram.is_Destructor
                                and then is_interface_Type (the_Package.cpp_class_Type))    -- tbd: destructors and interface types together upsets vTable.
                     then
                        if is_overloaded
                        then
                           the_name.used_Count  := the_name.used_Count + 1;
                           unique_function_Name := the_Subprogram.Name & "_v" & Image (the_Name.used_Count);
                        else
                           unique_function_Name := the_Subprogram.Name;
                        end if;

                        append (spec_Source,  specification_Source (Self                => the_Subprogram,
                                                                    declaration_package => the_Package.all'Access,
                                                                    using_name          => the_Subprogram.Name,
                                                                    namespace_Prefix    => null_unbounded_String,
                                                                    the_gnat_lang       => the_gnat_lang));
                        append (spec_Source,  ";");

                        if is_overloaded
                        then
                           append (spec_Source_private,  overload_resolution_Source (Self => the_Subprogram,
                                                                                     declaration_package  => the_Package.all'Access,
                                                                                     unique_function_name => unique_function_Name,
                                                                                     namespace_Prefix     => null_unbounded_String,
                                                                                     the_gnat_lang => the_gnat_lang));
                        end if;

                        append (spec_Source_private,  the_Subprogram.pragma_import_Source (declaration_package  => the_Package.all'Access,
                                                                                           unique_function_name => unique_function_Name,
                                                                                           in_cpp_Mode          => in_cpp_Mode));
                     end if;
                  end;
               end if;
            end;

            next (Cursor);
         end loop;

         append (spec_Source,   NL & NL & NL & NL);
      end emit_Subprograms;


      emit_ic_pointer_Types :
      declare
         the_Type    : ada_Type.view;
      begin
         for Each in 1 .. Natural (Length (ic_pointer_Types))
         loop
            the_Type := Element (ic_pointer_Types,  Each);

            declare
               subtype an_Array_view  is ada_Type.composite.an_array.view;
               subtype an_Array_class is ada_Type.composite.an_array.item'Class;

               subtype a_Record_view  is ada_Type.composite.a_record.view;
               subtype a_Record_class is ada_Type.composite.a_record.item'Class;
            begin
               if not (          the_Type.all in an_array_class                                                                              -- ignore any array types whose
                       and then (        (         an_array_view (the_Type).element_Type.all in a_record_class                               -- element type is a C class and which
                                          and then a_record_view (an_array_view (the_Type).element_Type).pure_virtual_member_function_Count > 0      )      -- is abstract, or whose
                                 or else (         an_array_view (the_Type).element_Type.all in an_array_class                               -- element type is an array, which
                                          and then an_array_view (an_array_view (the_Type).element_Type).is_Unconstrained        )      ))   -- is unconstrained.
               then
                  if not (        Tail (the_Type.Name, 5) = "_view"
                          or else Tail (the_Type.Name, 6) = "_array"
                          or else the_Type.all in ic_Pointer_Class)
                  then
                     append (spec_Source,          "   -- " & the_Type.Name       & NL);
                     append (spec_Source,          "   -- "                       & NL);
                  end if;

                  append (spec_Source,  declaration_Text (the_Type, the_Gnat_Lang) & NL & NL);

                  declare
                     the_representation_Text : constant String := representation_Text (the_Type);
                  begin
                     if the_representation_Text /= ""
                     then
                        append (spec_Source_private,  the_representation_Text & NL & NL & NL);
                     end if;
                  end;
               end if;
            end;

         end loop;
      end emit_ic_pointer_Types;


      if             the_Package.models_a_virtual_cpp_Class
        and then not the_Package.models_an_interface_Type
        and then not the_Package.cpp_class_Type.is_Abstract
      then
         append (spec_Source_private,   NL & NL & NL & "   package conversions is new System.Address_To_Access_Conversions (Item);" &  NL);
      end if;


      if spec_Source_private /= ""
      then
         append (spec_Source,   NL & NL & NL & NL & NL & NL
                              & "private"
                              & NL & NL & NL
                              & spec_Source_private
                              & NL & NL);
      end if;

      append (spec_Source,  NL & NL & "end " & the_Package.qualified_Name & ";");

      write_the_File :
      declare
         output_directory : unbounded_String := +SWIG_output_directory;
         lowcase_Name     : unbounded_String;
         the_File         : ada.text_io.File_type;

      begin
         if output_directory = ""
         then
            append (output_directory,  ".");
         end if;

         append (lowcase_Name,  the_Package.qualified_Name);

         translate   (lowcase_Name,  lower_case_Map);
         replace_All (lowcase_Name,  ".",  "-");

         declare
            file_Name : constant String := to_String (output_Directory & "/" & lowcase_Name & ".ads");
         begin
            create (the_File,  out_File,  file_Name);
            put    (the_File,  to_String (spec_Source));
            close  (the_File);
         exception
            when others => log (+"unable to create package file: '" & file_Name & "'");
         end;
      end write_the_File;
   end emit_Spec;



   procedure generate (Self : access gnat_Language.item)
   is
   begin
      emit_Spec (Self.Module_top.Ada.Package_top,              Self.in_cpp_Mode,  Self);
      emit_Spec (Self.Module_top.Ada.Package_binding,          Self.in_cpp_Mode,  Self);
      emit_Spec (Self.Module_top.Ada.Package_pointers,         Self.in_cpp_Mode,  Self);
      emit_Spec (Self.Module_top.Ada.Package_pointer_pointers, Self.in_cpp_Mode,  Self);

      declare
         use ada_package.Vectors;
         Cursor : ada_package.vector_Cursor := Self.Module_top.Ada.new_Packages.First;
      begin
         while has_Element (Cursor)
         loop
            emit_Spec (Element (Cursor),  Self.in_cpp_Mode,  Self);
            next (Cursor);
         end loop;
      end;
   end generate;


end gnat_Language.source_Generator;
