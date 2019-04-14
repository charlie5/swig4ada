with
     ada_Type.elementary.scalar.discrete.enumeration,
     ada_Type.elementary.scalar.discrete.integer.modular,
     ada_Type.elementary.scalar.discrete.integer.signed,
     ada_Type.elementary.scalar.real.float,
     ada_Type.elementary.an_access.to_type,
     ada_Type.a_subtype,
     ada_Type.composite.an_array,
     ada_Type.composite.a_record,
     ada_Utility,

     swigg_module.Binding,
     ada.Strings.Maps;


package body gnat_Language.Forge
is

   function construct return gnat_Language.view
   is
      use c_nameSpace,  ada_Package,  ada_Utility;

--        base_Language    : constant swigg_module.Language.item := swigg_module.Language.item (swigg_module.Language.construct);
      Self : constant View
--          := new gnat_Language.item'(swigg_module.Language.do_construct with -- base_Language with
--          := new gnat_Language.item'(swigg_module.Language.do_construct with -- base_Language with
        := new gnat_Language.item'(swigg_module.Language.new_Language with -- base_Language with

                                   new_Modules           => <>,
                                   name_Map_of_module    => <>,
                                   Module_core           => <>,
                                   Module_top            => <>,

                                   nameSpace_std         => <>,
                                   c_namespace_Stack     => <>,

                                   Package_standard      => <>,
                                   Package_system        => <>,

                                   Package_interfaces    => <>,
                                   Package_interfaces_c  => <>,
                                   Package_interfaces_c_strings
                                                         => <>,

                                   Package_swig          => <>,
                                   Package_swig_pointers => <>,

                                   incomplete_access_to_Type_i_c_pointer_List
                                                         => <>,

                                   name_Map_of_c_type    => <>,
                                   name_Map_of_ada_type  => <>,

                                   swig_type_Map_of_c_type        => <>,
                                   c_type_Map_of_ada_type         => <>,
                                   c_type_Map_of_ada_subprogram   => <>,
                                   c_namespace_Map_of_ada_Package => <>,

                                   current_c_Node         => null,
                                   c_class_stack          => <>,
                                   prior_c_Declaration    => <>,

                                   current_c_enum         => <>,
                                   last_c_enum_rep_value  => <>,
                                   anonymous_c_enum_Count => <>,

                                   -- old ...
                                   --
                                   a_namespaces           => namespace_sets.empty_Set,


                                   in_CPP_mode              => False,
                                   native_function_Flag     => False,
                                   enum_constant_Flag       => False,
                                   have_default_constructor_flag
                                                            => False,
                                   static_flag              => False,
                                   variable_wrapper_flag    => False,
                                   wrapping_member_flag     => False,
                                   is_anonymous_Enum        => False,

                                   enum_rep_clause_required => False,
                                   anonymous_enum_Count     => 0,
                                   integer_symbol_value_Map         => symbol_value_maps.empty_Map,

                                   f_runtime                => null,
                                   f_header                 => null,
                                   f_wrappers               => null,
                                   f_init                   => null,
                                   f_gnat                   => null,

                                   current_linkage_Symbol   => null_unbounded_String,
                                   current_lStr             => null_unbounded_String);
   begin
      --  Modules
      --
      Self.Module_core.Name := +"CORE_MODULE";


      --  c nameSpaces
      --
      Self.nameSpace_std := new_c_nameSpace (name   => "std",
                                             parent => null);
      Self.c_namespace_Stack.append (Self.nameSpace_std);


      --  ada Packages
      --
      Self.Package_standard                := new_ada_Package (name => "standard",   parent => null,                      is_Core => True);
      Self.Package_system                  := new_ada_Package (name => "system",     parent => Self.Package_standard,     is_Core => True);

      Self.Package_interfaces              := new_ada_Package (name => "interfaces", parent => Self.Package_standard,     is_Core => True);
      Self.Package_interfaces_c            := new_ada_Package (name => "c",          parent => Self.Package_interfaces,   is_Core => True);
      Self.Package_interfaces_c_strings    := new_ada_Package (name => "strings",    parent => Self.Package_interfaces_c, is_Core => True);

      Self.Package_swig                    := new_ada_Package (name => "swig",       parent => Self.Package_standard,     is_Core => True);
      Self.Package_swig_pointers           := new_ada_Package (name => "pointers",   parent => Self.Package_swig,         is_Core => True);


      create_C_core_Types :
      declare
         the_c_Type : c_Type.view;
      begin
         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"void");
         Self.register (the_c_Type,  doh_SwigType (-"void"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"ptrdiff_t");
         Self.register (the_c_Type,  doh_SwigType (-"ptrdiff_t"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"size_t");
         Self.register (the_c_Type,  doh_SwigType (-"size_t"), is_core_C_type => True);


         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"char");
         Self.register (the_c_Type,  doh_SwigType (-"char"),   is_core_C_type => True,  add_level_3_Indirection => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"wchar_t");
         Self.register (the_c_Type,  doh_SwigType (-"wchar_t"), is_core_C_type => True); --,  add_level_3_Indirection => True);


         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"unsigned char");
         Self.register (the_c_Type,  doh_SwigType (-"unsigned char"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"signed char");
         Self.register (the_c_Type,  doh_SwigType (-"signed char"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"std::string");
         Self.register (the_c_Type,  doh_SwigType (-"std::string"), is_core_C_type => True);


         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"short");
         Self.register (the_c_Type,  doh_SwigType (-"short"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"int");
         Self.register (the_c_Type,  doh_SwigType (-"int"),  is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"long");
         Self.register (the_c_Type,  doh_SwigType (-"long"),  is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"long long");
         Self.register (the_c_Type,  doh_SwigType (-"long long"), is_core_C_type => True);


         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"unsigned short");
         Self.register (the_c_Type,  doh_SwigType (-"unsigned short"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"unsigned int");
         Self.register (the_c_Type,  doh_SwigType (-"unsigned int"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"unsigned long");
         Self.register (the_c_Type,  doh_SwigType (-"unsigned long"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"unsigned long long");
         Self.register (the_c_Type,  doh_SwigType (-"unsigned long long"), is_core_C_type => True);


         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"int8_t");
         Self.register (the_c_Type,  doh_SwigType (-"int8_t"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"int16_t");
         Self.register (the_c_Type,  doh_SwigType (-"int16_t"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"int32_t");
         Self.register (the_c_Type,  doh_SwigType (-"int32_t"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"int64_t");
         Self.register (the_c_Type,  doh_SwigType (-"int64_t"), is_core_C_type => True);


         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"uint8_t");
         Self.register (the_c_Type,  doh_SwigType (-"uint8_t"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"uint16_t");
         Self.register (the_c_Type,  doh_SwigType (-"uint16_t"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"uint32_t");
         Self.register (the_c_Type,  doh_SwigType (-"uint32_t"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"uint64_t");
         Self.register (the_c_Type,  doh_SwigType (-"uint64_t"), is_core_C_type => True);


         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"intptr_t");
         Self.register (the_c_Type,  doh_SwigType (-"intptr_t"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"uintptr_t");
         Self.register (the_c_Type,  doh_SwigType (-"uintptr_t"), is_core_C_type => True);


         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"float");
         Self.register (the_c_Type,  doh_SwigType (-"float"), is_core_C_type => True);

         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"double");
         Self.register (the_c_Type,  doh_SwigType (-"double"), is_core_C_type => True);


         the_c_Type := c_type.new_standard_c_Type (Self.nameSpace_std,  +"bool");
         Self.register (the_c_Type,  doh_SwigType (-"bool"), is_core_C_type => True);
      end create_C_core_Types;


      create_Ada_core_Types :
      declare
         the_ada_Type : ada_Type.view;
      begin
         --  package 'Standard'
         --
         the_ada_Type := ada_Type.elementary.scalar.discrete.integer.modular.new_Item (Self.Package_system,
                                                                                       +"Address").all'Access;
         Self.name_Map_of_ada_type.insert (+"system.Address",
                                           the_ada_Type);

         the_ada_Type := ada_Type.elementary.scalar.discrete.enumeration    .new_Item (Self.Package_standard,
                                                                                       +"Character").all'Access;
         Self.name_Map_of_ada_type.insert (+"Character",
                                           the_ada_Type);

         the_ada_Type := ada_Type.elementary.scalar.discrete.enumeration    .new_Item (Self.Package_standard,
                                                                                       +"Wide_Character").all'Access;
         Self.name_Map_of_ada_type.insert (+"Wide_Character",
                                           the_ada_Type);

         the_ada_Type := ada_Type.elementary.scalar.discrete.integer.signed .new_Item (Self.Package_standard,
                                                                                       +"Integer").all'Access;
         Self.name_Map_of_ada_type.insert (+"Integer",
                                           the_ada_Type);

         the_ada_Type := ada_Type.elementary.scalar.discrete.integer.signed .new_Item (Self.Package_standard,
                                                                                       +"long_long_Integer").all'Access;
         Self.name_Map_of_ada_type.insert (+"long_long_Integer",
                                           the_ada_Type);

         the_ada_Type := ada_Type.elementary.scalar.discrete.integer.signed .new_Item (Self.Package_standard,
                                                                                       +"short_Integer").all'Access;
         Self.name_Map_of_ada_type.insert (+"short_Integer",
                                           the_ada_Type);

         the_ada_Type := ada_Type.elementary.scalar.real.float              .new_Item (Self.Package_standard,
                                                                                       +"Float").all'Access;
         Self.name_Map_of_ada_type.insert (+"Float",
                                           the_ada_Type);

         the_ada_Type := ada_Type.elementary.scalar.real.float              .new_Item (Self.Package_standard,
                                                                                       +"long_Float").all'Access;
         Self.name_Map_of_ada_type.insert (+"long_Float",
                                           the_ada_Type);


         Package_interfaces :
         declare
            the_ada_Type : ada_Type.view;
         begin
            --  signed
            --
            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.signed.new_Item (Self.Package_interfaces,
                                                                                         +"Integer_8").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.signed.new_Item (Self.Package_interfaces,
                                                                                         +"Integer_16").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.signed.new_Item (Self.Package_interfaces,
                                                                                         +"Integer_32").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.signed.new_Item (Self.Package_interfaces,
                                                                                         +"Integer_64").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            --  unsigned
            --
            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.modular.new_Item (Self.Package_interfaces,
                                                                                          +"Unsigned_8").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.modular.new_Item (Self.Package_interfaces,
                                                                                          +"Unsigned_16").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.modular.new_Item (Self.Package_interfaces,
                                                                                          +"Unsigned_32").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.modular.new_Item (Self.Package_interfaces,
                                                                                          +"Unsigned_64").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);
         end package_Interfaces;


         Package_interfaces_c :
         declare
            the_ada_Type : ada_Type.view;
         begin
            --  general
            --
            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.signed .new_Item (Self.Package_interfaces_c,
                                                                                          +"ptrdiff_t").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.modular.new_Item (Self.Package_interfaces_c,
                                                                                          +"size_t").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            --  signed
            --
            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_interfaces_c,
                                                            +"short",
                                                            base_type => Self.name_Map_of_ada_type.Element (+"short_Integer")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);


            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_interfaces_c,
                                                            +"int",
                                                            base_type => Self.fetch_ada_type (+"Integer")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);


            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.signed.new_Item (Self.Package_interfaces_c,
                                                                                         +"long").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            --  unsigned
            --
            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.modular.new_Item (Self.Package_interfaces_c,
                                                                                          +"unsigned_short").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.modular.new_Item (Self.Package_interfaces_c,
                                                                                          +"unsigned").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.modular.new_Item (Self.Package_interfaces_c,
                                                                                          +"unsigned_long").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            --  char
            --
            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_interfaces_c,
                                                            +"char",
                                                            base_type => Self.fetch_ada_Type (+"Character")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_Type.composite.an_array.new_Item (Self.Package_interfaces_c,
                                                                  +"char_array",
                                                                  the_array_dimension_upper_Bounds => (1 => ada_Type.composite.an_array.unConstrained),
                                                                  element_type                     => Self.fetch_ada_Type (+"interfaces.c.char")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            --  wchar_t
            --
            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_interfaces_c,
                                                            +"wchar_t",
                                                            base_type => Self.fetch_ada_Type (+"Wide_Character")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_Type.composite.an_array.new_Item (Self.Package_interfaces_c,
                                                                  +"wchar_array",
                                                                  the_array_dimension_upper_Bounds => (1 => ada_Type.composite.an_array.unConstrained),
                                                                  element_type                     => Self.fetch_ada_Type (+"interfaces.c.wchar_t")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            --  signed char
            --
            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.signed.new_Item (Self.Package_interfaces_c,
                                                                                         +"signed_char").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.modular.new_Item (Self.Package_interfaces_c,
                                                                                          +"unsigned_char").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_interfaces_c,
                                                            +"plain_char",
                                                            base_type => Self.fetch_ada_Type (+"interfaces.c.unsigned_char")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);

            --  float
            --
            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_interfaces_c,
                                                            +"c_float",
                                                            base_type => Self.fetch_ada_Type (+"Float")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);


            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_interfaces_c,
                                                            +"double",
                                                            base_type => Self.fetch_ada_Type (+"long_Float")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);
         end package_Interfaces_C;


         package_Interfaces_C_strings :
         begin
            the_ada_Type := ada_Type.elementary.an_access.to_type.new_Item (Self.Package_interfaces_c_strings,
                                                                            +"chars_ptr",
                                                                            accessed_type => Self.fetch_ada_Type (+"Character")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);


            the_ada_Type := ada_Type.composite.an_array.new_Item (Self.Package_interfaces_c_strings,
                                                                  +"chars_ptr_array",
                                                                  the_array_dimension_upper_Bounds => (1 => ada_Type.composite.an_array.unConstrained),
                                                                  element_type                     => Self.fetch_ada_Type (+"interfaces.c.strings.chars_ptr")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);
         end package_Interfaces_C_strings;


         package_Interfaces_C_extensions :   -- tbd: move this into package_Swig (below)
         begin
            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_swig,  +"long_long",
                                                            base_type => Self.fetch_ada_Type (+"long_long_Integer")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name, the_ada_Type);

            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.modular.new_Item (Self.Package_swig,  +"unsigned_long_long").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name, the_ada_Type);


            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_swig, +"opaque_structure",
                                                            base_type => Self.fetch_ada_Type (+"system.Address")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name, the_ada_Type);


            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_swig, +"incomplete_class",
                                                            base_type => Self.fetch_ada_Type (+"system.Address")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name, the_ada_Type);

            --  void
            --
            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_swig, +"void",
                                                            base_type => Self.fetch_ada_Type (+"system.Address")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name, the_ada_Type);

            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_swig, +"void_ptr",
                                                            base_type => Self.fetch_ada_Type (+"system.Address")).all'Access;

            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name, the_ada_Type);

            --  std::string
            --
            the_ada_Type := ada_type.composite.a_record.new_Item (Self.Package_swig_pointers,  +"std_string").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name, the_ada_Type);
         end package_Interfaces_C_extensions;


         package_Swig :
         declare
            use ada_Type.composite.an_array;

            procedure add_associated_swig_package_Types_for (the_ada_Type :    ada_Type.view;
                                                             c_type_Name  : in String;
                                                             jjj          :    Boolean := False)
            is
               function translated_c_type_Name return String
               is
                  Pad   :          unbounded_String := +c_type_Name;
                  Index : constant Natural          := ada.Strings.unbounded.Index (Pad, "::");
               begin
                  if Index /= 0 then
                     replace_Slice (Pad,  Index, Index + 1,  " ");
                  end if;

                  return to_String (Translate (Pad, Ada.Strings.Maps.to_Mapping (" ", "_")));
               end translated_c_type_Name;

               the_c_type_Name         : constant String       := translated_c_type_Name;
               level_1_pointer_subType :          ada_Type.view;

            begin
               do_level_1_indirection :
               declare
                  the_ada_array_Type   : ada_Type.view;
                  level_1_pointer_Type : ada_Type.view;

                  function the_declaration_package return ada_Package.view
                  is
                  begin
                     if the_ada_Type.resolved_Type.all in ada_Type.elementary.an_access.Item'Class
                     then
                        return Self.Package_swig_pointers;
                     else
                        return Self.Package_swig;
                     end if;
                  end the_declaration_package;

               begin
                  --  array
                  --
                  the_ada_array_Type := ada_Type.composite.an_array.new_Item (the_declaration_package,
                                                                              +the_c_type_Name & "_Array",
                                                                              the_array_dimension_upper_Bounds => (1 => unConstrained),
                                                                              element_type                     => the_ada_Type).all'Access;
                  Self.name_Map_of_ada_type.insert (the_ada_array_Type.qualified_Name,
                                                    the_ada_array_Type);
                  --  pointer
                  --
                  level_1_pointer_Type := ada_Type.elementary.an_access.to_type.new_Item (Self.Package_swig_pointers,
                                                                                          +"c_" & the_c_type_Name & "_Pointer.Pointers",
                                                                                          accessed_type => the_ada_Type).all'Access;
                  Self.name_Map_of_ada_type.insert (level_1_pointer_Type.qualified_Name,
                                                    level_1_pointer_Type);

                  level_1_pointer_subType := ada_type.a_subtype.new_subType (Self.Package_swig_pointers,
                                                                             +the_c_type_Name & "_Pointer",
                                                                             base_type => level_1_pointer_Type).all'Access;
                  Self.name_Map_of_ada_type.insert (level_1_pointer_subType.qualified_Name,
                                                    level_1_pointer_subType);
                  if jjj then
                     log (level_1_pointer_subType.qualified_Name & "'");
                     raise Program_Error;
                  end if;
               end do_level_1_indirection;


               do_level_2_indirection :
               declare
                  the_ada_array_Type      : ada_Type.view;
                  level_2_pointer_Type    : ada_Type.view;
                  level_2_pointer_subType : ada_Type.view;
               begin
                  --  array
                  --
                  the_ada_array_Type := ada_Type.composite.an_array.new_Item (Self.Package_swig_pointers,
                                                                              +the_c_type_Name & "_pointer_Array",
                                                                              the_array_dimension_upper_Bounds => (1 => unConstrained),
                                                                              element_type                     => level_1_pointer_subType).all'Access;
                  Self.name_Map_of_ada_type.insert (the_ada_array_Type.qualified_Name,
                                                    the_ada_array_Type);
                  --  pointer
                  --
                  level_2_pointer_Type := ada_Type.elementary.an_access.to_type.new_Item (Self.Package_swig_pointers,
                                                                                          +"c_" & the_c_type_Name & "_pointer_Pointer.Pointers",
                                                                                          accessed_type => level_1_pointer_subType).all'Access;
                  Self.name_Map_of_ada_type.insert (level_2_pointer_Type.qualified_Name,
                                                    level_2_pointer_Type);


                  level_2_pointer_subType := ada_type.a_subtype.new_subType (Self.Package_swig_pointers,
                                                                             +the_c_type_Name & "_pointer_Pointer",
                                                                             base_type => level_2_pointer_Type).all'Access;
                  Self.name_Map_of_ada_type.insert (level_2_pointer_subType.qualified_Name,
                                                    level_2_pointer_subType);
               end do_level_2_indirection;

            end add_associated_swig_package_Types_for;

         begin
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"swig.void_ptr"),             c_type_name => "void_ptr");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"swig.pointers.std_string"),  c_type_name => "std::string", jjj => False);

            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.size_t"),       c_type_name => "size_t");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.ptrdiff_t"),    c_type_name => "ptrdiff_t");

            --  signed
            --
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.short"),   c_type_name => "short");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.int"),     c_type_name => "int");

            --  unsigned
            --
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.unsigned_short"),   c_type_name => "unsigned_short");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.unsigned"),         c_type_name => "unsigned");

            --  real numbers
            --
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.c_float"),   c_type_name => "float");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.double"),    c_type_name => "double");

            --  sized signed integers
            --
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.Integer_8"),   c_type_name => "int8_t");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.Integer_16"),  c_type_name => "int16_t");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.Integer_32"),  c_type_name => "int32_t");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.Integer_64"),  c_type_name => "int64_t");

            --  sized unsigned integers
            --
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.Unsigned_8"),   c_type_name => "uint8_t");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.Unsigned_16"),  c_type_name => "uint16_t");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.Unsigned_32"),  c_type_name => "uint32_t");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.Unsigned_64"),  c_type_name => "uint64_t");


            --  bool
            --
            the_ada_Type := ada_type.a_subtype.new_subType (Self.Package_swig,  +"bool",
                                                            base_type => Self.fetch_ada_Type (+"interfaces.c.plain_char")).all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,  the_ada_Type);

            add_associated_swig_package_Types_for (the_ada_Type,  c_type_name => "bool");


            --  pointers to signed and unsigned integers
            --
            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.signed.new_Item (Self.Package_swig,
                                                                                         +"intptr_t").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);
            add_associated_swig_package_Types_for (the_ada_Type,
                                                   c_type_name => "intptr_t");

            the_ada_Type := ada_Type.elementary.scalar.discrete.integer.modular.new_Item (Self.Package_swig,
                                                                                          +"uintptr_t").all'Access;
            Self.name_Map_of_ada_type.insert (the_ada_Type.qualified_Name,
                                              the_ada_Type);
            add_associated_swig_package_Types_for (the_ada_Type,
                                                   c_type_name => "uintptr_t");

            --  long integers
            --
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.long"),            c_type_name => "long");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.unsigned_long"),   c_type_name => "unsigned long");

            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"swig.long_long"),               c_type_name => "long long");
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"swig.unsigned_long_long"),      c_type_name => "unsigned long long");


            --  wchar_t
            --
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.wchar_t"),
                                                   c_type_name => "wchar_t");

            --  char
            --
            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.strings.chars_ptr"),
                                                   c_type_name => "chars_ptr");

            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.signed_char"),
                                                   c_type_name => "signed_char");

            add_associated_swig_package_Types_for (Self.fetch_ada_Type (+"interfaces.c.unsigned_char"),
                                                   c_type_name => "unsigned_char");
         end package_Swig;

      end create_Ada_core_Types;


      associate_core_c_and_ada_Types :
      begin
         ---  General
         --

         --  void
         --
         Self.associate (Self.fetch_ada_Type (+"swig.void"),                      Self.fetch_c_Type   (+"void"));


         --  void_ptr
         --
         Self.associate (Self.fetch_ada_Type (+"swig.void_ptr"),                  Self.fetch_c_Type   (+"void*"));

         Self.associate (Self.fetch_ada_Type (+"swig.void_ptr_Array"),            Self.fetch_c_Type   (+"void*[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.void_ptr_Pointer"), Self.fetch_c_Type   (+"void**"));

         --  C 'std::string'
         --
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.std_string"),       Self.fetch_c_Type   (+"std::string"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.std_string_Pointer"),
                         Self.fetch_c_Type   (+"std::string*"));

         --  C 'size_t'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.size_t"),           Self.fetch_c_Type   (+"size_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.size_t_Array"),             Self.fetch_c_Type   (+"size_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.size_t_Pointer"),  Self.fetch_c_Type   (+"size_t*"));

         --  C 'ptrdiff_t'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.ptrdiff_t"),           Self.fetch_c_Type   (+"ptrdiff_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.ptrdiff_t_Array"),             Self.fetch_c_Type   (+"ptrdiff_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.ptrdiff_t_Pointer"),  Self.fetch_c_Type   (+"ptrdiff_t*"));

         --  bool
         --
         Self.associate (Self.fetch_ada_Type (+"swig.bool"),                   Self.fetch_c_Type   (+"bool"));
         Self.associate (Self.fetch_ada_Type (+"swig.bool_Array"),             Self.fetch_c_Type   (+"bool[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.bool_Pointer"),  Self.fetch_c_Type   (+"bool*"));


         ---  Signed
         --

         --  C 'short'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.short"),                  Self.fetch_c_Type (+"short"));

         Self.associate (Self.fetch_ada_Type (+"swig.short_Array"),                    Self.fetch_c_Type (+"short[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.short_Pointer"),         Self.fetch_c_Type (+"short*"));

         Self.associate (Self.fetch_ada_Type (+"swig.pointers.short_pointer_Array"),   Self.fetch_c_Type (+"short*[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.short_pointer_Pointer"), Self.fetch_c_Type (+"short**"));

         --  C 'int'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.int"),             Self.fetch_c_Type   (+"int"));

         Self.associate (Self.fetch_ada_Type (+"swig.int_Array"),               Self.fetch_c_Type   (+"int[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.int_Pointer"),    Self.fetch_c_Type   (+"int*"));

         Self.associate (Self.fetch_ada_Type (+"swig.pointers.int_pointer_Array"),     Self.fetch_c_Type   (+"int*[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.int_pointer_Pointer"),   Self.fetch_c_Type   (+"int**"));

         --  C 'long'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.long"),            Self.fetch_c_Type   (+"long"));

         Self.associate (Self.fetch_ada_Type (+"swig.long_Array"),              Self.fetch_c_Type   (+"long[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.long_Pointer"),   Self.fetch_c_Type   (+"long*"));

         Self.associate (Self.fetch_ada_Type (+"swig.pointers.long_pointer_Array"),    Self.fetch_c_Type   (+"long*[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.long_pointer_Pointer"),  Self.fetch_c_Type   (+"long**"));

         --  C 'long long'
         --
         Self.associate (Self.fetch_ada_Type (+"swig.long_long"),           Self.fetch_c_Type   (+"long long"));
         Self.associate (Self.fetch_ada_Type (+"swig.long_long_Array"),     Self.fetch_c_Type   (+"long long[]"));

         --  C 'int8_t'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.Integer_8"),           Self.fetch_c_Type   (+"int8_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.int8_t_Array"),              Self.fetch_c_Type   (+"int8_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.int8_t_Pointer"),   Self.fetch_c_Type   (+"int8_t*"));

         --  C 'int16_t'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.Integer_16"),          Self.fetch_c_Type   (+"int16_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.int16_t_Array"),             Self.fetch_c_Type   (+"int16_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.int16_t_Pointer"),  Self.fetch_c_Type   (+"int16_t*"));

         --  C 'int32_t'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.Integer_32"),            Self.fetch_c_Type   (+"int32_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.int32_t_Array"),               Self.fetch_c_Type   (+"int32_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.int32_t_Pointer"),    Self.fetch_c_Type   (+"int32_t*"));


         --  C 'int64_t'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.Integer_64"),            Self.fetch_c_Type   (+"int64_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.int64_t_Array"),               Self.fetch_c_Type   (+"int64_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.int64_t_Pointer"),    Self.fetch_c_Type   (+"int64_t*"));


         ---  Unsigned
         --

         --  C 'unsigned short'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.unsigned_short"),           Self.fetch_c_Type   (+"unsigned short"));
         Self.associate (Self.fetch_ada_Type (+"swig.unsigned_short_Array"),             Self.fetch_c_Type   (+"unsigned short[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.unsigned_short_Pointer"),  Self.fetch_c_Type   (+"unsigned short*"));

         --  C 'unsigned int'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.unsigned"),            Self.fetch_c_Type   (+"unsigned int"));

         Self.associate (Self.fetch_ada_Type (+"swig.unsigned_Array"),              Self.fetch_c_Type   (+"unsigned int[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.unsigned_Pointer"),   Self.fetch_c_Type   (+"unsigned int*"));

         Self.associate (Self.fetch_ada_Type (+"swig.pointers.unsigned_pointer_Array"),     Self.fetch_c_Type   (+"unsigned int*[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.unsigned_pointer_Pointer"),   Self.fetch_c_Type   (+"unsigned int**"));

         --  C 'unsigned long'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.unsigned_long"),       Self.fetch_c_Type   (+"unsigned long"));
         Self.associate (Self.fetch_ada_Type (+"swig.unsigned_long_Array"),         Self.fetch_c_Type   (+"unsigned long[]"));

         --  C 'unsigned long long'
         --
         Self.associate (Self.fetch_ada_Type (+"swig.unsigned_long_long"),          Self.fetch_c_Type   (+"unsigned long long"));
         Self.associate (Self.fetch_ada_Type (+"swig.unsigned_long_long_Array"),    Self.fetch_c_Type   (+"unsigned long long[]"));


         --  C 'uint8_t'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.Unsigned_8"),            Self.fetch_c_Type   (+"uint8_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.int8_t_Array"),                Self.fetch_c_Type   (+"uint8_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.int8_t_Pointer"),     Self.fetch_c_Type   (+"uint8_t*"));

         --  C 'uint16_t'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.Unsigned_16"),           Self.fetch_c_Type   (+"uint16_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.uint16_t_Array"),              Self.fetch_c_Type   (+"uint16_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.uint16_t_Pointer"),   Self.fetch_c_Type   (+"uint16_t*"));

         --  C 'uint32_t'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.Unsigned_32"),           Self.fetch_c_Type   (+"uint32_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.uint32_t_Array"),              Self.fetch_c_Type   (+"uint32_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.uint32_t_Pointer"),   Self.fetch_c_Type   (+"uint32_t*"));

         --  C 'uint64_t'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.Unsigned_64"),           Self.fetch_c_Type   (+"uint64_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.uint64_t_Array"),              Self.fetch_c_Type   (+"uint64_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.uint64_t_Pointer"),   Self.fetch_c_Type   (+"uint64_t*"));


         --  C 'intptr_t'
         --
         Self.associate (Self.fetch_ada_Type (+"swig.intptr_t"),                    Self.fetch_c_Type   (+"intptr_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.intptr_t_Array"),              Self.fetch_c_Type   (+"intptr_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.intptr_t_Pointer"),   Self.fetch_c_Type   (+"intptr_t*"));

         --  C 'uintptr_t'
         --
         Self.associate (Self.fetch_ada_Type (+"swig.uintptr_t"),                     Self.fetch_c_Type   (+"uintptr_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.uintptr_t_Array"),               Self.fetch_c_Type   (+"uintptr_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.uintptr_t_Pointer"),    Self.fetch_c_Type   (+"uintptr_t*"));


         --  char
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.char"),                        Self.fetch_c_Type   (+"char"));

         Self.associate (Self.fetch_ada_Type (+"interfaces.c.char_array"),                  Self.fetch_c_Type   (+"char[]"));
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.strings.chars_ptr"),           Self.fetch_c_Type   (+"char*"));

         Self.associate (Self.fetch_ada_Type (+"swig.pointers.chars_ptr_Array"),            Self.fetch_c_Type   (+"char*[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.chars_ptr_Pointer"),          Self.fetch_c_Type   (+"char**"));

         Self.associate (Self.fetch_ada_Type (+"swig.pointers.chars_ptr_pointer_Array"),    Self.fetch_c_Type   (+"char**[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.chars_ptr_pointer_Pointer"),  Self.fetch_c_Type   (+"char***"));

         --  unsigned char
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.unsigned_char"),               Self.fetch_c_Type   (+"unsigned char"));

         Self.associate (Self.fetch_ada_Type (+"swig.unsigned_char_Array"),                 Self.fetch_c_Type   (+"unsigned char[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.unsigned_char_Pointer"),      Self.fetch_c_Type   (+"unsigned char*"));

         Self.associate (Self.fetch_ada_Type (+"swig.pointers.unsigned_char_pointer_Array"),     Self.fetch_c_Type   (+"unsigned char*[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.unsigned_char_pointer_Pointer"),   Self.fetch_c_Type   (+"unsigned char**"));

         --  signed char
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.signed_char"),                 Self.fetch_c_Type   (+"signed char"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.signed_char_Pointer"),        Self.fetch_c_Type   (+"signed char*"));

         --  wchar_t
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.wchar_t"),                     Self.fetch_c_Type   (+"wchar_t"));
         Self.associate (Self.fetch_ada_Type (+"swig.wchar_t_Array"),                       Self.fetch_c_Type   (+"wchar_t[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.wchar_t_Pointer"),            Self.fetch_c_Type   (+"wchar_t*"));


         ---  Float
         --

         --  C 'float'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.c_float"),                   Self.fetch_c_Type (+"float"));

         Self.associate (Self.fetch_ada_Type (+"swig.float_Array"),                       Self.fetch_c_Type (+"float[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.float_Pointer"),            Self.fetch_c_Type (+"float*"));

         Self.associate (Self.fetch_ada_Type (+"swig.pointers.float_pointer_Array"),      Self.fetch_c_Type (+"float*[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.float_pointer_Pointer"),    Self.fetch_c_Type (+"float**"));

         --  C 'double'
         --
         Self.associate (Self.fetch_ada_Type (+"interfaces.c.double"),                    Self.fetch_c_Type (+"double"));

         Self.associate (Self.fetch_ada_Type (+"swig.double_Array"),                      Self.fetch_c_Type (+"double[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.double_Pointer"),           Self.fetch_c_Type (+"double*"));

         Self.associate (Self.fetch_ada_Type (+"swig.pointers.double_pointer_Array"),     Self.fetch_c_Type   (+"double*[]"));
         Self.associate (Self.fetch_ada_Type (+"swig.pointers.double_pointer_Pointer"),   Self.fetch_c_Type   (+"double**"));
      end associate_core_c_and_ada_Types;


      --  old ...
      --
      Self.add_Namespace (+"std");

      return Self;
   end Construct;


end gnat_Language.Forge;
