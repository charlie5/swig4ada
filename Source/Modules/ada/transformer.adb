with
     ada.Strings.unbounded,
     ada.Characters.handling,
     ada_Package,

     ada_type.a_subtype,
     ada_Type.elementary.an_Access.to_Type.interfaces_c_pointer,
     ada_Type.elementary.an_access.to_subProgram,
     ada_Type.elementary.scalar.discrete.enumeration,
     ada_Type.composite.a_record,
     ada_Type.composite.an_array,

     ada_Utility,
     Logger,
     doh_Support,

     GMP.discrete,
     ada_Variable,
     c_Declarable,
     c_Function,
     c_nameSpace,
     c_Parameter,
     c_Variable,

     DOHs.Pointers,

     ada.Containers.hashed_Maps,
     ada.Strings.fixed.Hash,
     ada.Strings.fixed;


package body Transformer
is
   use ada_Utility,
       Logger,
       doh_Support,
       ada.Strings.unbounded;

   function "+" (Self : in String) return unbounded_String
                 renames to_unbounded_String;


   procedure transform (From                                       : in     c_Module    .item;
                        Self                                       : in out ada_Language.item;
                        name_Map_of_c_type                         : in out c_Type     .name_Maps_of_c_type    .Map;
                        name_Map_of_ada_type                       : in out ada_Type   .name_Maps_of_ada_type  .Map;
                        c_type_Map_of_ada_type                     : in out swig_Module.c_type_Maps_of_ada_type.Map;
                        incomplete_access_to_Type_i_c_pointer_List : in out ada_Type.Vector;
                        c_type_Map_of_ada_subprogram               : in out swig_Module.c_type_Maps_of_ada_subprogram.Map;
                        new_ada_subPrograms                        : in out ada_subProgram.vector;
                        the_ada_subprogram_Map_of_c_function       : in out swig_Module.ada_subprogram_Maps_of_c_function.Map;
                        c_namespace_Map_of_ada_Package             : in out swig_Module.c_namespace_Maps_of_ada_Package.Map;

                        Result                                     :    out ada_Module.item)
   is
      function fetch_c_Type (Named : in unbounded_String) return c_Type.view
      is
      begin
         return name_Map_of_c_type.Element (Named);
      end fetch_c_Type;



      procedure make_Unique (the_Package : in ada_Package.view)
      --
      --  C is case sensitive, so two classes or typedefs may have names which differ only in case (such as 'hi0'
      --  and 'Hi0'). Their packages would have the same Ada name, and the same file, so the later one is suffixed.
      --
      is
         use ada.Characters.handling;
         use type ada_Package.view;

         function is_Taken return Boolean
         is
         begin
            for Each of Result.new_Packages
            loop
               if         Each        /= the_Package
                 and then Each.Parent  = the_Package.Parent
                 and then to_Lower (to_String (Each.ada_Name)) = to_Lower (to_String (the_Package.ada_Name))
               then
                  return True;
               end if;
            end loop;

            for Each of the_Package.Parent.Types     -- A package cannot have the name of a type of its parent, either.
            loop
               if to_Lower (to_String (Each.Name)) = to_Lower (to_String (the_Package.ada_Name))
               then
                  return True;
               end if;
            end loop;

            return False;
         end is_Taken;

         Count : Positive := 1;
      begin
         while is_Taken
         loop
            Count := Count + 1;
            the_Package.name_Suffix_is ("_" & ada.Strings.fixed.Trim (Count'Image, ada.Strings.Left));
         end loop;
      end make_Unique;



      function unique_type_Name (the_Package : in ada_Package.view;   Name : in unbounded_String) return unbounded_String
      --
      --  C is case sensitive, so two types of a package may have names which differ only in case (such as 'uint64'
      --  and 'UINT64'). The later one is suffixed.
      --
      is
         use ada.Characters.handling;
         use type ada_Package.view;

         function is_Taken (the_Name : in unbounded_String) return Boolean
         is
         begin
            for Each of the_Package.Types
            loop
               if to_Lower (to_String (Each.Name)) = to_Lower (to_String (the_Name))
               then
                  return True;
               end if;
            end loop;

            for Each of Result.new_Packages     -- A type cannot have the name of a child package, either.
            loop
               if         Each.Parent = the_Package
                 and then to_Lower (to_String (Each.ada_Name)) = to_Lower (to_String (the_Name))
               then
                  return True;
               end if;
            end loop;

            return False;
         end is_Taken;

         the_Name : unbounded_String := Name;
         Count    : Positive         := 1;
      begin
         while is_Taken (the_Name)
         loop
            Count    := Count + 1;
            the_Name := Name & "_" & ada.Strings.fixed.Trim (Count'Image, ada.Strings.Left);
         end loop;

         return the_Name;
      end unique_type_Name;



      function is_Bindable (the_c_Function : in c_Function.view) return Boolean
      --
      --  A function can only be bound when its return type and the type of each of its parameters has an Ada type.
      --  (A type may have none when it could not be resolved, such as a typedef nested in a class template.)
      --
      is
      begin
         if not c_type_Map_of_ada_type.contains (the_c_Function.return_Type)
         then
            return False;
         end if;

         for Each of the_c_Function.Parameters
         loop
            if not c_type_Map_of_ada_type.contains (Each.my_Type)
            then
               return False;
            end if;
         end loop;

         return True;
      end is_Bindable;

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

                  the_element_Type     : constant ada_Type.view := the_base_ada_Type;
                  new_ada_Array        :          ada_Type.composite.an_array.view;
               begin
                  new_ada_Array := ada_Type.composite.an_array.new_Item (the_element_Type.declaration_Package,
                                                                         the_base_ada_Type.Name & "_Array",
                                                                         the_array_dimension_upper_Bounds => [1 => ada_Type.composite.an_array.unConstrained],
                                                                         element_type                     => the_element_Type);

                  new_ada_Array.declaration_Package.add (new_ada_Array.all'Access);

                  name_Map_of_ada_type.insert (new_ada_Array.qualified_Name,
                                               new_ada_Array.all'Access);

                  dlog ("the_base_c_Type.Name: " & the_base_c_Type.Name & "[]");

                  if not c_type_Map_of_ada_type.contains (name_Map_of_c_type.Element (the_base_c_Type.Name & "[]"))     -- Two C types may share a name.
                  then
                     c_type_Map_of_ada_type.insert (name_Map_of_c_type.Element (the_base_c_Type.Name & "[]"),   -- Register the new pointer.
                                                    new_ada_Array.all'Access);
                  end if;
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
                     if    ada_Package.view (the_accessed_Type.declaration_Package) = Result.Package_top
                     then
                        return Result.Package_pointers;

                     elsif ada_Package.view (the_accessed_Type.declaration_Package) = Result.Package_pointers
                     then
                        return Result.Package_pointer_pointers;

                     else
                        return the_accessed_Type.declaration_Package.all'Access;
                     end if;
                  end declaration_Package;

                  the_Declaration_Package       : constant ada_Package.view := declaration_Package;
                  accessed_Type_is_main_type    : constant Boolean          :=     the_accessed_Type.Name = "Item";    -- Is the main type of the package.
                  the_type_Name                 :          unbounded_String;
               begin
                  --  Add type for instantiated pointer type from 'interfaces.C.pointers'.
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

                  new_ada_Type := ada_Type.elementary.an_Access.to_Type.interfaces_c_Pointer.new_Item (the_Declaration_Package,
                                                                                                       the_type_Name,
                                                                                                       accessed_type => the_accessed_Type).all'Access;
                  new_ada_Type.declaration_Package.add (new_ada_Type);

                  name_Map_of_ada_type                      .insert (new_ada_Type.qualified_Name, new_ada_Type);
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

                  new_ada_Type := ada_type.a_subType.new_subType (the_Declaration_Package,
                                                                  the_type_Name,
                                                                  base_type => new_ada_Type).all'Access;
                  new_ada_Type.declaration_Package.add (new_ada_Type);

                  if not name_Map_of_ada_type.contains (new_ada_Type.qualified_Name)     -- Two C types may share a name.
                  then
                     name_Map_of_ada_type.insert (new_ada_Type.qualified_Name, new_ada_Type);
                  end if;

                  if not c_type_Map_of_ada_type.contains (name_Map_of_c_type.Element (the_accessed_c_Type.Name & "*"))
                  then
                     c_type_Map_of_ada_type.insert (name_Map_of_c_type.Element (the_accessed_c_Type.Name & "*"),  new_ada_Type);   -- Register the new pointer.
                  end if;

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
                        dlog (+"");
                        dlog ("adding typedef: '" & the_c_Type.Name & "'      base_Type: '" & the_c_type.base_Type.Name & "'");

                        declare
                           use type ada_Package.view;
                           new_ada_Type : ada_Type.view;

                           base_Package : constant ada_Package.view
                             := ada_Package.view (c_type_Map_of_ada_type.Element (the_c_Type.base_Type).declaration_Package);
                        begin
                           if         the_c_Type.ultimate_base_Type.c_type_Kind /= c_type.c_Class
                             and then the_c_Type.ultimate_base_Type.c_type_Kind /= c_type.type_Pointer
                             and then base_Package /= Result.Package_top
                             and then c_namespace_Map_of_ada_Package.contains (c_nameSpace.view (the_c_Type.nameSpace))
                             and then c_namespace_Map_of_ada_Package.Element  (c_nameSpace.view (the_c_Type.nameSpace)) = base_Package
                           then   -- A typedef declared in a class, of a type of that class (such as one of its enumerations), is declared with it.
                              new_ada_Type := ada_type.a_subtype.new_Subtype (base_Package,
                                                                              unique_type_Name (base_Package,
                                                                                                ada_Utility.to_ada_Identifier (the_c_Type.Name)),
                                                                              c_type_Map_of_ada_type.Element (the_c_type.base_Type)).all'Access;
                              new_ada_Type.declaration_Package.add (new_ada_Type);

                           elsif     the_c_Type.ultimate_base_Type.c_type_Kind = c_type.c_Class     -- Also a typedef of a typedef of a class.
                             or else (         the_c_Type.ultimate_base_Type.c_type_Kind = c_type.type_Pointer     -- Or of a pointer.
                                      and then the_c_Type.ultimate_base_Type            /= fetch_c_Type (+"void*"))
                             or else (         ada_Package.view (c_type_Map_of_ada_type.Element (the_c_Type.base_Type).declaration_Package)        /= Result.Package_top     -- Or of a type declared in a child package
                                      and then ada_Package.view (c_type_Map_of_ada_type.Element (the_c_Type.base_Type).declaration_Package).Parent  = Result.Package_top)    -- (an enumeration of a class), which the top
                           then                                                                                                                                              -- package cannot see.
                              declare
                                 new_ada_Package  : constant ada_package.view
                                   := ada_Package.new_ada_Package (name   => to_String (ada_Utility.to_ada_Identifier (the_c_Type.Name)),
                                                                   parent => Result.Package_top);
                              begin
                                 make_Unique (new_ada_Package);
                                 Result.new_Packages.append (new_ada_Package);
                                 new_ada_Type := ada_type.a_subtype.new_Subtype (new_ada_Package,
                                                                                 +"Item",
                                                                                 c_type_Map_of_ada_type.Element (the_c_type.base_Type)).all'Access;

                                 new_ada_Type.declaration_Package.add (new_ada_Type);

                                 if         the_c_Type.ultimate_base_Type.c_type_Kind = c_type.c_Class
                                   and then name_Map_of_c_type.contains (the_c_Type.base_Type.Name & "[]")
                                   and then name_Map_of_c_type.contains (the_c_Type.base_Type.Name & "*")
                                   and then c_type_Map_of_ada_type.contains (name_Map_of_c_type.Element (the_c_Type.base_Type.Name & "[]"))
                                   and then c_type_Map_of_ada_type.contains (name_Map_of_c_type.Element (the_c_Type.base_Type.Name & "*"))
                                 then   -- The array and pointer types of a typedef of a class are subtypes of those of the class, so
                                        -- that the typedef and the class may be used interchangeably, as they may in C++. A function
                                        -- with a parameter of the typedef then overrides one with a parameter of the class.
                                    declare
                                       procedure add_Alias (Suffix : in String;   Name : in String)
                                       is
                                          own_c_Name  : constant unbounded_String := the_c_Type          .Name & Suffix;
                                          base_c_Name : constant unbounded_String := the_c_Type.base_Type.Name & Suffix;
                                       begin
                                          if         name_Map_of_c_type.contains (own_c_Name)
                                            and then name_Map_of_c_type.contains (base_c_Name)
                                            and then c_type_Map_of_ada_type.contains (name_Map_of_c_type.Element (base_c_Name))
                                          then
                                             declare
                                                the_Alias : constant ada_Type.view
                                                  := ada_Type.a_subType.new_Subtype (new_ada_Package,
                                                                                     +Name,
                                                                                     c_type_Map_of_ada_type.Element (name_Map_of_c_type.Element (base_c_Name))).all'Access;
                                             begin
                                                the_Alias.declaration_Package.add (the_Alias);

                                                name_Map_of_ada_type  .insert (the_Alias.qualified_Name,                 the_Alias);
                                                c_type_Map_of_ada_type.insert (name_Map_of_c_type.Element (own_c_Name), the_Alias);
                                             end;
                                          end if;
                                       end add_Alias;
                                    begin
                                       add_Alias ("[]",   "Item_Array");
                                       add_Alias ("*",    "Pointer");
                                       add_Alias ("*[]",  "Pointer_Array");
                                       add_Alias ("**",   "Pointer_Pointer");
                                    end;
                                 else
                                    add_array_Type_for   (new_ada_Type.all'Access, the_c_Type);
                                    add_type_Pointer_for (new_ada_Type.all'Access, the_c_Type);
                                 end if;
                              end;

                           else
                              new_ada_Type := ada_type.a_subtype.new_Subtype (Result.Package_top,
                                                                              unique_type_Name (Result.Package_top,
                                                                                                ada_Utility.to_ada_Identifier (the_c_Type.Name)),
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

                           dlog ("adding opaque struct'" & the_c_Type.Name & "'");

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
                           dlog ("adding incomplete class '" & the_c_Type.Name & "'");

                           Result.Package_top    .add    (new_ada_Type);
                           c_type_Map_of_ada_type.insert (the_c_Type, new_ada_Type);
                        end;


                     when c_type.type_Pointer =>
                        dlog (+"");
                        dlog ("adding type_Pointer '" & the_c_Type.Name & "'");

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

                              new_ada_Type.declaration_Package.add (new_ada_Type);   -- todo: Generalise this (ie move it out).

                              name_Map_of_ada_type  .insert (the_type_Name, new_ada_Type);
                              c_type_Map_of_ada_type.insert (the_c_Type,    new_ada_Type);
                           end;

                        elsif not c_type_Map_of_ada_type.contains (the_c_Type.accessed_Type)
                        then
                           log ("Warning: unable to bind the pointer type '" & the_c_Type.Name & "', as the type it points to is not known.");

                        else
                           dlog ("the_c_Type.accessed_Type:   " & the_c_Type.accessed_Type.Name);
                           dlog ("the corresponding ada Type: " & c_type_Map_of_ada_type.Element (the_c_Type.accessed_Type).Name);
                           add_type_Pointer_for (c_type_Map_of_ada_type.Element (the_c_Type.accessed_Type),
                                                 the_c_Type.accessed_Type);
                        end if;


                     when c_type.function_Pointer =>
                        dlog (+"");
                        dlog ("adding function_Pointer '" & the_c_Type.Name & "'");

                        if not is_Bindable (the_c_Type.accessed_Function.all'Access)
                        then   -- Such as a type which is declared after the first use of the function pointer.
                           log ("Warning: unable to bind the function pointer type '" & the_c_Type.Name & "', as one of its types has no Ada type.");
                        else
                           declare
                              use DOHs.Pointers;
                              use type ada_Package.view;
                              the_ada_subProgram : constant ada_subProgram.view := Self.to_ada_subProgram (the_c_type.accessed_Function.all'Access);
                              the_type_Name      : constant unbounded_String    := to_ada_Identifier (Self.to_descriptor (DOH_Pointer (to_Doh (+the_c_type.Name))));
                              new_ada_Type       :          ada_Type.view;
                           begin
                              the_ada_subProgram.Parameters := Self.to_ada_Parameters (the_c_type.accessed_Function.Parameters);

                              if        the_ada_subProgram.depends_on_any_pointer
                                or else (for some Each of the_ada_subProgram.required_Types                                            -- A type declared in a child package (a class)
                                         =>       ada_Package.view (Each.declaration_Package)        /= Result.Package_top             -- cannot be seen by the top package.
                                         and then ada_Package.view (Each.declaration_Package).Parent  = Result.Package_top)
                              then
                                 declare
                                    new_ada_Package  : constant ada_package.view := ada_Package.new_ada_Package (name   => to_String (the_type_Name),     -- The swig type made an identifier ('p_f_int_int_ret_int').
                                                                                                                 parent => Result.Package_top);
                                 begin
                                    new_ada_Type := ada_Type.elementary.an_access.to_subProgram.new_Item (new_ada_Package,
                                                                                                          +"Item",
                                                                                                          accessed_subProgram => the_ada_subProgram).all'Access;
                                    make_Unique (new_ada_Package);
                                    Result.new_Packages.append (new_ada_Package);
                                 end;
                              else
                                 new_ada_Type := ada_Type.elementary.an_access.to_subProgram.new_Item (Result.Package_top,
                                                                                                       the_type_Name,
                                                                                                       accessed_subProgram => the_ada_subProgram).all'Access;
                              end if;

                              new_ada_Type.declaration_Package.add (new_ada_Type);

                              name_Map_of_ada_type                .insert  (the_type_Name, new_ada_Type);
                              new_ada_subPrograms                 .append  (the_ada_subProgram);
                              the_ada_subprogram_Map_of_c_function.include (the_ada_subProgram, the_c_type.accessed_Function.all'Access);

                              c_type_Map_of_ada_type.insert (the_c_Type, new_ada_Type);

                              add_array_Type_for   (new_ada_Type.all'Access, the_c_Type);
                              add_type_Pointer_for (new_ada_Type.all'Access, the_c_Type);
                           end;
                        end if;


                     when c_type.typedef_Function =>
                        declare
                           the_ada_subProgram : constant ada_subProgram.view := Self.to_ada_subProgram (the_c_type.typed_Function.all'Access);
                        begin
                           the_ada_subProgram.Parameters := Self.to_ada_Parameters (the_c_type.typed_Function.Parameters);

                           c_type_Map_of_ada_subprogram        .insert  (the_c_Type, the_ada_subProgram);
                           new_ada_subPrograms                 .append  (the_ada_subProgram);
                           the_ada_subprogram_Map_of_c_function.include (the_ada_subProgram, the_c_type.typed_Function.all'Access);
                        end;


                     when c_type.c_Class =>
                        dlog (+"");
                        dlog ("adding C struct/class '" & the_c_Type.Name & "'");

                        declare
                           use ada_Type.composite.a_record;

                           --  A class which is declared in an imported module, and defined in the main module, has its
                           --  package in the main module. The imported module declares the name as an incomplete class.
                           --
                           new_ada_Package  : constant ada_package.view
                             := ada_Package.new_ada_Package (name   => to_String (to_ada_Identifier (the_c_Type.Name)),
                                                             parent => (if the_c_Type.is_defined_in_main_Module then Self.main_Package
                                                                                                                else Result.Package_top));

                           new_ada_Record   : constant ada_Type.composite.a_record.view
                             := ada_Type.composite.a_record.new_Item (new_ada_Package,
                                                                      +"Item");
                        begin
                           if the_c_Type.is_Union then
                              new_ada_Record.is_Union;
                           end if;

                           if the_c_Type.is_Virtual
                           then
                              new_ada_Record.has_virtual_Members;
                           end if;

                           if the_c_Type.has_nontrivial_Members
                           then
                              new_ada_Record.has_nontrivial_Members;
                           end if;

                           if not the_c_Type.is_layout_Pod
                           then
                              new_ada_Record.is_not_layout_Pod;
                           end if;

                           new_ada_Record.layout_Name_is (the_c_Type.layout_Name);

                           if the_c_Type.has_lost_Layout
                           then
                              new_ada_Record.lose_Layout;
                           end if;

                           new_ada_Package.add                   (new_ada_Record.all'Access);
                           new_ada_Package.models_cpp_class_Type (new_ada_Record.all'Access);

                           c_namespace_Map_of_ada_Package.insert (c_nameSpace.view (the_c_Type.Namespace), new_ada_Package);

                           add_array_Type_for   (new_ada_Record.all'Access, the_c_Type);
                           add_type_Pointer_for (new_ada_Record.all'Access, the_c_Type);

                           make_Unique (new_ada_Package);
                           Result.new_Packages   .append (new_ada_Package);
                           c_type_Map_of_ada_type.insert (the_c_Type, new_ada_Record.all'Access);
                        end;


                     when c_type.Enum =>
                        dlog (+"");
                        dlog ("adding enum '" & the_c_Type.Name & "'");

                        declare
                           use c_type.enum_literal_Vectors, GMP.discrete;

                           the_declaration_Package : constant access ada_Package.Item'Class
                             := (if c_namespace_Map_of_ada_Package.contains (c_nameSpace.view (the_c_Type.Namespace))
                                 then c_namespace_Map_of_ada_Package.Element (c_nameSpace.view (the_c_Type.Namespace))
                                 else Result.Package_top);     -- The namespace of the enumeration has no package of its own.

                           new_ada_Enumeration     : constant ada_Type.elementary.scalar.discrete.enumeration.view
                             := ada_Type.elementary.scalar.discrete.enumeration.new_Item (the_declaration_Package,
                                                                                          to_ada_Identifier (the_c_Type.Name));

                           the_c_Literals          : constant c_type.enum_literal_vectors.Vector := the_c_Type.Literals;
                           Cursor                  :          c_type.enum_literal_Vectors.Cursor := the_c_Literals.First;
                        begin
                           new_ada_Enumeration.object_Size_is (the_c_Type.enum_Size);

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
                                    use ada.Characters.handling;

                                    the_Literal : constant enum_Literal := Element (Cursor);

                                    function ada_literal_Name return unbounded_String
                                    --
                                    --  C is case sensitive, so a literal may differ only in case from the name
                                    --  of its own enumeration (such as 'enum Hello {hi, hello};'). The literal is then prefixed.
                                    --
                                    is
                                       the_Name : constant unbounded_String := ada_Utility.to_ada_Identifier (the_Literal.Name);
                                    begin
                                       if to_Lower (to_String (the_Name)) = to_Lower (to_String (new_ada_Enumeration.Name))
                                       then
                                          return "the_" & the_Name;
                                       else
                                          return the_Name;
                                       end if;
                                    end ada_literal_Name;

                                    the_literal_Name : constant unbounded_String := ada_literal_Name;
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

                                    else -- Add the literal to the enumeration.
                                       new_ada_Enumeration.add_Literal (name  => the_literal_Name,
                                                                        value => the_Literal.Value);
                                       the_literal_value_Map_of_literal_Name.insert (the_Literal.Value,
                                                                                     the_literal_Name);
                                    end if;
                                 end;

                                 next (Cursor);
                              end loop;
                           end;

                           new_ada_Enumeration.declaration_Package.add    (new_ada_Enumeration            .all'Access);
                           c_type_Map_of_ada_type                 .insert (the_c_Type, new_ada_Enumeration.all'Access);
                        end;


                     when c_type.array_Type =>
                        dlog (+"");
                        dlog ("adding array_Type '" & the_c_Type.Name & "' of element type: '" & the_c_Type.element_Type.qualified_Name & "'");

                        if not c_type_Map_of_ada_type.contains (the_c_Type.element_Type)
                        then
                           log ("Warning: unable to bind the array type '" & the_c_Type.Name & "', as its element type is not known.");

                        elsif      the_c_Type.element_Type.c_type_Kind = c_type.c_Class   -- Array of a class is already created when the class is
                          and then c_type_Map_of_ada_type.contains (the_c_Type)           -- created, to allow for Self-referential class members (see below).
                        then
                           dlog (+"Skipping array of class.");
                           null;

                        elsif      the_c_Type.element_Type.c_type_Kind = c_type.typeDef   -- Array of a class is already created when the class is
                          and then c_type_Map_of_ada_type.contains (the_c_Type)           -- created, to allow for Self-referential class members (see below).
                        then
                           dlog (+"Skipping array of 'typedef'ed class.");
                           null;

                        else
                           declare
                              use ada_Type.composite.an_array;
                              use type ada_Package.view;

                              the_ada_array_Bounds : constant ada_Type.composite.an_array.array_dimension_upper_Bounds
                                := ada_type.composite.an_array.array_dimension_upper_Bounds (the_c_Type.array_Dimensions_upper_Bound);

                              the_c_element_Type   : constant c_Type.view := the_c_Type.element_Type;
                              the_element_Type     : constant ada_Type.view := c_type_Map_of_ada_type.Element (the_c_element_Type);
                              new_ada_Array        :          ada_Type.composite.an_array.view;

                           begin
                              if         ada_Package.view (the_element_Type.declaration_Package) /= Result.Package_top
                                and then (        the_element_Type.all in ada_Type.composite.a_record.item'Class    -- Is a c class/struct which has its own package.
                                          or else the_element_Type.all in ada_Type.composite.an_array.item'Class)
                              then
                                 if are_Constrained (the_ada_array_Bounds)
                                 then  -- Place in own package.
                                    declare
                                       the_new_Package : constant ada_Package.view := ada_Package.new_ada_Package (name   => to_String (the_c_Type.Name),
                                                                                                                   parent => Result.Package_top);
                                    begin
                                       make_Unique (the_new_Package);
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
                                 declare
                                    --  The array of a type is named after the Ada name of that type, which may differ from its C name.
                                    --
                                    array_Name : constant unbounded_String
                                      := (if the_c_Type.Name = the_c_Type.element_Type.Name & "[]" then the_element_Type.Name & "_array"
                                                                                                   else to_ada_Identifier (the_c_Type.Name));
                                 begin
                                 if       the_element_Type.declaration_Package.is_Core
                                   or not From.new_c_Declarations.Contains (c_Declarable.view (the_c_Type.element_Type))
                                 then
                                    new_ada_Array := ada_Type.composite.an_array.new_Item (Result.Package_top,
                                                                                           array_Name,
                                                                                           the_array_dimension_upper_Bounds => the_ada_array_Bounds,
                                                                                           element_type                     => the_element_Type);
                                 else
                                    new_ada_Array := ada_Type.composite.an_array.new_Item (the_element_Type.declaration_Package,
                                                                                           array_Name,
                                                                                           the_array_dimension_upper_Bounds => the_ada_array_Bounds,
                                                                                           element_type                     => the_element_Type);
                                 end if;
                                 end;
                              end if;

                              new_ada_Array.declaration_Package.add (new_ada_Array.all'Access);
                              begin
                                 name_Map_of_ada_type.insert (new_ada_Array.qualified_Name,
                                                              new_ada_Array.all'Access);
                              exception
                                 when Constraint_Error =>
                                    dlog (+"");
                                    dlog ("Unable to add '" & new_ada_Array.qualified_Name & "'into the Ada type map, as it already exists there.");
                                    raise ada_Language.Aborted with "Unable to add '" & to_String (new_ada_Array.qualified_Name) & "' into the Ada type map, as it already exists there.";
                              end;
                              c_type_Map_of_ada_type.insert (the_c_Type, new_ada_Array.all'Access);
                           end;
                        end if;


                     when others =>
                        dlog ("Transformer.transform: unhandled c type Kind for : " & the_c_Type.Name & "   " & c_Type.a_c_type_Kind'Image (the_c_Type.c_type_Kind));
                        --  raise Program_Error;
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
         use c_Type.Vectors;
         Cursor : c_Type.Cursor;
      begin
         Cursor := From.new_c_Types.First;

         while has_Element (Cursor)
         loop
            declare
               use c_Type, ada_Type, ada_Type.composite.a_record;

               the_c_Type : constant c_Type.view := Element (Cursor);
            begin
               case the_c_Type.c_type_Kind
               is
                  when c_Type.c_Class =>
                     declare
                        the_ada_Record : constant ada_Type.composite.a_record.view := ada_Type.composite.a_record.view (c_type_Map_of_ada_type.Element (the_c_Type));
                     begin
                        if the_c_Type.nameSpace.models_a_virtual_cpp_Class
                        then -- Is a tagged record in Ada.
                           add_base_Classes :
                           declare
                              the_c_Bases : constant c_Type.Vector := the_c_Type.base_Classes;
                              Cursor      :          c_Type.Cursor := the_c_Bases.First;
                              has_Parent  : constant Boolean       := (for some Each of the_c_Bases => Each.is_Virtual);
                           begin
                              --  A tagged type has a single parent, which must itself be tagged. The first base class which
                              --  is virtual becomes the parent, as C++ places it first in the object. A base class which is not
                              --  virtual becomes a component, as it does for a class which is not virtual. Any further virtual
                              --  base class is ignored.
                              --
                              while has_Element (Cursor)
                              loop
                                 if not Element (Cursor).is_Virtual
                                 then
                                    --  In a type extension the component may not be where C++ has the base class (see the members
                                    --  which a derived class adds), so it only reserves storage, and 'as_<base>' reaches the base.
                                    --
                                    the_ada_Record.add_Component (ada_Variable.new_ada_Variable (  to_ada_Identifier (Element (Cursor).Name)
                                                                                                 & (if has_Parent then "_storage" else ""),
                                                                                                 c_type_Map_of_ada_type.Element (Element (Cursor))));
                                 elsif the_ada_Record.base_Classes.is_Empty
                                 then
                                    the_ada_Record.add_Base (c_type_Map_of_ada_type.Element (Element (Cursor)));
                                 else
                                    log (  "Warning: the base class '" & Element (Cursor).Name & "' of class '" & the_c_Type.Name
                                         & "' is ignored, as multiple inheritance is not supported.");

                                    --  The part of the object which is that base class still needs its storage: without it an
                                    --  object which is declared in Ada is smaller than C++ takes it to be, and its constructor
                                    --  writes beyond it. The component reserves the storage, and is not otherwise of use.
                                    --
                                    declare
                                       the_Storage : constant ada_Variable.view
                                         := ada_Variable.new_ada_Variable (to_ada_Identifier (Element (Cursor).Name) & "_storage",
                                                                           c_type_Map_of_ada_type.Element (Element (Cursor)));
                                    begin
                                       the_Storage.is_raw_Storage := True;
                                       the_ada_Record.add_Component (the_Storage);
                                    end;
                                 end if;

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
                                 if c_type_Map_of_ada_type.contains (Element (Cursor))
                                 then
                                    declare
                                       the_Base : constant ada_Variable.view
                                         := ada_Variable.new_ada_Variable (to_ada_Identifier (Element (Cursor).Name),
                                                                           c_type_Map_of_ada_type.Element (Element (Cursor)));
                                    begin
                                       the_Base.is_base_Class := True;
                                       the_ada_Record.add_Component (the_Base);
                                    end;
                                 else
                                    log (  "Warning: the base class '" & Element (Cursor).Name & "' of class '" & the_c_Type.Name
                                         & "' has no Ada type, and is left out. The layout of the record does not match that of the class.");
                                    the_ada_Record.lose_Layout;
                                 end if;

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
                              if c_type_Map_of_ada_type.contains (the_c_Components (Each).my_Type)
                              then
                                 declare
                                    the_Component : constant ada_Variable.view := Self.to_ada_Variable (the_c_Components (Each).all'Access);
                                 begin
                                    --  A member which is a class that is declared and never defined has a size which is not known.
                                    --
                                    if         the_Component.my_Type.all in ada_Type.a_subType.item'Class
                                      and then ada.Characters.handling.to_Lower (to_String (ada_Type.a_subType.view (the_Component.my_Type).base_Type.qualified_Name))
                                               in "swig.incomplete_class" | "swig.opaque_structure"
                                    then
                                       log (  "Warning: the member '" & the_c_Components (Each).Name & "' of class '" & the_c_Type.Name
                                            & "' is of a class which is not defined, so its size is not known. The layout of the record does not match that of the class.");
                                       the_ada_Record.lose_Layout;
                                    end if;

                                    --  A component of a type extension may not be where C++ has its member (see 'memberVariableHandler'
                                    --  in 'ada_Language'), so it only reserves storage, and is named to say so. The member has functions.
                                    --
                                    if         not the_ada_Record.base_Classes.is_Empty
                                      and then not the_c_Components (Each).is_ignored_Member     -- Which is named so already.
                                    then
                                       the_Component.Name := the_Component.Name & "_storage";
                                    end if;

                                    the_ada_Record.add_Component (the_Component);
                                 end;
                              else
                                 log (  "Warning: the member '" & the_c_Components (Each).Name & "' of class '" & the_c_Type.Name
                                      & "' has a type which is not known, and is left out. The layout of the record does not match that of the class.");
                                 the_ada_Record.lose_Layout;
                              end if;
                           end loop;
                        end add_Components;


                        add_Functions :
                        declare
                           use c_function.Vectors;
                           the_c_Functions  : constant c_Function.Vector := the_c_Type.nameSpace.Subprograms;
                           Cursor           :          c_function.Cursor := the_c_Functions.First;
                           unbound_Count    :          Natural           := 0;
                        begin
                           while has_Element (Cursor)
                           loop
                              if is_Bindable (Element (Cursor))
                              then
                                 declare
                                    the_c_Function     : constant c_Function.view     := Element (Cursor);
                                    the_ada_subProgram : constant ada_subProgram.view := Self.to_ada_subProgram (the_c_Function);
                                    is_Overridable     :          Boolean             := True;
                                 begin
                                    the_ada_subProgram.Parameters := Self.to_ada_Parameters (the_c_function.Parameters);

                                    --  C is case sensitive, so a member function may differ only in case from a type which is
                                    --  declared in the class (a function 'mode' and a typedef 'Mode'). The function is prefixed.
                                    --
                                    if (for some Each of the_ada_Record.declaration_Package.Types
                                        =>   ada.Characters.handling.to_Lower (to_String (Each.Name))
                                           = ada.Characters.handling.to_Lower (to_String (the_ada_subProgram.Name)))
                                    then
                                       the_ada_subProgram.Name := "the_" & the_ada_subProgram.Name;
                                    end if;

                                    if the_c_Function.is_Overriding
                                    then
                                       --  C++ allows a function which overrides to return a pointer or reference to a class derived
                                       --  from that returned by the function it overrides. In Ada the two results must be of the
                                       --  same type, so the result type of the overridden function is used.
                                       --
                                       declare
                                          use ada_Type.Vectors;
                                          use type ada.Containers.Count_type;

                                          the_Class  : ada_Type.composite.a_record.view := the_ada_Record;
                                          is_Found   : Boolean                          := False;
                                          is_Unknown : Boolean                          := False;     -- The functions of a class in an imported
                                       begin                                                          -- module are not collected.
                                          while    not is_Found
                                            and then not the_Class.base_Classes.is_Empty
                                          loop
                                             the_Class := ada_Type.composite.a_record.view (the_Class.base_Classes.first_Element);

                                             if the_Class.declaration_Package.Subprograms.is_Empty
                                             then
                                                is_Unknown := True;
                                             end if;

                                             for Each of the_Class.declaration_Package.Subprograms
                                             loop
                                                if         Each.Name              = the_ada_subProgram.Name
                                                  and then Each.Parameters.Length = the_ada_subProgram.Parameters.Length
                                                then
                                                   the_ada_subProgram.return_Type := Each.return_Type;
                                                   is_Found                       := True;
                                                   exit;
                                                end if;
                                             end loop;
                                          end loop;

                                          is_Overridable := is_Found or is_Unknown;
                                       end;
                                    end if;

                                    if is_Overridable
                                    then
                                       the_ada_Record.declaration_Package.add (the_ada_subProgram);
                                    else
                                       --  The function which is overridden could not be bound, so there is nothing to override.
                                       --  Declared as a new function, it would take a further slot in the vtable.
                                       --
                                       log (  "Warning: unable to bind the function '" & the_c_Function.Name & "' of class '" & the_c_Type.Name
                                            & "', as the function which it overrides is not bound.");
                                    end if;
                                 end;

                              elsif      Element (Cursor).is_Virtual
                                and then not Element (Cursor).is_Overriding
                                and then not Element (Cursor).Parameters.is_Empty
                              then
                                 --  A virtual function has a slot in the C++ vtable, whether or not it can be bound. A primitive
                                 --  operation with only the 'Self' parameter stands in for it, so that the slots which follow
                                 --  keep their place. (A function which overrides needs none, as it has the slot of its parent.)
                                 --
                                 declare
                                    use c_Parameter.Vectors;

                                    the_c_Function     : constant c_Function.view := Element (Cursor);
                                    the_self_Parameter :          c_Parameter.Vector;
                                    the_ada_subProgram :          ada_subProgram.view;
                                 begin
                                    unbound_Count      := unbound_Count + 1;
                                    the_ada_subProgram := ada_subProgram.new_ada_subProgram
                                                            (+("unbound_virtual_" & ada.Strings.fixed.Trim (unbound_Count'Image, ada.Strings.Left)),
                                                             c_type_Map_of_ada_type.Element (fetch_c_Type (+"void")));

                                    the_self_Parameter.append (the_c_Function.Parameters.first_Element);

                                    the_ada_subProgram.Parameters  := Self.to_ada_Parameters (the_self_Parameter);
                                    the_ada_subProgram.is_Virtual  := True;
                                    the_ada_subProgram.is_Abstract := the_c_Function.is_Abstract;
                                    the_ada_subProgram.link_Symbol := +"unbound";

                                    the_ada_Record.declaration_Package.add (the_ada_subProgram);

                                    log (  "Warning: unable to bind the virtual function '" & the_c_Function.Name & "' of class '" & the_c_Type.Name
                                         & "', as one of its types is not known. '" & the_ada_subProgram.Name & "' holds its place.");
                                 end;

                              else
                                 log (  "Warning: unable to bind the function '" & Element (Cursor).Name & "' of class '" & the_c_Type.Name
                                      & "', as one of its types is not known.");
                              end if;

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
         use c_Variable.Vectors;
         Cursor : c_Variable.Cursor := From.new_c_Variables.First;
      begin
         while has_Element (Cursor)
         loop
            declare
               use c_type;
               use type ada_Package.view;

               the_c_Variable   : constant c_Variable.view := Element (Cursor);
               the_ada_Variable :          ada_Variable.view;
            begin
               if not c_type_Map_of_ada_type.contains (the_c_Variable.my_Type)
               then
                  log ("Warning: unable to bind the variable '" & the_c_Variable.Name & "', as its type is not known.");

               elsif      the_c_Variable.owner_Class /= null
                 and then not c_type_Map_of_ada_type.contains (the_c_Variable.owner_Class)
               then
                  log (  "Warning: unable to bind the static member variable '" & the_c_Variable.Name
                       & "', as its class '" & the_c_Variable.owner_Class.Name & "' is not bound.");
               else
                  the_ada_Variable := Self.to_ada_Variable (the_c_Variable);

                  if         the_c_Variable.owner_Class /= null     -- A static member variable is declared in the package of its class.
                    and then c_type_Map_of_ada_type.contains (the_c_Variable.owner_Class)
                  then
                     ada_Package.view (c_type_Map_of_ada_type.Element (the_c_Variable.owner_Class).declaration_Package).add (the_ada_Variable);

                  elsif     the_c_Variable.my_Type.c_type_Kind = C_Class
                    or else (         ada_Package.view (the_ada_Variable.my_Type.declaration_Package)        /= Result.Package_top     -- The top package cannot see
                             and then ada_Package.view (the_ada_Variable.my_Type.declaration_Package).Parent  = Result.Package_top)    -- its own child packages.
                    or else (         the_ada_Variable.is_Constant                                                              -- A constant pointer to a function
                             and then the_ada_Variable.my_Type.resolved_Type.all                                                -- has a function of the binding
                                      in ada_Type.elementary.an_access.to_subProgram.item'Class)                               -- package as its value.
                  then
                     Result.Package_binding.add (the_ada_Variable);
                  else
                     Result.Package_top    .add (the_ada_Variable);
                  end if;
               end if;
            end;

            next (Cursor);
         end loop;
      end add_ada_Variable_for_each_c_Variable;


      add_ada_subProgram_for_each_c_Function :
      declare
         use c_Function.Vectors;
         Cursor : c_Function.Cursor := From.new_c_Functions.First;
      begin
         while has_Element (Cursor)
         loop
            if is_Bindable (Element (Cursor))
            then
               declare
                  the_c_Function     : constant c_Function.view     := Element (Cursor);
                  the_ada_subProgram : constant ada_subProgram.view := Self.to_ada_subProgram (the_c_Function);
               begin
                  the_ada_subProgram.Parameters := Self.to_ada_Parameters (the_c_Function.Parameters);
                  Result.Package_binding.add (the_ada_subProgram);
               end;
            else
               log ("Warning: unable to bind the function '" & Element (Cursor).Name & "', as one of its types is not known.");
            end if;

            next (Cursor);
         end loop;
      end add_ada_subProgram_for_each_c_Function;

   end transform;


end Transformer;
