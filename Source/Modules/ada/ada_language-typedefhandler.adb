separate (ada_Language)


overriding
function typedefHandler (Self : access Item;
                         N    : in     Node_Pointer) return C.int
is
   the_Node          :          doh_Node renames N;
   the_doh_type_Name : constant doh_String    := doh_String (get_Attribute (the_Node, "name"));

   --  A typedef of a class is known by its name within the class ('Bar::FooType'), so one of the same name
   --  which is declared outside ('typedef char * FooType;') does not stand in its way.
   --
   known_Name : constant unbounded_String := (if Self.c_class_Stack.is_Empty then +the_doh_type_Name
                                                                             else Self.current_c_Class.Name & "::" & String'(+the_doh_type_Name));

   function hides_another_Type return Boolean
   --
   --  True for a typedef of a class which is not to be made although its name within its class is free: its name is
   --  that of a type which is known already, and either that is a typedef of another class (the instances of a template
   --  each have the typedefs of the template, of which the first is made) or this one is of a class or a pointer, which
   --  could not be told from the other later. One of a number or an enumeration, with the name of a type declared
   --  outside any class, is made: it is a subtype in the package of its class.
   --
   is
      use type c_Type.a_c_type_Kind;
      the_Base : constant unbounded_String := +Attribute (the_Node, "type");
   begin
      return          not Self.c_class_Stack.is_Empty
             and then Self.swig_type_Map_of_c_type.contains (+the_doh_type_Name)
             and then (        Self.class_typedef_Names.contains (String'(+the_doh_type_Name))
                       or else not (         Self.swig_type_Map_of_c_type.contains (the_Base)
                                    and then Self.swig_type_Map_of_c_type.Element (the_Base).c_type_Kind in c_Type.standard_c_Type | c_Type.Enum));
   end hides_another_Type;

begin
   indent_Log;
   dlog (+"");
   dlog (+"'typedefHandler'   the_doh_type_Name: '" & String'(+the_doh_type_Name) & "'");

   Self.current_c_Node := doh_Node (the_Node);
   locate (doh_Node (the_Node));

   if        (         Self.prior_c_Declaration     /= null
              and then Self.prior_c_Declaration.Name = String'(+the_doh_type_Name)
              and then not (         not Self.c_class_Stack.is_Empty                                     -- The declaration before is one of
                            and then Self.swig_type_Map_of_c_type.contains (+the_doh_type_Name)          -- that name outside the class, and
                            and then not Self.swig_type_Map_of_c_type.contains (known_Name)))            -- not this one made already.

     or else Self.swig_type_Map_of_c_type.contains (known_Name)
     or else hides_another_Type
   then
      dlog (+"Skipping typedef.");
   else
      if         not Self.c_class_Stack.is_Empty
        and then not Self.class_typedef_Names.contains (String'(+the_doh_type_Name))
      then
         Self.class_typedef_Names.append (String'(+the_doh_type_Name));
      end if;

      declare
         Name             : constant unbounded_String := +Attribute (the_Node, "name");
         the_type_Name    : constant unbounded_String :=  Name;

         the_doh_swigType : constant SwigType_Pointer :=  SwigType_Pointer (get_Attribute (the_Node, "type"));
         the_swig_Type    : constant swig_Type        := +doh_Item (the_doh_swigType);

         Pad              :          SwigType_Pointer with Unreferenced;
         use type C.int;
      begin
         dlog ("'typedefHandler' - name: '" & Name & "'     swig_Type: '" & to_String (the_swig_Type) & "'");

         if SwigType_isArray (the_doh_swigType) /= 0
         then
            dlog (+"typedef array detected");
            declare
               swig_Type_copy       : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (the_doh_swigType)));
               the_Array            : constant SwigType_Pointer := SwigType_pop_Arrays (swig_Type_copy);
               dimension_Count      : constant C.int            := SwigType_array_nDim (the_Array);
               element_Type         : constant SwigType_Pointer := SwigType_array_type (swig_Type_copy);
               array_dimension_Text :          unbounded_String;
               new_c_Array          :          c_Type.view;
            begin
               new_c_Array := c_type.new_array_Type (Namespace    => Self.current_c_Namespace,
                                                     Name         => the_type_Name,
                                                     element_Type => Self.demand_c_Type_for (doh_Item (element_Type)));
               for Each in 1 .. dimension_Count
               loop
                  array_dimension_Text := +doh_Item (SwigType_array_getdim (the_Array, Each - 1));

                  declare
                     the_Dimension : Integer := 0;     -- A dimension of 0 stands for an unknown length (as in 'typedef char name[];').
                  begin
                     if array_dimension_Text /= ""
                     then
                        begin
                           the_Dimension := Integer (Value (resolved_c_integer_Expression (Self,
                                                                                           array_dimension_Text,
                                                                                           Self.integer_symbol_value_Map,
                                                                                           Self.current_class_namespace_Prefix)));
                        exception
                           when others =>
                              warn (Value, "Unable to evaluate the array dimension '" & array_dimension_Text & "' of '" & the_type_Name
                                         & "', whose length is taken to be unknown.");
                        end;
                     end if;

                     c_type.add_array_Dimension (new_c_Array,
                                                 upper_Bound => the_Dimension - 1);
                  end;
               end loop;

               Self.register (new_c_Array, the_doh_type_Name);
               Self.prior_c_Declaration := new_c_Array.all'Access;
            end;

         elsif is_a_function_Pointer (doh_Item (the_doh_swigType))
         then
            dlog (+"function pointer found");
            Pad := SwigType_del_pointer (the_doh_swigType);

            declare
               raw_swigType         : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (the_doh_swigType)));
               the_Function         : constant SwigType_Pointer := SwigType_pop_Function (raw_swigType);
               function_return_Type : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (raw_swigType)));
               function_Parameters  : constant doh_ParmList     := doh_ParmList (SwigType_function_parms (the_Function, the_Node));

               new_c_Function         : c_Function.view;
               new_c_function_Pointer : c_Type.view;
            begin
               new_c_Function            := c_function.new_c_Function   (to_unbounded_String ("anonymous"),
                                                                         Self.swig_type_Map_of_c_type.Element (+doh_Item (function_return_Type)));
               new_c_function_Pointer    := c_type.new_function_Pointer (Namespace         => Self.current_c_Namespace,
                                                                         Name              => the_type_Name,
                                                                         accessed_Function => new_c_Function);
               new_c_Function.Parameters := Self.to_c_Parameters (function_Parameters);

               Self.register (new_c_function_Pointer, the_doh_type_Name);
               Self.prior_c_Declaration  := new_c_function_Pointer.all'Access;
            end;

         elsif Swigtype_isFunction (the_doh_swigType) /= 0
         then
            dlog (+"typedef function detected");
            declare
               the_Function          : constant SwigType_Pointer := SwigType_pop_function (the_doh_swigType);
               function_return_Type  : constant unbounded_String := +doh_Copy (doh_Item   (the_doh_swigType));
               function_Parameters   : constant doh_ParmList     := doh_ParmList (SwigType_function_Parms (the_Function, the_Node));

               new_c_Function        : constant c_Function.view  := c_Function.new_c_Function (to_unbounded_String ("anonymous"),
                                                                                               Self.swig_type_Map_of_c_type.Element (function_return_Type));
               new_c_typdef_Function :          c_Type.view;
            begin
               dlog ("function_return_Type: '" & function_return_Type & "'");

               new_c_Function.Parameters := Self.to_c_Parameters (function_Parameters);
               new_c_Typdef_function     := c_type.new_typedef_Function (Namespace      => Self.current_c_Namespace,
                                                                         Name           => the_type_Name,
                                                                         typed_Function => new_c_Function);
               Self.register (new_c_typdef_Function,
                              the_doh_type_Name,
                              create_array_Type => False);

               Self.prior_c_Declaration := new_c_Typdef_function.all'Access;
            end;

         else
            if Self.swig_type_Map_of_c_type.contains (the_swig_Type)
            then
               dlog ("swig_type_Map_of_c_type.contains " & the_swig_Type);
               declare
                  the_base_Type : constant c_Type.view := Self.swig_type_Map_of_c_type.Element (the_swig_Type);
               begin
                  if "_" & the_type_Name = the_swig_Type
                  then
                     Self.register_Mirror (the_Type_Name,
                                           the_base_Type,
                                           doh_SwigType (-the_type_Name));
                     the_base_Type.Name_is (the_type_Name);
                     Self.name_Map_of_c_type.Element (the_base_Type.Name & "[]").Name_is (the_type_Name & "_array");
                  else
                     declare
                        new_c_typeDef : constant c_Type.view := c_Type.new_Typedef (Namespace => Self.current_c_Namespace,
                                                                                    Name      => the_type_Name,
                                                                                    base_Type => the_base_Type);
                     begin
                        if Self.c_class_Stack.is_Empty
                        then   Self.register (new_c_typeDef, the_doh_type_Name);
                        else   Self.register (new_c_typeDef, doh_SwigType (to_Doh (to_String (Self.current_c_Class.Name & "::" & to_String (the_doh_type_Name)))));
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
                     new_c_Class := c_Type.new_opaque_Struct (Namespace => Self.current_c_nameSpace,
                                                              Name      => the_type_Name);
                     Self.register (new_c_Class, the_doh_type_Name);
                     Self.prior_c_Declaration := new_c_Class.all'Access;
                  end;

               else   -- Handle case:  'typedef struct foo foo_t;'
                  declare
                     use swigg.Utility;
                     new_c_Class : c_Type.view;
                     class_Name  : doh_swigType := doh_swigType (doh_Copy (doh_Item (-Name)));
                  begin
                     dlog (String' (+class_Name));
                     strip_all_qualifiers (class_Name);
                     dlog (String' (+class_Name));

                     if Self.swig_type_Map_of_c_type.Contains (+class_Name)
                     then
                        new_c_Class := Self.swig_type_Map_of_c_type.Element (+class_Name);
                     else
                        new_c_Class := c_Type.new_opaque_Struct (Namespace => Self.current_c_nameSpace,
                                                                 Name      => +class_Name);
                        Self.register (new_c_Class, doh_SwigType (the_doh_swigType));
                     end if;


                     if "_" & the_type_Name = the_swig_Type
                     then
--                             Self.register_Mirror (the_Type_Name,
--                                                   new_c_Class,
--                                                   doh_Item (-the_type_Name));
--                                                   doh_Item (-("_" & the_type_Name)));
                        new_c_Class.Name_is (the_type_Name);

                        Self.name_Map_of_c_type.Element (new_c_Class.Name & "[]").Name_is (new_c_Class.Name & "_array");
                     else
                        if the_type_Name /= new_c_Class.Name     -- Ignore such as "typedef struct Animal Animal;".
                        then
                           declare
                              new_c_typeDef : constant c_Type.view := c_Type.new_Typedef (Namespace => Self.current_c_Namespace,
                                                                                          Name      => the_type_Name,
                                                                                          base_Type => new_c_Class);
                           begin
                              Self.register (new_c_typeDef, the_doh_type_Name);
                              Self.prior_c_Declaration := new_c_typeDef.all'Access;
                           end;
                        end if;
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
