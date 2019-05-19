with
     ada.Strings.unbounded,
     ada_Package,

     ada_type.a_subtype,
     ada_Type.elementary.an_access.to_type.interfaces_c_pointer,
     ada_Type.elementary.an_access.to_subProgram,
     ada_Type.elementary.scalar.discrete.enumeration,
     ada_Type.composite.a_record,
     ada_Type.composite.an_array,

     ada_Utility,
     doh_Support,

     GMP.discrete,
     ada_Variable,
     c_Declarable,
     c_Function,
     c_Variable,

     DOHs.Pointers,

     ada.Containers.hashed_Maps,
     ada.Strings.fixed.Hash;


package body Transformer
is
   use ada_Utility,
       doh_Support,
       ada.Strings.unbounded;



   function "+" (Self : in String) return unbounded_String
                 renames to_unbounded_String;



   procedure transform (From                                       : in     c_Module     .item;
                        Self                                       : in out ada_Language.item;

                        name_Map_of_c_type                         : in out c_Type.               name_Maps_of_c_type  .Map;
                        name_Map_of_ada_type                       : in out ada_Type.             name_Maps_of_ada_type.Map;
                        c_type_Map_of_ada_type                     : in out swig_Module.        c_type_Maps_of_ada_type.Map;
                        incomplete_access_to_Type_i_c_pointer_List : in out ada_Type.      Vector;
                        c_type_Map_of_ada_subprogram               : in out swig_Module.        c_type_Maps_of_ada_subprogram.Map;
                        new_ada_subPrograms                        : in out ada_subProgram.Vector;
                        the_ada_subprogram_Map_of_c_function       : in out swig_Module.ada_subprogram_Maps_of_c_function .Map;
                        c_namespace_Map_of_ada_Package             : in out swig_Module.   c_namespace_Maps_of_ada_Package.Map;

                        Result                                     :    out ada_Module.item)
   is
      function fetch_c_Type (Named : in unbounded_String) return c_Type.view
      is
      begin
         return name_Map_of_c_type.Element (Named);
      end fetch_c_Type;

   begin
      add_ada_Type_for_each_c_Type :
      declare
         use c_type.Vectors;

         function "<" (Left, Right : c_Type.view) return Boolean
         is
         begin
            if Right.depends_directly_on (Left.all'Access) then
               return True;

            elsif Left.depends_directly_on (Right.all'Access) then
               return False;

            else
               return False;
               return Left.Name < Right.Name;
            end if;
         end "<";
         pragma Unreferenced ("<");

         Cursor : c_type.Cursor;
      begin
         Cursor := From.new_c_Types.First;

         while has_Element (Cursor)
         loop
            declare
               use c_Type, ada_Type;

               the_c_Type : constant c_Type.view := Element (Cursor);


               procedure add_array_Type_for (the_base_ada_Type : in ada_Type.view;
                                             the_base_c_Type   : in c_Type  .view)
               is
                  use ada_type.composite.an_array;

                  the_element_Type     : constant ada_Type.view                   := the_base_ada_Type;
                  new_ada_Array        :          ada_Type.composite.an_array.view;
               begin
                  new_ada_Array := ada_Type.composite.an_array.new_Item (the_element_Type.declaration_Package,
                                                                         the_base_ada_Type.Name & "s",  -- Pluralise.    "_array",    -- +"Items",
                                                                         the_array_dimension_upper_Bounds => (1 => ada_Type.composite.an_array.unConstrained),
                                                                         element_type                     => the_element_Type);

                  new_ada_Array.declaration_Package.add (new_ada_Array.all'Access);

                  name_Map_of_ada_type  .insert (new_ada_Array.qualified_Name,                              new_ada_Array.all'Access);

                  log ("the_base_c_Type.Name: " & the_base_c_Type.Name & "[]");

                  c_type_Map_of_ada_type.insert (name_Map_of_c_type.Element (the_base_c_Type.Name & "[]"),  new_ada_Array.all'Access);     -- Register the new pointer.
               end add_array_Type_for;


               function new_pointer_Type_for (the_accessed_Type   : in ada_Type.view;
                                              the_accessed_c_Type : in c_Type.view;
                                              level_2_indirection : in Boolean) return ada_Type.view
               is
                  use type ada_Package.view;
                  new_ada_Type : ada_Type.view;

                  function declaration_Package return ada_package.view
                  is
                  begin
                     if    the_accessed_Type.declaration_Package = Result.Package_top
                     then
                        return Result.Package_pointers;

                     elsif the_accessed_Type.declaration_Package = Result.Package_pointers
                     then
                        return Result.Package_pointer_pointers;

                     else
                        return the_accessed_Type.declaration_Package.all'Access;
                     end if;
                  end declaration_Package;

                  the_Declaration_Package       : constant ada_Package.view := declaration_Package;
                  accessed_Type_is_main_type    : constant Boolean          :=     the_accessed_Type.Name = "Item";    -- is the main type of the package
                  the_type_Name                 :          unbounded_String;
               begin
                  --  add type for instantiated pointer type from 'interfaces.c.pointers'
                  --
                  if accessed_Type_is_main_type
                  then
                     if level_2_indirection then   the_type_Name := +"pointer_Pointers.Pointer";
                     else                          the_type_Name := +"Pointers.Pointer";
                     end if;
                  else
                     if level_2_indirection then   the_type_Name := the_accessed_Type.Name & "_Pointers.Pointer";
                     else                          the_type_Name := the_accessed_Type.Name & "_Pointers.Pointer";
                     end if;
                  end if;

                  new_ada_Type := ada_Type.elementary.an_Access.to_Type.interfaces_c_Pointer.new_Item (the_Declaration_Package,   -- the_accessed_Type.declaration_Package,
                                                                                                       the_type_Name,
                                                                                                       accessed_type => the_accessed_Type).all'Access;
                  new_ada_Type.declaration_Package.add (new_ada_Type);

                  name_Map_of_ada_type                      .insert (new_ada_Type.qualified_Name,  new_ada_Type);
                  incomplete_access_to_Type_i_c_pointer_List.append (new_ada_Type);

                  --  Add 'subtype renaming' for the above instantiated pointer.
                  --
                  if accessed_Type_is_main_type
                  then
                     if level_2_indirection then   the_type_Name := +"pointer_Pointer";
                     else   the_type_Name := +"Pointer";
                     end if;
                  else
                     if level_2_indirection then   the_type_Name := the_accessed_Type.Name & "_Pointer";
                     else                          the_type_Name := the_accessed_Type.Name & "_Pointer";
                     end if;
                  end if;

                  new_ada_Type := ada_type.a_subType.new_subType (the_Declaration_Package,   -- The_accessed_Type.declaration_Package.
                                                                  the_type_Name,
                                                                  base_type => new_ada_Type).all'Access;
                  new_ada_Type.declaration_Package.add (new_ada_Type);

                  name_Map_of_ada_type  .insert (new_ada_Type.qualified_Name,                                  new_ada_Type);
                  c_type_Map_of_ada_type.insert (name_Map_of_c_type.Element (the_accessed_c_Type.Name & "*"),  new_ada_Type);   -- Register the new pointer.

                  return new_ada_Type;
               end new_pointer_Type_for;


               procedure add_type_Pointer_for (the_accessed_Type : in ada_Type.view;   the_accessed_c_Type : in c_Type.view)
               is
                  the_accessed_c_Type_Pointer : constant c_Type.view   := fetch_c_Type         (the_accessed_c_Type.Name & "*");
                  new_ada_Type                :          ada_Type.view := new_pointer_Type_for (the_accessed_Type,
                                                                                                the_accessed_c_Type,
                                                                                                level_2_indirection => False);
               begin
                  if not (         the_accessed_c_Type_Pointer.c_type_Kind               = type_Pointer
                          and then the_accessed_c_Type_Pointer.accessed_Type.c_type_Kind = type_Pointer)
                  then
                     add_array_Type_for (new_ada_Type,
                                         the_accessed_c_Type_Pointer);

                     new_ada_Type := new_pointer_Type_for (new_ada_Type,
                                                           the_accessed_c_Type_Pointer,
                                                           level_2_indirection => True);
                  end if;
               end add_type_Pointer_for;

            begin
               if        the_c_Type.is_Ignored
                 or else c_type_Map_of_ada_type.contains (the_c_Type)
               then
                  null;
               else
                  case the_c_Type.c_type_Kind
                  is
                     when c_type.Typedef =>
                        log (+"");
                        log ("adding typedef: '" & the_c_Type.Name & "'      base_Type: '" & the_c_type.base_Type.Name & "'");

                        declare
                           new_ada_Type : ada_Type.view;
                        begin
                           if        the_c_Type.base_Type.c_type_Kind = c_type.c_Class
                             or else (         the_c_Type.base_Type.c_type_Kind = c_type.type_Pointer
                                      and then the_c_Type.base_Type            /= fetch_c_Type (+"void*"))
                           then
                              declare
                                 new_ada_Package  : constant ada_package.view
                                   := ada_Package.new_ada_Package (name   => to_String (ada_Utility.to_ada_Identifier (the_c_Type.Name)),
                                                                   parent => Result.Package_top);
                              begin
                                 Result.new_Packages.append (new_ada_Package);
                                 new_ada_Type := ada_type.a_subtype.new_Subtype (new_ada_Package,
                                                                                 +"Item",
                                                                                 c_type_Map_of_ada_type.Element (the_c_type.base_Type)).all'Access;

                                 new_ada_Type.declaration_Package.add (new_ada_Type);

                                 add_array_Type_for   (new_ada_Type.all'Access, the_c_Type);
                                 add_type_Pointer_for (new_ada_Type.all'Access, the_c_Type);
                              end;

                           else
                              new_ada_Type := ada_type.a_subtype.new_Subtype (Result.Package_top,
                                                                              ada_Utility.to_ada_Identifier  (the_c_Type.Name),
                                                                              c_type_Map_of_ada_type.Element (the_c_type.base_Type)).all'Access;
                              new_ada_Type.declaration_Package.add (new_ada_Type);
                           end if;

                           c_type_Map_of_ada_type.insert (the_c_Type, new_ada_Type);
                        end;


                     when c_type.opaque_Struct =>
                        declare
                           new_ada_Type : ada_Type.view;
                        begin
                           new_ada_Type := ada_type.a_subtype.new_Subtype (Result.Package_top,
                                                                           ada_Utility.to_ada_Identifier (the_c_Type.Name),
                                                                           name_Map_of_ada_type.Element (+"swig.opaque_structure")).all'Access;

                           log ("adding opaque struct'" & the_c_Type.Name & "'");

                           Result.Package_top    .add    (new_ada_Type);
                           c_type_Map_of_ada_type.insert (the_c_Type, new_ada_Type);
                        end;


                     when c_type.incomplete_Class =>
                        declare
                           new_ada_Type : ada_Type.view;
                        begin
                           new_ada_Type := ada_type.a_subtype.new_Subtype (Result.Package_top,
                                                                           ada_Utility.to_ada_Identifier (the_c_Type.Name),
                                                                           name_Map_of_ada_type.Element (+"swig.incomplete_class")).all'Access;
                           log ("adding incomplete class '" & the_c_Type.Name & "'");

                           Result.Package_top    .add    (new_ada_Type);
                           c_type_Map_of_ada_type.insert (the_c_Type, new_ada_Type);
                        end;


                     when c_type.type_Pointer =>
                        log (+"");
                        log ("adding type_Pointer '" & the_c_Type.Name & "'");

                        if        the_c_Type.accessed_Type.c_type_Kind = c_type.c_Class
                          or else (         the_c_Type.accessed_Type.          c_type_Kind = c_type.typeDef
                                   and then the_c_Type.accessed_Type.base_Type.c_type_Kind = c_type.c_Class)
                        then
                           null;   -- Pointer to a class is already created when the class is created, to allow for Self-referential class members (see below).

                        elsif the_c_Type.accessed_Type.c_type_Kind = c_type.typedef_Function
                        then
                           declare
                              use swig_Module.c_type_Maps_of_ada_subprogram;
                              the_ada_subProgram : constant ada_subProgram.view := c_type_Map_of_ada_subprogram.Element (the_c_type.accessed_Type);
                              the_type_Name      : constant unbounded_String    := ada_Utility.to_ada_Identifier        (the_c_type.Name); --  & "_Pointer";
                              new_ada_Type       :          ada_Type.view;
                           begin
                              new_ada_Type := ada_Type.elementary.an_access.to_subProgram.new_Item (Result.Package_top,
                                                                                                    the_type_Name,
                                                                                                    accessed_subProgram => the_ada_subProgram).all'Access;

                              new_ada_Type.declaration_Package.add (new_ada_Type);   -- tbd: generalise this (ie move it out)

                              name_Map_of_ada_type  .insert (the_type_Name,  new_ada_Type);
                              c_type_Map_of_ada_type.insert (the_c_Type,     new_ada_Type);
                           end;

                        else
                           log ("the_c_Type.accessed_Type:   " & the_c_Type.accessed_Type.Name);
                           log ("the corresponding ada Type: " & c_type_Map_of_ada_type.Element (the_c_Type.accessed_Type).Name);
                           add_type_Pointer_for (c_type_Map_of_ada_type.Element (the_c_Type.accessed_Type),
                                                 the_c_Type.accessed_Type);
                        end if;


                     when c_type.function_Pointer =>
                        log (+"");
                        log ("adding function_Pointer '" & the_c_Type.Name & "'");

                        declare
                           use DOHs.Pointers;
                           the_ada_subProgram : constant ada_subProgram.view := Self.       to_ada_subProgram (the_c_type.accessed_Function.all'Access);
                           the_type_Name      : constant unbounded_String    := ada_Utility.to_ada_Identifier (Self.to_descriptor (DOH_Pointer (to_Doh (to_String (the_c_type.Name)))));
                           new_ada_Type       :          ada_Type.view;
                        begin
                           the_ada_subProgram.Parameters := Self.to_ada_Parameters (the_c_type.accessed_Function.Parameters);

                           if the_ada_subProgram.depends_on_any_pointer
                           then
                              declare
                                 new_ada_Package  : constant ada_package.view := ada_Package.new_ada_Package (name   => to_String (ada_Utility.to_ada_Identifier (the_c_Type.Name)),
                                                                                                              parent => Result.Package_top);
                              begin
                                 new_ada_Type := ada_Type.elementary.an_access.to_subProgram.new_Item (new_ada_Package,
                                                                                                       +"Item",  -- the_type_Name,
                                                                                                       accessed_subProgram => the_ada_subProgram).all'Access;
                                 Result.new_Packages.append (new_ada_Package);
                              end;

                           else
                              new_ada_Type := ada_Type.elementary.an_access.to_subProgram.new_Item (Result.Package_top,
                                                                                                    the_type_Name,
                                                                                                    accessed_subProgram => the_ada_subProgram).all'Access;
                           end if;

                           new_ada_Type.declaration_Package.add (new_ada_Type);

                           name_Map_of_ada_type                .insert  (the_type_Name,  new_ada_Type);
                           new_ada_subPrograms                 .append  (the_ada_subProgram);
                           the_ada_subprogram_Map_of_c_function.include (the_ada_subProgram, the_c_type.accessed_Function.all'Access);

                           c_type_Map_of_ada_type.insert (the_c_Type, new_ada_Type);

                           add_array_Type_for   (new_ada_Type.all'Access, the_c_Type);
                           add_type_Pointer_for (new_ada_Type.all'Access, the_c_Type);
                        end;


                     when c_type.typedef_Function =>
                        declare
                           the_ada_subProgram : constant ada_subProgram.view := Self.to_ada_subProgram (the_c_type.typed_Function.all'Access);
                        begin
                           the_ada_subProgram.Parameters := Self.to_ada_Parameters (the_c_type.typed_Function.Parameters);

                           c_type_Map_of_ada_subprogram        .insert  (the_c_Type,  the_ada_subProgram);
                           new_ada_subPrograms                 .append  (the_ada_subProgram);
                           the_ada_subprogram_Map_of_c_function.include (the_ada_subProgram, the_c_type.typed_Function.all'Access);
                        end;


                     when c_type.c_Class =>
                        log (+"");
                        log ("adding C struct/class '" & the_c_Type.Name & "'");

                        declare
                           use ada_Type.composite.a_record;
                           new_ada_Package  : constant ada_package.view                 := ada_Package.new_ada_Package (name   => to_String (ada_Utility.to_ada_Identifier (the_c_Type.Name)),
                                                                                                                        parent => Result.Package_top);
                           new_ada_Record   : constant ada_Type.composite.a_record.view := ada_Type.composite.a_record.new_Item (new_ada_Package,
                                                                                                                                 +"Item");
                        begin
                           if the_c_Type.is_Union then
                              new_ada_Record.is_Union;
                           end if;

                           new_ada_Package.add                   (new_ada_Record.all'Access);
                           new_ada_Package.models_cpp_class_Type (new_ada_Record.all'Access);

                           c_namespace_Map_of_ada_Package.insert (the_c_Type.Namespace, new_ada_Package);

                           add_array_Type_for   (new_ada_Record.all'Access, the_c_Type);
                           add_type_Pointer_for (new_ada_Record.all'Access, the_c_Type);

                           Result.new_Packages   .append (new_ada_Package);
                           c_type_Map_of_ada_type.insert (the_c_Type, new_ada_Record.all'Access);
                        end;


                     when c_type.Enum =>
                        log (+"");
                        log ("adding enum '" & the_c_Type.Name & "'");

                        declare
                           use c_type.enum_literal_Vectors, GMP.discrete;

                           the_declaration_Package : constant access ada_Package.Item'Class
                             := c_namespace_Map_of_ada_Package.Element (the_c_Type.Namespace);

                           new_ada_Enumeration     : constant ada_Type.elementary.scalar.discrete.enumeration.view
                             := ada_Type.elementary.scalar.discrete.enumeration.new_Item (the_declaration_Package, -- From.Package_top,
                                                                                          ada_Utility.to_ada_Identifier (the_c_Type.Name));

                           the_c_Literals          : constant c_type.enum_literal_vectors.Vector := the_c_Type.Literals;
                           Cursor                  :          c_type.enum_literal_Vectors.Cursor := the_c_Literals.First;
                        begin
                           declare
                              function Hash (From : in gmp.discrete.Integer) return ada.Containers.Hash_Type
                              is
                              begin
                                 return ada.Strings.Fixed.Hash (Image (From));
                              end Hash;

                              package literal_value_Maps_of_literal_Name is new ada.Containers.hashed_Maps (gmp.discrete.Integer,
                                                                                                            unbounded_String,
                                                                                                            Hash,
                                                                                                            "=");
                              the_literal_value_Map_of_literal_Name : literal_value_Maps_of_literal_Name.Map;
                           begin
                              while has_Element (Cursor)
                              loop
                                 declare
                                    the_Literal      : constant enum_Literal     := Element (Cursor);
                                    the_literal_Name : constant unbounded_String := ada_Utility.to_ada_Identifier (the_Literal.Name);
                                 begin
                                    if the_literal_value_Map_of_literal_Name.Contains (the_Literal.Value)
                                    then   -- Transform the duplicate valued literal to a constant enumeration variable.
                                       declare
                                          use ada_Variable;
                                          the_ada_Variable : constant ada_Variable.view
                                            := new_ada_Variable (the_literal_Name,
                                                                 ada_Type.view (new_ada_Enumeration),
                                                                 the_literal_value_Map_of_literal_Name.Element (the_Literal.Value));
                                       begin
                                          the_declaration_Package.add (the_ada_Variable);
                                       end;

                                    else   -- Add the literal to the enumeration.
                                       new_ada_Enumeration.add_Literal (name  => the_literal_Name,
                                                                        value => the_Literal.Value);
                                       the_literal_value_Map_of_literal_Name.insert (the_Literal.Value,
                                                                                     the_literal_Name);
                                    end if;
                                 end;

                                 next (Cursor);
                              end loop;
                           end;

                           new_ada_Enumeration.declaration_Package.add    (new_ada_Enumeration.all'Access);
                           c_type_Map_of_ada_type                 .insert (the_c_Type, new_ada_Enumeration.all'Access);
                        end;


                     when c_type.array_Type =>
                        log (+"");
                        log ("adding array_Type '" & the_c_Type.Name & "' of element type: '" & the_c_Type.element_Type.qualified_Name & "'");

                        if         the_c_Type.element_Type.c_type_Kind = c_type.c_Class   -- Array of a class is already created when the class is
                          and then c_type_Map_of_ada_type.contains (the_c_Type)           -- created, to allow for Self-referential class members (see below).
                        then
                           log (+"Skipping array of class.");
                           null;

                        elsif      the_c_Type.element_Type.c_type_Kind = c_type.typeDef   -- Array of a class is already created when the class is
                          and then c_type_Map_of_ada_type.contains (the_c_Type)           -- created, to allow for Self-referential class members (see below).
                        then
                           log (+"Skipping array of 'typedef'ed class.");
                           null;

                        else
                           declare
                              use ada_type.composite.an_array;

                              the_ada_array_Bounds : constant ada_type.composite.an_array.array_dimension_upper_Bounds
                                := ada_type.composite.an_array.array_dimension_upper_Bounds (the_c_Type.array_Dimensions_upper_Bound);

                              the_element_Type     : constant ada_Type.view                   := c_type_Map_of_ada_type.Element (the_c_Type.element_Type);
                              new_ada_Array        :          ada_Type.composite.an_array.view;

                           begin
                              if         the_element_Type.declaration_Package /= Result.Package_top
                                and then (        the_element_Type.all in ada_Type.composite.a_record.item'Class    -- Is a c class/struct which has its own package.
                                          or else the_element_Type.all in ada_Type.composite.an_array.item'Class)
                              then
                                 if are_Constrained (the_ada_array_Bounds)
                                 then  -- Place in own package.
                                    declare
                                       the_new_Package : constant ada_package.view := ada_Package.new_ada_Package (name   => to_String (the_c_Type.Name),
                                                                                                                   parent => Result.Package_top);
                                    begin
                                       Result.new_Packages.append (the_new_Package);
                                       new_ada_Array := ada_Type.composite.an_array.new_Item (the_new_Package,
                                                                                              +"Item",
                                                                                              the_array_dimension_upper_Bounds => the_ada_array_Bounds,
                                                                                              element_type                     => the_element_Type);
                                    end;
                                 else
                                    new_ada_Array := ada_Type.composite.an_array.new_Item (the_element_Type.declaration_Package,
                                                                                           +"Items",
                                                                                           the_array_dimension_upper_Bounds => the_ada_array_Bounds,
                                                                                           element_type                     => the_element_Type);
                                 end if;

                              else
                                 if       the_element_Type.declaration_Package.is_Core
                                   or not From.new_c_Declarations.Contains (c_Declarable.view (the_c_Type.element_Type))
                                 then
                                    new_ada_Array := ada_Type.composite.an_array.new_Item (Result.Package_top,
                                                                                           ada_Utility.to_ada_Identifier (the_c_Type.Name),
                                                                                           the_array_dimension_upper_Bounds => the_ada_array_Bounds,
                                                                                           element_type                     => the_element_Type);
                                 else
                                    new_ada_Array := ada_Type.composite.an_array.new_Item (the_element_Type.declaration_Package,
                                                                                           ada_Utility.to_ada_Identifier (the_c_Type.Name),
                                                                                           the_array_dimension_upper_Bounds => the_ada_array_Bounds,
                                                                                           element_type                     => the_element_Type);
                                 end if;
                              end if;

                              new_ada_Array.declaration_Package.add (new_ada_Array.all'Access);
                              begin
                                 name_Map_of_ada_type  .insert (new_ada_Array.qualified_Name,  new_ada_Array.all'Access);
                              exception
                                 when Constraint_Error =>
                                    log (+"");
                                    log ("Unable to add '" & new_ada_Array.qualified_Name & "'into the Ada type map, as it already exists there.");
                                    raise ada_Language.Aborted;
                              end;
                              c_type_Map_of_ada_type.insert (the_c_Type, new_ada_Array.all'Access);
                           end;
                        end if;


                     when others =>
                        log ("unhandled c type Kind for : " & the_c_Type.Name & "   " & c_type.a_c_type_Kind'Image (the_c_Type.c_type_Kind));
                        raise Program_Error;
                  end case;

               end if;
            end;

            next (Cursor);
         end loop;
      end add_ada_Type_for_each_c_Type;


      --  Pass 2: Fill in class members, now that an ada type exists for each c type.
      --
      add_ada_Type_for_each_c_Type_pass_2 :
      declare
         use c_type.Vectors;
         Cursor : c_type.Cursor;
      begin
         Cursor := From.new_c_Types.First;

         while has_Element (Cursor)
         loop
            declare
               use c_Type, ada_Type, ada_Type.composite.a_record;

               the_c_Type   : constant c_Type.view := Element (Cursor);
            begin
               case the_c_Type.c_type_Kind
               is
                  when c_type.c_Class =>
                     declare
                        the_ada_Record : constant ada_Type.composite.a_record.view := ada_Type.composite.a_record.view (c_type_Map_of_ada_type.Element (the_c_Type));
                     begin
                        if the_c_Type.nameSpace.models_a_virtual_cpp_Class
                        then   -- Is a tagged record in Ada.
                           add_base_Classes :
                           declare
                              the_c_Bases : constant c_Type.Vector := the_c_Type.base_Classes;
                              Cursor      :          c_Type.Cursor := the_c_Bases.First;
                           begin
                              while has_Element (Cursor)
                              loop
                                 the_ada_Record.add_Base (c_type_Map_of_ada_type.Element (Element (Cursor)));

                                 next (Cursor);
                              end loop;
                           end add_base_Classes;

                        else
                           transform_base_Classes_to_record_Components :
                           declare
                              the_c_Bases : constant c_Type.Vector := the_c_Type.base_Classes;
                              Cursor      :          c_Type.Cursor := the_c_Bases.First;
                           begin
                              while has_Element (Cursor)
                              loop
                                 the_ada_Record.add_Component (ada_Variable.new_ada_Variable (ada_Utility.to_ada_Identifier (Element (Cursor).Name),
                                                               c_type_Map_of_ada_type.Element (Element (Cursor))));

                                 next (Cursor);
                              end loop;
                           end transform_base_Classes_to_record_Components;
                        end if;


                        add_Components :
                        declare
                           the_c_Components : constant c_type.record_Components := the_c_Type.Components;
                        begin
                           for Each in the_c_Components'Range
                           loop
                              the_ada_Record.add_Component (Self.to_ada_Variable (the_c_Components (Each).all'Access));
                           end loop;
                        end add_Components;


                        add_Functions :
                        declare
                           use c_function.Vectors;
                           the_c_Functions  : constant c_Function.Vector := the_c_Type.nameSpace.Subprograms;
                           Cursor           :          c_function.Cursor := the_c_Functions.First;
                        begin
                           while has_Element (Cursor)
                           loop
                              declare
                                 the_c_Function     : constant c_Function.view     := Element (Cursor);
                                 the_ada_subProgram : constant ada_subProgram.view := Self.to_ada_subProgram (the_c_Function);
                              begin
                                 the_ada_subProgram.Parameters := Self.to_ada_Parameters (the_c_function.Parameters);
                                 the_ada_Record.declaration_Package.add (the_ada_subProgram);
                              end;

                              next (Cursor);
                           end loop;
                        end add_Functions;
                     end;

                  when others =>
                     null;
               end case;
            end;

            next (Cursor);
         end loop;
      end add_ada_Type_for_each_c_Type_pass_2;


      add_ada_Variable_for_each_c_Variable :
      declare
         use c_variable.Vectors;
         Cursor : c_variable.Cursor := From.new_c_Variables.First;
      begin
         while has_Element (Cursor)
         loop
            declare
               use c_type;

               the_c_Variable   : constant c_Variable.view := Element (Cursor);
               the_ada_Variable :          ada_Variable.view;
            begin
               the_ada_Variable := Self.to_ada_Variable (the_c_variable);

               if the_c_Variable.my_Type.c_type_Kind = C_Class
               then
                  Result.Package_binding.add (the_ada_Variable);
               else
                  Result.Package_top    .add (the_ada_Variable);
               end if;
            end;

            next (Cursor);
         end loop;
      end add_ada_Variable_for_each_c_Variable;


      add_ada_subProgram_for_each_c_Function :
      declare
         use c_function.Vectors;
         Cursor : c_function.Cursor := From.new_c_Functions.First;
      begin
         while has_Element (Cursor)
         loop
            declare
               the_c_Function     : constant c_Function.view     := Element (Cursor);
               the_ada_subProgram : constant ada_subProgram.view := Self.to_ada_subProgram (the_c_Function);
            begin
               the_ada_subProgram.Parameters := Self.to_ada_Parameters (the_c_Function.Parameters);
               Result.Package_binding.add (the_ada_subProgram);
            end;

            next (Cursor);
         end loop;
      end add_ada_subProgram_for_each_c_Function;

   end transform;


end Transformer;
