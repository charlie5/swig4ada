separate (ada_Language)


procedure register (Self : access Item;   the_c_Type              : in c_Type.view;
                                          to_swig_Type            : in doh_swigType;
                                          is_core_C_type          : in Boolean := False;
                                          create_array_Type       : in Boolean := True;
                                          add_level_3_Indirection : in Boolean := False)
is
   use swigg.Utility;
   is_a_new_Type : constant Boolean := not is_core_C_type;
   the_swig_Type : doh_swigType     := doh_Copy (to_swig_Type);

   the_c_type_Pointer         : c_Type.view;
   the_c_type_pointer_Pointer : c_Type.view;


   function is_a_Typedef_of_char return Boolean
   --
   --  Whether the type is a typedef of plain 'char' ('typedef char char_t;'). A pointer to it is a C string, as one
   --  to 'char' is, so it is given the pointer types of 'char' (and is 'interfaces.C.Strings.chars_ptr' in Ada),
   --  and none of its own. A typedef of a 'signed char' or an 'unsigned char' is a byte, and keeps its own.
   --
   is
      use type c_Type.a_c_type_Kind;
   begin
      return     the_c_Type.c_type_Kind = c_Type.Typedef
        and then Self.name_Map_of_c_type.contains (+"char")
        and then the_c_Type.ultimate_base_Type = Self.fetch_c_Type (+"char");
   end is_a_Typedef_of_char;

   of_char : constant Boolean := is_a_Typedef_of_char;

   --  A type is known by its swig type and also, for convenience, by its unqualified name and the names of its
   --  array, pointer and reference types. Two types of different scopes may share such a name (an enumeration
   --  of the same name in each of two classes, say), in which case the name remains that of the first.
   --
   procedure enter_swig_Type (Key : in unbounded_String;   the_Type : in c_Type.view)
   is
   begin
      if not Self.swig_type_Map_of_c_type.contains (Key)
      then
         Self.swig_type_Map_of_c_type.insert (Key, the_Type);
      end if;
   end enter_swig_Type;

   procedure enter_Name (Key : in unbounded_String;   the_Type : in c_Type.view)
   is
   begin
      if not Self.name_Map_of_c_type.contains (Key)
      then
         Self.name_Map_of_c_type.insert (Key, the_Type);
      end if;
   end enter_Name;

   procedure register_the_Type
   --
   --  The type itself, by its swig type and by its name.
   --
   is
   begin
      do_c_Type:
      begin
         enter_swig_Type (+the_swig_Type, the_c_Type);

         if unbounded_String' (+the_swig_Type) /= the_c_Type.Name
         then
            enter_swig_Type (the_c_Type.Name, the_c_Type);
         end if;

         enter_Name (the_c_Type.Name, the_c_Type);

         if is_a_new_Type
         then
            Self.add_new_c_Type (the_c_Type);
         end if;
      end do_c_Type;
   end register_the_Type;



   procedure register_its_Array
   --
   --  The array of the type.
   --
   is
   begin
      if create_array_Type
      then   -- Add associated array.
         declare
            array_swigType   : constant doh_swigType := doh_swigType (to_DOH ("a." & (+the_swig_Type)));
            the_c_type_Array :          c_Type.view;
         begin
            the_c_type_Array := c_type.new_array_Type (the_c_Type.nameSpace,
                                                       the_c_Type.Name & "[]",
                                                       element_Type => the_c_Type);

            --  dlog ("Adding C array   type for swig type '" &  to_String (array_swigType) & "'    C array name is '" & (+the_c_type_Array.qualified_Name) & "'");

            the_c_type_Array.add_array_Dimension;

            enter_swig_Type (+array_swigType, the_c_type_Array);

            if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("a." & the_c_Type.Name, the_c_Type_Array);
            end if;

            enter_Name (the_c_type_Array.Name, the_c_type_Array);

            if is_a_new_Type
            then
               Self.add_new_c_Type (the_c_type_Array);
            end if;
         end;
      end if;
   end register_its_Array;



   procedure register_its_Pointer
   --
   --  The pointer to the type.
   --
   is
   begin
      declare   -- Add associated pointer.
         pointer_swigType : constant doh_swigType := doh_swigType (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type))));
      begin
         if of_char
         then
            the_c_type_Pointer := Self.fetch_c_Type (+"char*");
         else
            the_c_type_Pointer := c_type.new_type_Pointer (the_c_Type.nameSpace,
                                                           the_c_Type.Name & "*",
                                                           accessed_Type => the_c_Type);
         end if;

         --  dlog ("Adding C pointer type for swig type '" &  to_String (pointer_swigType) & "'    C pointer name is '" & (+the_c_type_Pointer.qualified_Name) & "'");

         enter_swig_Type (+pointer_swigType, the_c_type_Pointer);

         if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
         then
            enter_swig_Type ("p." & the_c_Type.Name, the_c_Type_Pointer);
         end if;

         enter_Name (the_c_Type.Name & "*", the_c_type_Pointer);

         declare   -- Register pointer to 'const'.
            the_pointer_to_const_swigType : constant doh_swigType
              := doh_swigType (swigtype_add_Pointer (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                            const_String (to_Doh ("const")))));
            the_c_pointer_to_const_Name   : constant unbounded_String := "const " & the_c_Type.Name & "*";
         begin
            enter_swig_Type (+the_pointer_to_const_swigType, the_c_type_Pointer);

            if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("p.q(const)." & the_c_Type.Name, the_c_Type_Pointer);
            end if;

            enter_Name (the_c_pointer_to_const_Name, the_c_type_Pointer);
         end;

         if is_a_new_Type
           and not of_char
         then
            Self.add_new_c_Type (the_c_type_Pointer);
         end if;
      end;
   end register_its_Pointer;



   procedure register_its_Reference
   --
   --  The reference to the type, which is a pointer too.
   --
   is
   begin
      declare   -- Add associated reference.
         reference_swigType : constant doh_swigType := doh_swigType (SwigType_add_reference (SwigType_Pointer (doh_copy (the_swig_Type))));
      begin
         enter_swig_Type (+reference_swigType, the_c_type_Pointer);

         if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
         then
            enter_swig_Type ("r." & the_c_Type.Name, the_c_Type_Pointer);
         end if;

         --  An rvalue reference ('T&&', which swig writes 'z.T') is a pointer too.
         --
         enter_swig_Type ("z."          & unbounded_String'(+the_swig_Type), the_c_type_Pointer);
         enter_swig_Type ("z.q(const)." & unbounded_String'(+the_swig_Type), the_c_type_Pointer);

         enter_Name (the_c_type.Name & "&", the_c_type_Pointer);

         declare   -- Register reference to 'const'.
            the_reference_to_const_swigType : constant doh_swigType
              := doh_swigType (SwigType_add_reference (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                              const_String (to_Doh ("const")))));
            the_c_reference_to_const_Name   : constant unbounded_String := "const " & the_c_Type.Name & "&";
         begin
            enter_swig_Type (+the_reference_to_const_swigType, the_c_type_Pointer);

            if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("r.q(const)." & the_c_Type.Name & "&", the_c_type_Pointer);
            end if;

            enter_Name (the_c_reference_to_const_Name, the_c_type_Pointer);
         end;
      end;
   end register_its_Reference;



   procedure register_its_pointer_Pointer
   --
   --  The pointer to a pointer to the type.
   --
   is
   begin
      do_level_2_indirection:
      begin
         declare
            array_of_pointers_swigType : constant doh_swigType
              := doh_SwigType (to_DOH ("a." & (+doh_Item (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type)))))));
            the_c_type_pointer_Array   : c_Type.view;
         begin
            if of_char
            then
               the_c_type_pointer_Array := Self.fetch_c_Type (+"char*[]");
            else
               the_c_type_pointer_Array := c_type.new_array_Type (the_c_Type.nameSpace,
                                                                  the_c_Type.Name & "*[]",
                                                                  element_Type => the_c_type_Pointer);
               the_c_type_pointer_Array.add_array_Dimension;
            end if;

            enter_swig_Type (+array_of_pointers_swigType, the_c_type_pointer_Array);

            if unbounded_String' (+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("a.p." & the_c_Type.Name, the_c_type_pointer_Array);
            end if;

            enter_Name (the_c_Type.Name & "*[]", the_c_type_pointer_Array);

            if is_a_new_Type
              and not of_char
            then
               Self.add_new_c_Type (the_c_type_pointer_Array);
            end if;
         end;

         if of_char
         then
            the_c_type_pointer_Pointer := Self.fetch_c_Type (+"char**");
         else
            the_c_type_pointer_Pointer := c_type.new_type_Pointer (the_c_Type.nameSpace,
                                                                   the_c_Type.Name & "**",
                                                                   accessed_Type => the_c_type_Pointer);
         end if;

         declare   -- Add pointer pointer.
            pointer_to_pointer_swigType : constant doh_swigType
              := doh_SwigType (swigtype_add_Pointer (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type)))));
         begin
            enter_swig_Type (+pointer_to_pointer_swigType, the_c_type_pointer_Pointer);

            if unbounded_String' (+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("p.p." & the_c_Type.Name, the_c_type_pointer_Pointer);
            end if;

            enter_swig_Type ("r.p." & the_c_Type.Name, the_c_type_pointer_Pointer);     -- A reference to a pointer is passed as a pointer to it.

            enter_Name (the_c_Type.Name & "**", the_c_type_pointer_Pointer);
         end;


         declare   -- Register pointer pointer to 'const'.
            the_pointer_to_pointer_to_const_swigType : constant doh_swigType
              := doh_SwigType (swigtype_add_Pointer (swigtype_add_Pointer (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                                                  const_String (to_Doh ("const"))))));
            the_c_pointer_to_pointer_to_const_Name   : constant unbounded_String   := "const " & the_c_Type.Name & "**";
         begin
            enter_swig_Type (+the_pointer_to_pointer_to_const_swigType, the_c_type_pointer_Pointer);

            if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("p.p.q(const)." & the_c_Type.Name, the_c_type_pointer_Pointer);
            end if;

            enter_Name (the_c_pointer_to_pointer_to_const_Name, the_c_type_pointer_Pointer);
         end;

         if is_a_new_Type
           and not of_char
         then
            Self.add_new_c_Type (the_c_type_pointer_Pointer);
         end if;
      end do_level_2_indirection;
   end register_its_pointer_Pointer;



   procedure register_the_third_Level
   --
   --  The pointer to a pointer to a pointer to the type.
   --
   is
   begin
      do_level_3_indirection:
      declare
         the_c_type_pointer_pointer_Pointer : constant c_Type.view := c_type.new_type_Pointer (the_c_Type.nameSpace,
                                                                                               the_c_Type.Name & "***",
                                                                                               accessed_Type => the_c_type_pointer_Pointer);
      begin
         declare
            array_of_pointer_pointers_swigType : constant doh_swigType
              := doh_SwigType (to_DOH ("a." & (+doh_Item (swigtype_add_Pointer (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type))))))));
            the_c_type_pointer_pointer_Array   : c_Type.view;
         begin
            --  dlog (+"array_of_pointer_pointers_swigType: '" & String'(+array_of_pointer_pointers_swigType) & "'");

            the_c_type_pointer_pointer_Array := c_type.new_array_Type (the_c_Type.nameSpace,
                                                                       the_c_Type.Name & "**[]",
                                                                       element_Type => the_c_type_pointer_Pointer);
            the_c_type_pointer_pointer_Array.add_array_Dimension;

            enter_swig_Type (+array_of_pointer_pointers_swigType, the_c_type_pointer_pointer_Array);

            if unbounded_String' (+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("a.p.p" & the_c_Type.Name, the_c_type_pointer_pointer_Array);
            end if;

            enter_Name (the_c_type_pointer_pointer_Array.Name, the_c_type_pointer_pointer_Array);

            if is_a_new_Type
            then
               Self.add_new_c_Type (the_c_type_pointer_pointer_Array);
            end if;
         end;

         declare   -- Add pointer pointer.
            pointer_to_pointer_pointer_swigType : constant doh_swigType
              := doh_SwigType (swigtype_add_Pointer (swigtype_add_Pointer (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type))))));
         begin
            enter_swig_Type (+pointer_to_pointer_pointer_swigType, the_c_type_pointer_pointer_Pointer);

            if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("p.p.p" & the_c_Type.Name, the_c_type_pointer_pointer_Pointer);
            end if;

            enter_Name (the_c_type_pointer_pointer_Pointer.Name, the_c_type_pointer_pointer_Pointer);
         end;

         if is_a_new_Type
         then
            Self.add_new_c_Type (the_c_type_pointer_pointer_Pointer);
         end if;
      end do_level_3_indirection;
   end register_the_third_Level;



begin
   strip_all_Qualifiers (the_swig_Type);

   if Self.swig_type_Map_of_c_type.Contains (+the_swig_Type)
   then   -- The swig type is already registered (such as by 'typedef struct foo {...} foo;').
      dlog (+"The C type named '" & the_c_Type.Name & "' for swig type '" & to_String (the_swig_Type) & "' is already registered.");
      return;
   end if;

   --  dlog ("");
   --  dlog (+"Registering new C type named '" & the_c_Type.Name & "' for swig type '" & to_String (the_swig_Type) & "'    is a new Type: " & Boolean'Image (is_a_new_Type));

   register_the_Type;
   register_its_Array;
   register_its_Pointer;
   register_its_Reference;
   register_its_pointer_Pointer;

   if add_level_3_Indirection
   then
      register_the_third_Level;
   end if;
end register;
