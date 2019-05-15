with
     c_Variable;


--  old ...
--
with c_nameSpace;              use c_nameSpace;
with ada_Utility;              use ada_Utility;

with ada.Characters.handling;   use ada.Characters.handling;
with c_Function;


package body c_Type
is
   use enum_literal_Vectors,
       GMP.discrete;



   -----------
   --  Globals
   --

   NL : constant String := new_line_Token;

   function "+" (Self : in String) return  ada.strings.Unbounded.Unbounded_String
     renames ada.strings.Unbounded.To_Unbounded_String;



   ---------
   --  Forge
   --

   function virtual_class_Pointer_construct (nameSpace           : access c_nameSpace.item'class := null;
                                             Name                : in     unbounded_String       := null_unbounded_String;
                                             base_Type           : in     c_Type.view) return c_Type.item
   is
   begin
      return (c_declarable.item with My => (c_type_Kind       => virtual_class_Pointer,
                                            nameSpace         => nameSpace,
                                            Name              => Name,
                                            import_Convention => Unknown,
                                            ignore            => False,
--                                               my_view_Type        => my_view_Type,
--                                               my_array_Type       => my_array_Type,
                                            pointee_Type      => base_Type,
                                            resolved_Type     => null));
   end virtual_class_Pointer_construct;



   function new_virtual_class_Pointer (nameSpace : access c_nameSpace.item'class := null;
                                       Name      : in     unbounded_String       := null_unbounded_String;
                                       base_Type : in     c_Type.view) return c_Type.view
   is
   begin
      return new c_Type.item'(virtual_class_Pointer_construct (nameSpace,  Name,  base_Type));
   end new_virtual_class_Pointer;




   function Typedef_construct (nameSpace : access c_nameSpace.item'class := null;
                               Name      : in     unbounded_String       := null_unbounded_String;
                               base_Type : in     c_Type.view) return c_Type.item
   is
   begin
      return (c_declarable.item with My => (c_type_Kind         => Typedef,
                                            nameSpace           => nameSpace,
                                            Name                => Name,
                                            import_Convention   => Unknown,
                                            ignore              => False,
                                            base_Type           => base_Type,
                                            resolved_Type       => null));
   end Typedef_construct;


   function new_Typedef (nameSpace : access c_nameSpace.item'class := null;
                         Name                : in unbounded_String  := null_unbounded_String;
                         base_Type           : in c_Type.view) return c_Type.view
   is
   begin
      return new c_Type.item'(Typedef_construct (nameSpace,  Name,  base_Type));
   end new_Typedef;




   function new_type_Pointer (nameSpace : access c_nameSpace.item'class := null;
                              Name                : in unbounded_String  := null_unbounded_String;
                              accessed_Type       : in c_Type.view) return c_Type.view
   is
   begin
      return new c_Type.item'(c_declarable.item with My => (c_type_Kind         => type_Pointer,
                                                            nameSpace           => nameSpace,
                                                            Name                => Name,
                                                            import_Convention   => Unknown,
                                                            accessed_Type       => accessed_Type,
                                                            others              => <>));
   end new_type_Pointer;




   function new_function_Pointer (nameSpace : access c_nameSpace.item'class := null;
                                  Name                : in unbounded_String  := null_unbounded_String;
                                  accessed_Function   : access c_Function.item'class) return c_Type.view
   is
   begin
      return new c_Type.item'(c_declarable.item with My => (c_type_Kind         => function_Pointer,
                                                            nameSpace           => nameSpace,
                                                            Name                => Name,
                                                            accessed_Function   => accessed_Function,
                                                            others              => <>));
   end new_function_Pointer;




   function new_typedef_Function (nameSpace      : access c_nameSpace.item'class := null;
                                  Name           : in     unbounded_String       := null_unbounded_String;
                                  typed_Function : access c_Function.item'class) return c_Type.view
   is
   begin
      return new c_Type.item'(c_declarable.item with My => (c_type_Kind         => typedef_Function,
                                                            nameSpace           => nameSpace,
                                                            Name                => Name,
                                                            typed_function      => typed_Function,
                                                            others              => <>));
   end new_typedef_Function;




   function new_array_Type       (nameSpace : access c_nameSpace.item'class := null;
                                  Name                : in unbounded_String  := null_unbounded_String;
                                  element_Type        : in c_Type.view)       return c_Type.view
   is
   begin
      return new c_Type.item'(c_declarable.item with My => (c_type_Kind         => array_Type,
                                                            nameSpace           => nameSpace,
                                                            Name                => Name,
                                                            element_Type        => element_Type,
                                                            others              => <>));
   end new_array_Type;




   function new_standard_c_Type (nameSpace : access c_nameSpace.item'class;
                                 Name                : in unbounded_String) return c_Type.view
   is
   begin
      return new c_Type.item'(c_declarable.item with My => (c_type_Kind         => standard_c_Type,
                                                            nameSpace           => nameSpace,
                                                            Name                => Name,
                                                            import_Convention   => Unknown,
                                                            others              => <>));
   end new_standard_c_Type;





   function c_opaque_Struct_construct    (nameSpace : access c_nameSpace.item'class;
                                          Name                : in unbounded_String) return c_Type.item
   is
   begin
      return c_Type.item'(c_declarable.item with My => (c_type_Kind         => opaque_Struct,
                                                        nameSpace           => nameSpace,
                                                        Name                => Name,
                                                        import_Convention   => Unknown,
                                                        others              => <>));
   end c_opaque_Struct_construct;




   function new_opaque_Struct    (nameSpace : access c_nameSpace.item'class;
                                  Name                : in unbounded_String) return c_Type.view
   is
   begin
      return new c_Type.item'(c_declarable.item with My => (c_type_Kind         => opaque_Struct,
                                                            nameSpace           => nameSpace,
                                                            Name                => Name,
                                                            import_Convention   => Unknown,
                                                            others              => <>));
   end new_opaque_Struct;




   function c_incomplete_Class_construct (nameSpace : access c_nameSpace.item'class;
                                          Name      : in     unbounded_String) return c_Type.item
   is
   begin
      return c_Type.item'(c_declarable.item with My => (c_type_Kind         => incomplete_Class,
                                                        nameSpace           => nameSpace,
                                                        Name                => Name,
                                                        import_Convention   => Unknown,
                                                        others              => <>));
   end c_incomplete_Class_construct;




   function new_incomplete_Class (nameSpace : access c_nameSpace.item'class;
                                  Name                : in unbounded_String) return c_Type.view
   is
   begin
      return new c_Type.item'(c_declarable.item with My => (c_type_Kind         => incomplete_Class,
                                                            nameSpace           => nameSpace,
                                                            Name                => Name,
                                                            import_Convention   => Unknown,
                                                            others              => <>));
   end new_incomplete_Class;




   function Enum_construct (nameSpace : access c_nameSpace.item'Class;
                            Name                : in unbounded_String) return c_Type.item
   is
   begin
      return (c_declarable.item with My => (c_type_Kind         => Enum,
                                            nameSpace           => nameSpace,
                                            Name                => Name,
                                            import_Convention   => Unknown,
                                            others              => <>));
   end Enum_construct;




   function new_Enum (nameSpace : access c_nameSpace.item'class;
                      Name                : in unbounded_String) return c_Type.view
   is
   begin
      return new c_Type.item'(Enum_construct (nameSpace,  Name));
   end new_Enum;




   function c_Class_construct (nameSpace : access c_nameSpace.item'Class;
                               Name      : in     unbounded_String) return c_Type.item
   is
   begin
      return (c_declarable.item with My => (c_type_Kind         => c_Class,
                                            nameSpace           => new_c_nameSpace (to_String (Name),  nameSpace.all'Access),
                                            Name                => Name,
                                            import_Convention   => Unknown,
                                            others              => <>));
   end c_Class_construct;



   function new_c_Class (nameSpace : access c_nameSpace.item'Class;
                         Name      : in      unbounded_String) return c_Type.view
   is
   begin
      return new c_Type.item'(c_Class_construct (nameSpace,  Name));
   end new_c_Class;





   function new_unknown_Type return c_Type.view    -- nb: Returned object is *mutable*.
   is
   begin
      return new c_Type.item;   -- Default is a mutable object of c_type_Kind 'Unknown'.
   end new_unknown_Type;




   --------------
   --  Attributes
   --


   -----------
   --  General
   --

   function c_type_Kind (Self : access Item) return a_c_type_Kind
   is
   begin
      return Self.my.c_type_Kind;
   end c_type_Kind;



   procedure Name_is (Self : access Item;
                      Now  : in     unbounded_String)
   is
   begin
      Self.my.Name := Now;

   end Name_is;



   overriding
   function Name (Self : access Item) return unbounded_String
   is
   begin
      return Self.my.Name;
   end Name;



   function qualified_Name (Self : access Item) return unbounded_String
   is
   begin
--        case Self.my.c_type_Kind is
--
--           when Unknown =>
--              return "<unknown_type>." & Self.my.Name;
--
--
--           when others =>

--        if         Self.my.c_type_Kind = Typedef
--          and then Self.nameSpace.is_Import
--          and then Self.my.base_Type.my.resolved_Type /= null
--        then
--           return Self.my.base_Type.my.resolved_Type.qualified_Name;
--        else
--           log ("myName: '" & Self.my.Name & "'");

      if Self.my.nameSpace = null
      then
         log (+"Null nameSpace !");
      end if;

      if Self.my.nameSpace.Name = "std"
      then
         return Self.my.Name;
      else
         return Self.my.nameSpace.qualified_Name & "." & Self.my.Name;
      end if;

--        end if;

--        end case;
   end qualified_Name;




   procedure nameSpace_is (Self : access Item;
                                     Now  : access c_nameSpace.item'class)
   is
   begin
      Self.my.nameSpace := Now;
   end nameSpace_is;



   function nameSpace (Self : access Item) return access c_nameSpace.item'class
   is
   begin
      return Self.my.nameSpace;
   end nameSpace;



   function is_Ignored (Self : access Item) return Boolean
   is
   begin
      return Self.my.Ignore;
   end is_Ignored;


   procedure ignore    (Self : access Item)
   is
   begin
      Self.my.Ignore := True;
   end ignore;



   procedure import_Convention_is (Self : access Item;   Now : in an_import_Convention)
   is
   begin
      Self.my.import_Convention := Now;
   end import_Convention_is;



   function my_import_Convention (Self : access Item) return an_import_Convention
   is
   begin
      return Self.my.import_Convention;
   end my_import_Convention;
   pragma Unreferenced (my_import_Convention);




--     procedure my_view_Type_is         (Self : access Item;   Now : in c_Type.view)
--     is
--     begin
--        Self.my.my_view_Type := Now;
--     end;
--
--
--
--     function  my_view_Type            (Self : access Item)                                 return c_Type.view
--     is
--     begin
--        return Self.my.my_view_Type;
--     end;
--
--
--
--
--     procedure my_array_Type_is         (Self : access Item;   Now : in c_Type.view)
--     is
--     begin
--        Self.my.my_array_Type := Now;
--     end;
--
--
--
--     function  my_array_Type            (Self : access Item)                                 return c_Type.view
--     is
--     begin
--        return Self.my.my_array_Type;
--     end;



   function ultimate_base_Type (Self : access Item) return c_Type.view
   is
   begin
      --  log ("'ultimate_base_Type' ~ c_type_Kind: '" & a_c_type_kind'Image (Self.my.c_type_Kind) & "'");
      case Self.my.c_type_Kind
      is
         when array_Type
            | opaque_Struct
            | incomplete_Class
            | standard_c_Type
            | function_Pointer
            | typedef_Function
            | type_Pointer
            | c_Class
            | Enum
            | virtual_class_Pointer
            | Unknown =>

            return Self.all'Access;

         when Typedef =>
            return Self.my.base_Type.ultimate_base_Type;
      end case;
   end ultimate_base_Type;




   function is_ultimately_Unsigned (Self : access Item) return Boolean
   is
   begin
      return Index (to_Lower (Self.ultimate_base_type.Name), "unsigned") /= 0;
   end is_ultimately_Unsigned;




   procedure resolved_Type_is (Self : access Item;   Now : in c_Type.view)
   is
   begin
      Self.my.resolved_Type := Now;
   end resolved_Type_is;




   function resolved_Type (Self : access Item) return c_Type.view   -- tbd: move this into 'Language' ... its app code !!
   is
   begin
      --  log ("'ultimate_base_Type' ~ c_type_Kind: '" & a_c_type_kind'Image (Self.my.c_type_Kind) & "'");
      if Self.nameSpace.Kind = header_Import
      then
         case Self.my.c_type_Kind
         is
            when opaque_Struct
               | incomplete_Class
               | standard_c_Type
               | function_Pointer
               | typedef_Function
               | c_Class
               | Enum                  -- tbd: when moved to 'Language', make 'Enum' type resolve to interface.c.Int
               | Unknown =>

               return Self.all'Access;

            when type_Pointer =>
               return Self.my.accessed_Type.resolved_Type;
--                 return Self.my.accessed_Type.resolved_Type.my_view_Type;

            when array_Type =>
               return Self.my.element_Type.resolved_Type;
--                 return Self.my.element_Type.resolved_Type.my_array_Type;

            when Typedef =>
               return Self.my.base_Type.resolved_Type;

            when virtual_class_Pointer =>
               return Self.my.pointee_Type.resolved_Type;
         end case;

      else
         return Self.all'Access;
      end if;
   end resolved_Type;




   function  context_required_Type (Self : access Item) return c_Type.view
   is
   begin
      case Self.my.c_type_Kind
      is
         when opaque_Struct
            | incomplete_Class
            | standard_c_Type
            | function_Pointer
            | typedef_Function
            | c_Class
            | Enum                  -- tbd: when moved to 'Language', make 'Enum' type resolve to interface.c.Int
            | Unknown =>

            return Self.all'Access;

         when type_Pointer =>
            return Self.my.accessed_Type;

         when array_Type =>
            return Self.my.element_Type;

         when Typedef =>
            return Self.my.base_Type;

         when virtual_class_Pointer =>
            return null; -- Self.my.base_Type;
      end case;
   end context_required_Type;



   overriding
   function  depended_on_Declarations (Self : access Item) return c_Declarable.views
   is
      use c_Declarable;
   begin
--        log ("c_type.depended_on_Declarations ~ Self.Name: '" & Self.name & "'");
      case Self.my.c_type_Kind
      is
         when array_Type =>
            return   Self.my.element_Type.all'Access
                   & Self.my.element_Type.depended_on_Declarations;

         when c_Class =>
            declare
               the_Types : c_declarable.views (1 .. 500);
               Count     : Natural := 0;
            begin
               for Each in 1 .. Self.my.component_Count
               loop
                  if not (         Self.my.Components (Each).my_Type.c_type_Kind   = type_Pointer     -- Detect and ignore a Self-referential pointer.
                          and then Self.my.Components (Each).my_Type.accessed_Type = Self)            --
                  then
                     declare
                        my_type_Dependencies : constant c_Declarable.views := Self.my.Components (Each).my_Type.depended_on_Declarations;
                     begin
                        Count             := Count + 1;
                        the_Types (Count) := Self.my.Components (Each).my_Type.all'Access;

                        the_Types (Count + 1 .. Count + my_type_Dependencies'Length)
                                          := my_type_Dependencies;
                        Count             := Count + my_type_Dependencies'Length;
                     end;
--                       Count := Count + 1;
--                       the_Types (Count) := Self.my.Components (Each).my_Type.all'access;
                  end if;
               end loop;

               return the_Types (1 .. Count);
            end;

         when opaque_Struct
            | incomplete_Class
            | Enum
            | standard_c_Type
            | Unknown          =>

            return (1 .. 0 => <>);    -- No types are required.


         when function_Pointer =>
            return   Self.my.accessed_Function.all'Access
                   & Self.my.accessed_Function.depended_on_Declarations;

         when typedef_Function =>
            return   Self.my.typed_Function.all'Access
                   & Self.my.typed_Function.depended_on_Declarations;


         when type_Pointer =>
            return   Self.my.accessed_Type.all'Access
                   & Self.my.accessed_Type.depended_on_Declarations;


         when Typedef =>
            return   Self.my.base_Type.all'Access
                   & Self.my.base_Type.depended_on_Declarations;


         when virtual_class_Pointer =>
            return (1 .. 0 => <>);    -- No types are required.

--           when Unknown =>
--              raise Program_Error;
      end case;
   end depended_on_Declarations;



   overriding
   function required_Types (Self : access Item) return c_declarable.c_Type_views
   is
   begin
      case Self.my.c_type_Kind
      is
         when array_Type =>
            return (1 => Self.my.element_Type);

         when c_Class =>
            declare
               the_Types : c_declarable.c_Type_views (1 .. Self.my.component_Count);
               Count     : Natural := 0;
            begin
               for Each in the_Types'Range
               loop
--                    log ("JJJJJJJJJJJJJJJJJJ: " & Self.my_view_type.qualified_Name & "     " & Self.my.Components (Each).my_Type.resolved_Type.qualified_Name);

--                    if Self.my.Components (Each).my_Type.resolved_Type /= my_view_Type (Self) then   -- detect and ignore a Self-referential pointer

                  if         Self.my.Components (Each).my_Type.c_type_Kind   = type_Pointer   -- Detect and ignore a Self-referential pointer.
                    and then Self.my.Components (Each).my_Type.accessed_Type = Self           --
                  then
                     Count := Count + 1;
                     the_Types (Count) := Self.my.Components (Each).my_Type.resolved_Type;
                     --  the_Types (Each) := Self.my.Components (Each).my_Type;
                  end if;
               end loop;

               return the_Types (1 .. Count);
            end;

         when opaque_Struct
            | incomplete_Class
            | Enum
            | standard_c_Type
            | Unknown          =>
            return (1 .. 0 => <>);    -- No types are required.

         when function_Pointer =>
            return Self.my.accessed_Function.required_Types;

         when typedef_Function =>
            return Self.my.typed_Function.required_Types;

         when type_Pointer =>
            return (1 => Self.my.accessed_Type);

         when Typedef =>
            return (1 => Self.my.base_Type);

         when virtual_class_Pointer =>
            return (1 .. 0 => <>);    -- No types are required.

--           when Unknown =>
--              raise Program_Error;
      end case;
   end required_Types;



   overriding
   function depends_on (Self : access Item;   a_Declarable : in c_Declarable.view) return Boolean
   is
   begin
--      log ("c_type.depends_on ~ Self.Name: '" & Self.name & "'     a_Declarable.Name: '" & a_Declarable.Name & "'");
      raise Program_Error;

      case Self.my.c_type_Kind is

         when array_Type =>

            return    Self.my.element_Type.all'Access = a_Declarable
              or else Self.my.element_Type.depends_on (a_Declarable);


         when c_Class =>
            declare
               the_component_Type : c_Type.view;
            begin
               for Each in 1 .. Self.my.component_Count loop
                  the_component_Type := Self.my.Components (Each).my_Type;

                  if not (the_component_Type.c_type_Kind = type_Pointer   -- detect and ignore a Self-referential pointer
                          and then the_component_Type.accessed_Type = Self)         --
                  then
--                       log ("the_component_Type.Name: '" & the_component_Type.Name & "'   a_Declarable.Name: '" & a_Declarable.Name & "'");
                     if        the_component_Type.all'Access = a_Declarable
                       or else the_component_Type.depends_on (a_Declarable)
                     then
                        return True;
                     end if;
                  else
                     null; -- log ("Self referential class pointer detected !");
                  end if;

               end loop;

               return False;
            end;


         when opaque_Struct
            | incomplete_Class
            | Enum
            | standard_c_Type
            | Unknown          =>

            return False;


         when function_Pointer =>

            return    Self.my.accessed_Function.all'Access = a_Declarable
              or else Self.my.accessed_Function.depends_on (a_Declarable);

         when typedef_Function =>

            return    Self.my.typed_Function.all'Access = a_Declarable
              or else Self.my.typed_Function.depends_on (a_Declarable);


         when type_Pointer =>

            return    Self.my.accessed_Type.all'Access = a_Declarable
              or else Self.my.accessed_Type.depends_on (a_Declarable);


         when Typedef =>

            return    Self.my.base_Type.all'Access = a_Declarable
              or else Self.my.base_Type.depends_on (a_Declarable);


         when virtual_class_Pointer =>

            return False;


--           when Unknown =>
--              raise Program_Error;

      end case;

   end depends_on;



   overriding
   function depends_directly_on (Self : access Item;   a_Declarable : in     c_Declarable.view) return Boolean
   is
   begin
--      log ("c_type.depends_on ~ Self.Name: '" & Self.name & "'     a_Declarable.Name: '" & a_Declarable.Name & "'");
      case Self.my.c_type_Kind
      is
         when array_Type =>
            return Self.my.element_Type.all'Access = a_Declarable;

         when c_Class =>
            declare
               the_component_Type : c_Type.view;
            begin
               for Each in 1 .. Self.my.component_Count
               loop
                  the_component_Type := Self.my.Components (Each).my_Type;

                  if not (         the_component_Type.c_type_Kind   = type_Pointer      -- Detect and ignore a Self-referential pointer.
                          and then the_component_Type.accessed_Type = Self)             --
                  then
--                       log ("the_component_Type.Name: '" & the_component_Type.Name & "'   a_Declarable.Name: '" & a_Declarable.Name & "'");
                     if the_component_Type.all'Access = a_Declarable
                     then
                        return True;
                     end if;
                  else
                     null; -- log ("Self referential class pointer detected !");
                  end if;
               end loop;

               return False;
            end;

         when opaque_Struct
            | incomplete_Class
            | Enum
            | standard_c_Type
            | Unknown          =>
            return False;

         when function_Pointer =>
            return    Self.my.accessed_Function.all'Access = a_Declarable;

         when typedef_Function =>
            return    Self.my.typed_Function.all'Access = a_Declarable;

         when type_Pointer =>
            return    Self.my.accessed_Type.all'Access = a_Declarable;

         when Typedef =>
            return    Self.my.base_Type.all'Access = a_Declarable;

         when virtual_class_Pointer =>
            return False;

--           when Unknown =>
--              raise Program_Error;
      end case;
   end depends_directly_on;




   overriding
   function  directly_depended_on_Declarations (Self : access Item) return c_Declarable.views
   is
      use c_Declarable;
   begin
--      log ("c_type.depends_on ~ Self.Name: '" & Self.name & "'     a_Declarable.Name: '" & a_Declarable.Name & "'");
      case Self.my.c_type_Kind
      is
         when array_Type =>
            return    (1 => Self.my.element_Type.all'Access);

         when c_Class =>
            declare
--                 the_component_Type           : c_Type.view;
               the_depended_on_Declarations : c_Declarable.views (1 .. Self.my.component_Count);
            begin
               for Each in the_depended_on_Declarations'Range
               loop
                  the_depended_on_Declarations (Each) := Self.my.Components (Each).my_Type.all'Access;

--                    the_component_Type := Self.my.Components (Each).my_Type;
--
--                    if not (         the_component_Type.c_type_Kind = type_Pointer   -- detect and ignore a Self-referential pointer
--                            and then the_component_Type.accessed_Type = Self)         --
--                    then
--  --                       log ("the_component_Type.Name: '" & the_component_Type.Name & "'   a_Declarable.Name: '" & a_Declarable.Name & "'");
--                       if the_component_Type.all'access = a_Declarable then
--                          return True;
--                       end if;
--                    else
--                       null; -- log ("Self referential class pointer detected !");
--                    end if;
               end loop;

               return the_depended_on_Declarations;
            end;

         when opaque_Struct
            | incomplete_Class
            | Enum
            | standard_c_Type
            | Unknown          =>
            return (1 .. 0 => <>);

         when function_Pointer =>
            return   Self.my.accessed_Function.all'Access
                   & Self.my.accessed_Function.directly_depended_on_Declarations;
--              return    (1 => Self.my.accessed_Function.all'access);

         when typedef_Function =>
            return   Self.my.typed_Function.all'Access
                   & Self.my.typed_Function.directly_depended_on_Declarations;
--              return    (1 => Self.my.typed_Function.all'access);

         when type_Pointer =>
            return (1 => Self.my.accessed_Type.all'Access);

         when Typedef =>
            return (1 => Self.my.base_Type.all'Access);

         when virtual_class_Pointer =>
            return (1 .. 0 => <>);

--           when Unknown =>
--              raise Program_Error;
      end case;
   end directly_depended_on_Declarations;



--     function depends_on (Self   : access Item;
--                          a_Type : in     c_Type.view)    return Boolean
--     is
--        my_Depends : c_Type.views := Self.required_Types;
--     begin
--
--        for Each in my_Depends'range loop
--           if my_Depends (Each) = a_Type then
--              return True;
--           end if;
--        end loop;
--
--        return False;
--     end;



   procedure verify (Self : access Item)
   is
   begin
--      log ("verifying type: '" & Self.my.Name & "'");
      Self.my.Name := to_ada_Identifier (Self.my.Name);

      case Self.my.c_type_Kind
      is
         when array_Type
            | opaque_Struct
            | incomplete_Class
            | standard_c_Type
            | function_Pointer
            | typedef_Function
            | virtual_class_Pointer =>
--            | Typedef =>
            null;

         when type_Pointer =>
--              log ("H1");
--
--  --              log ("me resolved : '" & Self.my.resolved_Type.Name & "'");
--  --
--  --
--  --              if  Self.nameSpace.Kind = header_Import then null; end if;   log ("H2");
--  --              if  Self.my.accessed_type.my.resolved_Type = null then log ("NULLLLL"); end if; log ("H3");
--  --              if  Self.my.accessed_type.my.resolved_type.c_type_Kind = standard_c_Type then null; end if;  log ("H4");
--
--              if          Self.nameSpace.Kind          = header_Import
--                 and then Self.my.resolved_Type /= null then
--                 log ("k1");
--                 log ("Self.my.resolved_Type Name: '" & Self.my.resolved_Type.Name & "'");
--              end if;
--
--
--              --
--              if          Self.nameSpace.Kind          = header_Import
--                 and then Self.my.accessed_type.my.resolved_Type /= null then
--                 log ("H2");
--                 log ("Self.my.accessed_type Kind: '" & a_c_type_Kind'Image (Self.my.accessed_type.c_type_Kind) & "'");
--                 log ("Self.my.accessed_type.my.resolved_Type Name: '" & Self.my.accessed_type.my.resolved_Type.Name & "'");
--              end if;
--
--
--              if         Self.nameSpace.Kind                       = header_Import
--                and then Self.my.accessed_type.my.resolved_Type             /= null
--                and then Self.my.accessed_type.my.resolved_type.c_type_Kind  = standard_c_Type
--              then
--                 log ("resolving unknown type for type_pointer");
--                 Self.My := Self.my.accessed_type.my.resolved_type.my_view_Type.My;                   --
--              end if;
            null;

         when Typedef =>
--              if         Self.nameSpace.Kind = header_Import
--                and then Self.my.resolved_Type /= null
--                and then Self.my.resolved_Type.c_type_Kind = standard_c_Type
--              then
--                 log ("resolving unknown type");
--
--  --               if Self.my.resolved_type.my.my_view_Type /= null then
--
--  --                    Self.my.my_view_Type.My  := Self.my.resolved_type.my.my_view_Type.My;   -- nb: order is important !
--  --  --                    Self.my.my_view_Type.My  := Self.my.base_type.my.resolved_type.my.my_view_Type.My;   -- nb: order is important !
--  --  --                    Self.my.my_array_Type.My := Self.my.resolved_type.my.my_array_Type.My;  --
--  --
--                    Self.My                  := Self.my.resolved_type.My;                   --
--  --                  Self.My                  := Self.my.base_Type.my.resolved_type.My;                   --
--  --               end if;
--
--              end if;
            null;

         when Unknown =>
--              if Self.my.resolved_Type /= null then
--                 --Self.nameSpace.is_Unknown;
--                 log ("resolving unknown type");
--
--
--                 Self.my.my_view_Type.My  := Self.my.resolved_type.my.my_view_Type.My;
--                 Self.my.my_array_Type.My := Self.my.resolved_type.my.my_array_Type.My;
--                 Self.My                  := Self.my.resolved_type.My;
--              end if;
            null;

         when c_Class =>
            transform_non_virtual_base_Classes_to_record_Components :
            declare
               use c_variable, c_Type.Vectors;
               Cursor   : c_Type.Cursor := Last (Self.my.base_Classes);      -- we go in reverse so the order is correct using prepend (below).
               the_Base : c_Type.view;
            begin
               while has_Element (Cursor)
               loop
                  the_Base := Element (Cursor);

                  if not is_Virtual (the_Base)
                  then
                     delete   (Self.my.base_Classes, Cursor);
                     Cursor := Last (Self.my.base_Classes);

                     Self.my.component_Count                           := Self.my.component_Count + 1;                            -- prepend the base type
                     Self.my.Components (2 .. Self.my.component_Count) := Self.my.Components (1 .. Self.my.component_Count - 1);  --
                     Self.my.Components (1)                            := new_c_Variable (name => +"kkk", -- the_Base.my.nameSpace.Name & "_base",
                                                                                          of_type => null); -- the_Base);
                  else
                     previous (Cursor);
                  end if;
               end loop;
            end transform_non_virtual_base_Classes_to_record_Components;

            --  Correct component Identifier names.
            --
            for Each in 1 .. Self.my.component_Count
            loop
               Self.my.Components (Each).Name := to_ada_Identifier (Self.my.Components (Each).Name);
            end loop;

            --  Detect if 'use' of interfaces.c.int or unsigned, is required.
            --
            for Each in 1 .. Self.my.component_Count
            loop
               if Self.my.Components (Each).bit_Field /= -1
               then
                  --  log ("RRRRRRRRRRRRRRRRR: '" & Self.my.Components (Each).my_Type.Name & "'");
                  if Self.my.Components (Each).my_Type.qualified_Name = "interfaces.c.Int"
                  then
                     Self.my.requires_Interfaces_C_Int_use := True;

                  elsif Self.my.Components (Each).my_Type.qualified_Name = "interfaces.c.Unsigned"
                  then
                     Self.my.requires_Interfaces_C_Unsigned_use := True;

                  elsif Self.my.Components (Each).my_Type.qualified_Name = "interfaces.c.unsigned_Char"
                  then
                     Self.my.requires_Interfaces_C_Unsigned_use := True;

                  elsif Self.my.Components (Each).my_Type.qualified_Name = "interfaces.c.extensions.bool"
                  then
                     Self.my.requires_Interfaces_C_Extensions_bool_use := True;
                  end if;
               end if;
            end loop;

         when Enum =>
            for Each in 1 .. Natural (Length (Self.my.Literals))
            loop
               replace_Element (Self.my.Literals,  Each, (name  => to_ada_Identifier (Element (Self.my.Literals,  Each).Name),
                                                          value => Element (Self.my.Literals,  Each).Value));
            end loop;

            correct_any_name_Clash :
            declare
               Clash_found : Boolean := False;       -- Occurs when any of an enun's literals matches its name (disregarding case).
            begin

               for Each in 1 .. Natural (Length (Self.my.Literals))
               loop
                  if to_Lower (to_String (Element (Self.my.Literals,  Each).Name))  =   to_Lower (to_String (Self.my.Name))
                  then
                     Clash_found := True;
                  end if;
               end loop;

               if Clash_found
               then
                  append (Self.my.Name, "_enum");
               end if;
            end correct_any_name_Clash;

            sort_Literals :
            declare
               function less_than (Left, Right : enum_Literal) return Boolean is begin   return left.Value < right.Value;   end less_than;

               package Sorter is new enum_literal_vectors.generic_Sorting ("<" => less_than);
            begin
               Sorter.sort (Self.my.Literals);
            end sort_Literals;

--           when Unknown  =>
--              raise Program_Error;
      end case;
   end verify;



--     function c_Class_public_declaration_Text (Self : access Item) return String
--     is
--        use c_Type.Vectors;
--        use ada.Containers;
--
--        the_Source              : unbounded_String;
--        union_variant_type_Name : unbounded_String := Self.my.Name & "_variant";
--     begin
--
--        append (the_Source,  NL  &  "type "  &  Self.my.Name);
--
--        if Self.my.is_Union then
--           append (the_Source,  " (union_Variant : " &  union_variant_type_Name & " := " & union_variant_type_Name & "'First)");
--        end if;
--
--        append (the_Source,  " is ");
--
--
--        if not is_Empty (Self.my.base_Classes) then
--
--           if Self.is_Limited then
--              append (the_Source,  "limited ");
--           end if;
--
--           append (the_Source,  "new ");
--
--           declare
--              Cursor : c_Type.Cursor := First (Self.my.base_Classes);
--           begin
--              while has_Element (Cursor) loop
--
--                 if Cursor /= First (Self.my.base_Classes) then
--                    append (the_Source,  NL & "                and ");
--                 end if;
--
--                 append (the_Source,  Element (Cursor).my.nameSpace.Name & ".item");
--                 next   (Cursor);
--              end loop;
--           end;
--
--           if is_tagged_Type (Self)  or  Length (Self.my.base_Classes) > 1 then
--              append (the_Source,  " with private");
--           end if;
--
--        else
--
--           if is_interface_Type (Self) then
--              append (the_Source,  " limited interface");
--
--           elsif virtual_member_function_Count (Self) > 0 then
--
--              if Self.pure_virtual_member_function_Count > 0 then
--                 append (the_Source,  " abstract");
--              end if;
--
--              append (the_Source,  " tagged limited");
--           else
--              append (the_Source,  " private");
--           end if;
--
--        end if;
--
--        append (the_Source,  ";");
--
--        return to_String (the_Source);
--     end;
--
--
--
--
--
--
--     function c_Class_private_declaration_Text (Self : access Item) return String
--     is
--        use c_Type.Vectors;
--        use ada.Containers;
--
--        the_Source              : unbounded_String;
--        union_variant_type_Name : unbounded_String := Self.my.Name & "_variant";
--     begin
--        if Self.is_interface_Type then
--           return "";
--        end if;
--
--
--        if Self.my.requires_Interfaces_C_Int_use then
--           append (the_Source, "   use type interfaces.C.int;"   & NL & NL);
--        end if;
--
--        if Self.my.requires_Interfaces_C_Unsigned_use then
--           append (the_Source, "   use type interfaces.C.Unsigned;"   & NL & NL);
--        end if;
--
--        if Self.my.requires_Interfaces_C_Unsigned_Char_use then
--           append (the_Source, "   use type interfaces.C.Unsigned_Char;"   & NL & NL);
--        end if;
--
--        if Self.my.requires_Interfaces_C_Extensions_bool_use then
--           append (the_Source, "   use type interfaces.C.extensions.bool;"   & NL & NL);
--        end if;
--
--
--        if Self.my.is_Union then
--           append (the_Source,    NL & NL & "type " & union_variant_type_Name & " is (");
--
--           declare
--              --use c_Variable.array_bounds_Vectors, ada.Containers;
--              the_Component : access c_Variable.item'class;
--           begin
--              for Each in 1 .. Self.my.component_Count loop
--
--                 the_Component := Self.my.Components (Each);
--
--                 append (the_Source,  the_Component.Name  & "_variant");
--
--                 if Each /= Self.my.component_Count then
--                    append (the_Source,  ", ");
--                 end if;
--
--              end loop;
--           end;
--
--           append (the_Source,    ");" & NL);
--        end if;
--
--
--
--        append (the_Source,  NL  &  "type "  &  Self.my.Name);
--
--        if Self.my.is_Union then
--           append (the_Source,  " (union_Variant : " &  union_variant_type_Name & " := " & union_variant_type_Name & "'First)");
--        end if;
--
--        append (the_Source,  " is ");
--
--
--        if not is_Empty (Self.my.base_Classes) then
--
--           if Self.is_Limited then
--              append (the_Source,  "limited ");
--           end if;
--
--           append (the_Source,  "new ");
--
--           declare
--              Cursor : c_Type.Cursor := First (Self.my.base_Classes);
--           begin
--              while has_Element (Cursor) loop
--
--                 if Cursor /= First (Self.my.base_Classes) then
--                    append (the_Source,  NL & "                and ");
--                 end if;
--
--                 append (the_Source,  Element (Cursor).my.nameSpace.Name & ".item");
--                 next   (Cursor);
--              end loop;
--           end;
--
--           if is_tagged_Type (Self)  or  Length (Self.my.base_Classes) > 1 then
--              append (the_Source,  " with");
--           end if;
--
--        else
--
--           if is_interface_Type (Self) then
--              append (the_Source,  " limited interface");
--
--           elsif virtual_member_function_Count (Self) > 0 then
--
--              if Self.pure_virtual_member_function_Count > 0 then
--                 append (the_Source,  " abstract");
--              end if;
--
--              append (the_Source,  " tagged limited");
--           end if;
--
--        end if;
--
--
--
--        if not is_interface_Type (Self) then
--           declare
--              has_Components : Boolean := False;
--           begin
--              append (the_Source,  NL & "      record");
--
--
--              -- member variables (ie components)
--              --
--              if Self.my.component_Count = 0 then
--
--                 if not has_Components then
--                    append (the_Source,   NL & "          null;");
--                 end if;
--
--              else
--                 if Self.my.is_Union then
--                    append (the_Source,  NL & "      case union_Variant is");
--                 end if;
--
--                 declare
--                    use c_Variable.array_bounds_Vectors, ada.Containers;
--                    the_Component : access c_Variable.item'class;
--                    type_Modifier : unbounded_String;
--                    type_Name     : unbounded_String;
--                 begin
--                    for Each in 1 .. Self.my.component_Count loop
--
--                       the_Component := Self.my.Components (Each);
--
--                       if Self.my.is_Union then
--                          append (the_Source,  NL & "         when " & the_component.Name & "_variant =>");
--                       end if;
--
--
--  --                       if the_Component.bit_Field = -1 then       -- components, which have bit fields specified, cannot be aliased
--  --                          if    the_Component.is_class_Pointer
--  --                            or (the_Component.is_Pointer  and then  the_Component.my_Type.my.c_type_Kind = Enum)
--  --                          then
--  --
--  --                             if the_component.my_type.my.nameSpace.is_Core then
--  --                                type_Modifier := to_unbounded_String ("aliased");
--  --                             else
--  --                                type_Modifier := to_unbounded_String ("aliased");    -- tbd: sort this out with 'withing' requirements.
--  --                                --type_Modifier := to_unbounded_String ("access");
--  --                             end if;
--  --
--  --                          else
--  --                             type_Modifier := to_unbounded_String ("aliased");
--  --                          end if;
--  --                       end if;
--
--                       if         the_Component.my_type.resolved_Type.c_type_Kind = type_Pointer
--                         and then the_Component.my_type.resolved_Type.accessed_Type.qualified_Name /= "Character"
--                       then
--                          type_Modifier := to_unbounded_String ("access");
--                          type_Name     := the_Component.my_type.resolved_Type.accessed_Type.qualified_Name;
--                       else
--                          if the_Component.bit_Field = -1 then       -- components, which have bit fields specified, cannot be aliased
--                             type_Modifier := to_unbounded_String ("aliased");
--                          end if;
--                          type_Name := the_Component.my_type.resolved_Type.qualified_Name;
--                       end if;
--
--                       append (the_Source,  NL & "         " & the_Component.Name  & " : " & type_Modifier & " " & type_Name);
--
--
--                       if not is_Empty (the_component.array_Bounds) then
--                          append (the_Source, " (");
--
--                          for Each in 1 .. Integer (Length (the_component.array_Bounds)) loop
--                             if Each > 1 then
--                                append (the_Source, ",");
--                             end if;
--
--                             append (the_Source, "0 .." & natural'Image (Element (the_component.array_Bounds, Each)));
--                          end loop;
--
--                          append (the_Source, ")");
--                       end if;
--
--
--
--                       if         the_Component.bit_Field           /= -1
--                         and then the_Component.my_Type.c_type_Kind /= Enum
--                       then
--                          declare
--                             ultimate_base_Type_Name : unbounded_String := to_unbounded_String (to_Lower (to_String (the_Component.my_Type.ultimate_base_Type.Name)));
--                          begin
--
--                             --log ("ultimate Name: '" & the_Component.my_Type.ultimate_base_Type.Name & "'");
--
--                             if         Index (ultimate_base_Type_Name, "unsigned") = 0
--                               and then Index (ultimate_base_Type_Name, "bool")     = 0
--                             then  -- must be signed
--
--                                append (the_Source,   " range -2**" & natural'Image (the_Component.bit_Field - 1)
--                                        & " .. 2**"     & natural'Image (the_Component.bit_Field - 1) & " - 1");
--                             else -- must be unsigned
--                                append (the_Source,   " range 0 .. 2**" & natural'Image (the_Component.bit_Field) & " - 1");
--                             end if;
--                          end;
--
--                       end if;
--
--
--                       append (the_Source,  ";");
--
--                    end loop;
--                 end;
--
--
--                 if Self.my.is_Union then
--                    append (the_Source,  NL & "      end case;");
--                 end if;
--
--              end if;
--
--
--              append (the_Source,  NL & "      end record");
--
--           end;
--        end if;
--
--
--        append (the_Source,  ";" & NL & NL);
--
--
--        if Self.my.is_Union then
--           append (the_Source,  "   pragma unchecked_Union (" & Self.my.Name & ");" & NL & NL);
--        end if;
--
--
--
--
--        return to_String (the_Source);
--
--     end c_Class_private_declaration_Text;
--
--
--
--
--
--
--
--
--     -- nb: the size of a 'subtype enumeration_type_subtype is enumeration_type' is different to the size of the enumeration_type itSelf !!
--     --     (tbd: add design note !!!)
--     --     (tbd: should we try to force the subtype to the same size as its base enumeration type ?
--
--
--     function Enum_declaration_Text (Self : access Item) return String
--     is
--        use enum_literal_Vectors;
--        the_Source : unbounded_String;
--     begin
--        append (the_Source,  "   type " & Self.my.Name & " is (");
--
--        if is_Empty (Self.my.Literals) then
--           append (the_Source,  " nil");
--        else
--           for Each in 1 .. Natural (Length (Self.my.Literals)) loop
--              if not (         Each > 1
--                      and then Element (Self.my.Literals,  Each).Value = Element (Self.my.Literals,  Each - 1).Value)   -- skip any with duplicate values.
--              then
--                 if Each > 1 then
--                    append (the_Source,  "," & NL);
--                 end if;
--
--                 append (the_Source,  "   " & element (Self.my.Literals,  each).Name);
--              end if;
--           end loop;
--        end if;
--
--
--        append (the_Source,   ");");
--
--
--        -- nb: enumeration representation clauses and pragmas need to be done immediately after the type's declaration
--        --     (and not in the private part, as usual), since they may be used as variables or record components prior
--        --     to the packages private part.
--        --
--        append (the_Source,  NL & NL & "   for " & Self.my.Name & " use (");
--
--        if is_Empty (Self.my.Literals) then
--           append (the_Source,  " nil => 0");
--        else
--           for Each in 1 .. Natural (Length (Self.my.Literals)) loop
--              if not (         Each > 1
--                      and then Element (Self.my.Literals,  Each).Value = Element (Self.my.Literals,  Each - 1).Value)   -- skip any with duplicate values.
--              then
--                 if Each > 1 then
--                    append (the_Source,  "," & NL);
--                 end if;
--
--                 append (the_Source,  "   " & element (Self.my.Literals, each).Name  &  " => "  &  Image (element (Self.my.Literals, each).Value));
--              end if;
--           end loop;
--        end if;
--
--        append (the_Source,   ");");
--
--
--        append (the_Source,   NL & NL & "   pragma Convention (C, " & Self.my.Name &  ");" & NL);
--
--
--        return to_String (the_Source);
--
--     end Enum_declaration_Text;
--
--
--
--
--
--
--
--  --     function  declaration_Text    (Self : access Item) return String
--  --     is
--  --        use gnat_Utility;
--  --
--  --        the_Source : unbounded_String;
--  --     begin
--  --  --      verify (Self);
--  --
--  --
--  --        case Self.my.c_type_Kind is
--  --
--  --           when virtual_class_Pointer =>
--  --
--  --              append (the_Source,  "   type " & Self.my.Name & " is new system.Address;");
--  --
--  --
--  --           when array_Type =>
--  --
--  --              append (the_Source,  "   type " & Self.my.Name & " is array (");
--  --
--  --              for Each in 1 .. Self.my.array_dimension_Count loop
--  --
--  --                 if Each > 1 then
--  --                    append (the_Source,  ",");
--  --                 end if;
--  --
--  --                 if Self.my.array_Dimensions_upper_Bound (Each)  =  -1 then
--  --                    --append (the_Source,  "Natural range <>");
--  --                    append (the_Source,  "interfaces.C.Size_t range <>");
--  --                 else
--  --                    --append (the_Source,  "Natural range 0 .. " & Image (Self.my.array_Dimensions_upper_Bound (Each)));
--  --                    append (the_Source,  "interfaces.C.Size_t range 0 .. " & Image (Self.my.array_Dimensions_upper_Bound (Each)));
--  --                 end if;
--  --
--  --              end loop;
--  --
--  --              append (the_Source,  ") of aliased " & qualified_Name (Self.my.element_Type) & ";");
--  --
--  --
--  --           when c_Class =>
--  --              return c_Class_public_declaration_Text (Self);
--  --
--  --
--  --           when Enum =>
--  --              return Enum_declaration_Text (Self);
--  --
--  --
--  --           when function_Pointer =>
--  --
--  --              append (the_Source,  "   type " & Self.my.Name & " is access ");
--  --              append (the_Source,  Self.my.accessed_Function.specification_Source (nameSpace => Self.my.nameSpace,
--  --                                                                                   using_Name          => null_unbounded_String,
--  --                                                                                   namespace_Prefix    => null_unbounded_String));
--  --              append (the_Source,  ";");
--  --
--  --
--  --           when type_Pointer =>
--  --
--  --              if         Self.accessed_Type.c_type_Kind = c_Class                              -- add forward declaration of a class type,
--  --                and then Self.accessed_Type.depends_on (c_Type.view (Self))                 -- if that is what we reference
--  --              then                                                                             --
--  --                 append (the_Source, "   type " & Self.accessed_Type.Name & ";" & NL & NL);    --
--  --              end if;
--  --
--  --
--  --              append (the_Source,  "   type " & Self.my.Name & " is access all "  &  Self.my.accessed_Type.qualified_Name);
--  --
--  --              if         Self.my.accessed_Type.my.c_type_Kind = c_Class
--  --                and then Self.my.accessed_Type.is_tagged_Type
--  --              then
--  --                 append (the_Source,  "'Class ");
--  --              end if;
--  --
--  --              append (the_Source,  ";");
--  --
--  --
--  --           when opaque_Struct
--  --              | Unknown       =>
--  --
--  --              return  to_String ("   type " & Self.my.Name & " is new interfaces.c.extensions.opaque_structure_def;");
--  --
--  --
--  --           when incomplete_Class =>
--  --              return  to_String ("   type " & Self.my.Name & " is new interfaces.c.extensions.incomplete_class_def;");
--  --
--  --
--  --           when standard_c_Type =>
--  --              return "";
--  --
--  --
--  --           when Typedef =>
--  --
--  --              if Self.my.base_Type.c_type_Kind = type_Pointer then
--  --                 return to_String ("   type "  &  Self.my.Name  &  " is access all "  &  Self.my.base_Type.accessed_Type.qualified_Name   &  ";");
--  --              else
--  --                 return to_String ("   type "  &  Self.my.Name  &  " is new "  &  Self.my.base_Type.qualified_Name   &  ";");
--  --                 -- return to_String ("   subtype "  &  Self.my.Name  &  " is "  &  Self.my.base_Type.qualified_Name   &  ";");
--  --              end if;
--  --
--  --
--  --  --           when Unknown =>
--  --  --              raise Program_Error;
--  --        end case;
--  --
--  --
--  --        return to_String (the_Source);
--  --     end;
--
--


   function contains_bit_Fields (Self : access Item) return Boolean
   is
   begin
      for Each in 1 .. Self.my.component_Count
      loop
         if Self.my.Components (Each).bit_Field /= -1
         then
            return True;
         end if;
      end loop;

      return False;
   end contains_bit_Fields;



--     function  representation_Text (Self : access Item) return String
--     is
--        the_Source : unbounded_String;
--     begin
--
--        case Self.my.c_type_Kind is
--
--           when array_Type
--              | opaque_Struct
--              | incomplete_Class
--              | Enum                   -- Enum representation occurs as part of the declaration_Text (not in package private part)
--              | standard_c_Type
--              | type_Pointer
--              | Typedef
--              | virtual_class_Pointer
--              | Unknown   =>
--
--              null;
--
--
--           when c_Class =>
--              append (the_Source,  c_Class_private_declaration_Text (Self));
--
--              if contains_bit_Fields (Self) then
--                 append (the_Source,   NL & NL
--                                     & "   for " & Self.my.Name & " use" & NL
--                                     & "      record"                        );
--
--                 declare
--                    the_Component : access c_Variable.item'class;
--                    bit_Count     : Natural           := 0;
--                    at_Count      : Natural           := 0;
--                    First         : Natural;
--                    Last          : Natural;
--                 begin
--                    if Self.is_Virtual then
--                       at_Count := system.Storage_Unit;                   -- adjust 'at_Count' for  vtable ptr/ada tag
--                    end if;
--
--
--                    for Each in 1 .. Self.my.component_Count loop
--
--                       the_Component := Self.my.Components (Each);
--
--                       if the_Component.bit_Field /= -1 then
--
--                          First     := bit_Count;
--                          bit_Count := bit_Count + the_Component.bit_Field;
--                          Last      := bit_Count - 1;
--
--                          append (the_Source,  NL & "         " & the_Component.Name
--                                                  & " at " & natural'Image (at_Count) & " range " & natural'Image (First) & " .. "
--                                                                                                  & natural'Image (Last) & ";");
--                          if bit_Count >= system.word_Size then
--                             bit_Count := bit_Count - system.word_Size;                       -- tbd: check these are correct & portable
--                             at_Count  := at_Count + system.word_Size / system.storage_Unit;  --
--                          end if;
--
--                       else
--                          null;
--                       end if;
--
--                    end loop;
--
--                 end;
--
--
--                 append (the_Source,  NL & "      end record;"               & NL);
--              end if;
--
--
--
--              if Self.is_Virtual and then not Self.is_interface_Type then
--                 append (the_Source,  to_String (NL & "   pragma cpp_Class (Entity => " & Self.my.Name & ");" & NL & NL));
--              end if;
--
--              return to_String (the_Source);
--
--
--           when function_Pointer =>
--
--              return to_String (NL & "pragma convention (C, " & Self.my.Name & ");");
--
--
--  --           when Unknown =>
--  --              raise Program_Error;
--        end case;
--
--
--        return to_String (the_Source);
--     end;
--


   ----------------------------
   --  'array_Type' Subprograms
   --

   function element_Type (Self : access Item) return c_Type.view
   is
   begin
      return Self.my.element_Type;
   end element_Type;



   procedure add_array_Dimension (Self : access Item;   upper_Bound : in     Integer := unConstrained)
   is
   begin
      Self.my.array_dimension_Count                                        := Self.my.array_dimension_Count + 1;
      Self.my.array_Dimensions_upper_Bound (Self.my.array_dimension_Count) := upper_Bound;
   end add_array_Dimension;



   function is_Unconstrained (Self : access Item) return Boolean
   is
   begin
      for Each in 1 .. Self.my.array_dimension_Count
      loop
         if Self.my.array_Dimensions_upper_Bound (Each) = -1
         then
            return True;
         end if;
      end loop;

      return False;
   end is_Unconstrained;



   function  array_dimension_Count (Self : access Item) return Natural
   is
   begin
      return Self.my.array_dimension_Count;
   end array_dimension_Count;




   function  array_Dimensions_upper_Bound (Self : access Item) return array_dimension_upper_Bounds
   is
   begin
      return Self.my.array_Dimensions_upper_Bound (1 .. Self.my.array_dimension_Count);
   end array_Dimensions_upper_Bound;




   ------------------------------
   --  'type_Pointer' Subprograms
   --

   function accessed_Type (Self : access Item) return c_Type.view
   is
   begin
      return Self.my.accessed_Type;
   end accessed_Type;



   ----------------------
   --  'Enum' Subprograms
   --

   procedure add_Literal (Self : access Item;   Name         : in unbounded_String;
                                                Value        : in gmp.discrete.Integer)
   is
   begin
      append (Self.my.Literals,  (name => Name,
                                  value => Value));
   end add_Literal;




   function contains_Literal (Self  : access Item;
                              Named : in     String) return Boolean
   is
      Cursor : enum_literal_Vectors.Cursor := First (Self.my.Literals);
   begin
      while has_Element (Cursor)
      loop
         if Element (Cursor).Name = Named then
            return True;
         end if;

         next (Cursor);
      end loop;

      return False;
   end contains_Literal;



   procedure add_transformed_Literal (Self         : access Item;
                                      literal_Name : in     unbounded_String)
   is
   begin
      append (Self.my.transformed_literals_Names,  literal_Name);
   end add_transformed_Literal;



   function contains_transformed_Literal (Self  : access Item;
                                          Named : in     unbounded_String)  return Boolean
   is
   begin
      return contains (Self.my.transformed_literals_Names,  Named);
   end contains_transformed_Literal;



   function  Literals (Self : access Item) return enum_literal_vectors.Vector
   is
   begin
      return Self.my.Literals;
   end Literals;



   -------------------------
   --  'c_Class' Subprograms
   --

   function  use_type_Text        (Self : access Item) return String
   is
      the_Source : unbounded_String;
   begin
      case Self.my.c_type_Kind
      is
         when array_Type
            | opaque_Struct
            | incomplete_Class
            | Enum                   -- Enum representation occurs as part of the declaration_Text (not in package private part).
            | standard_c_Type
            | type_Pointer
            | Typedef
            | function_Pointer
            | typedef_Function
            | virtual_class_Pointer
            | Unknown   =>
            null;

         when c_Class =>
            --  Components which are bitfields, and are signed, require a 'use type ...' so that the negation operator '-' is visible
            --  during the components '... range -2**n .. 2**n - 1;' definition.
            --
            declare
               the_Component : access c_Variable.item; --'class;
--                 bit_Count     : Natural           := 0;
            begin
               for Each in 1 .. Self.my.component_Count
               loop
                  the_Component := Self.my.Components (Each);

                  if the_Component.bit_Field /= -1
                  then
                     if Index (to_unbounded_String (to_Lower (to_String (the_Component.my_Type.Name))), "unsigned") = 0
                     then   -- Must be signed.
                        declare
                           the_Text : constant String := to_String (NL & "   use type " & the_Component.my_Type.qualified_Name & ";");
                        begin
                           if Index (the_Source, the_Text) = 0
                           then    -- Don't include more than once.
                              append (the_Source,  the_Text);
                           end if;
                        end;
                     end if;
                  end if;
               end loop;
            end;
      end case;

      return to_String (the_Source);
   end use_type_Text;



   procedure add_Base (Self       : access Item;
                       base_Class : in     c_Type.view)
   is
      use c_Type.Vectors;
   begin
      append (Self.my.base_Classes,  base_Class);
   end add_Base;



   function base_Classes (Self : access Item) return c_Type.Vector
   is
   begin
      return Self.my.base_Classes;
   end base_Classes;



   procedure add_Component (Self          : access Item;
                            new_Component : access c_Variable.item'class)
   is
   begin
      Self.my.component_Count                      := Self.my.component_Count + 1;
      Self.my.Components (Self.my.component_Count) := new_Component;
   end add_Component;


   function component_Count (Self : access Item) return Natural
   is
   begin
      return Self.my.component_Count;
   end component_Count;



   function  Components (Self : access Item) return record_Components
   is
   begin
      return Self.my.Components (1 .. Self.my.component_Count);
   end Components;



   procedure is_Union (Self : access Item)
   is
   begin
      Self.my.is_Union := True;
   end is_Union;



   function virtual_member_function_Count (Self : access Item) return Natural
   is
      use c_Function.Vectors;
      the_Count : Natural := 0;
   begin
      for Each in 1 .. Natural (Length (Self.my.nameSpace.Subprograms))
      loop
         if Element (Self.my.nameSpace.Subprograms,  Each).is_Virtual
         then
            the_Count := the_Count + 1;
         end if;
      end loop;

      return the_Count;
   end virtual_member_function_Count;



   function is_Union (Self : access Item) return Boolean
   is
   begin
      return Self.my.is_Union;
   end is_Union;



   function is_Virtual (Self : access Item) return Boolean
   is
   begin
      return total_virtual_member_function_Count (Self) > 0;
   end is_Virtual;



   function is_tagged_Type (Self : access Item) return Boolean
   is
   begin
      return         is_virtual        (Self)
        and then not is_interface_Type (Self);
   end is_tagged_Type;



   function is_Limited (Self : access Item) return Boolean
   is
      use c_Type.Vectors;
      Cursor : c_Type.Cursor := First (Self.my.base_Classes);
   begin
      while has_Element (Cursor)
      loop
         if Element (Cursor).is_interface_Type then
            return True;
         end if;

         next (Cursor);
      end loop;

      return False;
   end is_Limited;



   function pure_virtual_member_function_Count  (Self : access Item) return Natural
   is
      use c_Function.Vectors;
      the_Count       :          Natural           := 0;
      the_Subprograms : constant c_Function.Vector := Self.my.nameSpace.Subprograms;
   begin
      for Each in 1 .. Natural (Length (the_Subprograms))
      loop
         if          Element (the_Subprograms,  Each).is_Virtual
            and then Element (the_Subprograms,  Each).is_Abstract
         then
            the_Count := the_Count + 1;
         end if;
      end loop;

      return the_Count;
   end pure_virtual_member_function_Count;




   function total_virtual_member_function_Count (Self : access Item) return Natural
   is
      use c_Type.Vectors;
      the_Count : Natural := virtual_member_function_Count (Self);
   begin
      for Each in 1 .. Natural (Length (Self.my.base_Classes))
      loop
         the_Count := the_Count + total_virtual_member_function_Count (Element (Self.my.base_Classes,
                                                                                Each));
      end loop;

      return the_Count;
   end total_virtual_member_function_Count;



   function  is_interface_Type (Self : access Item) return Boolean
   is
   begin
--        log ("'is_interface_Type' -   record_component_Count = " & integer'image (Self.a_cpp_class_Type.record_component_Count)
--             & "    virtual_member_function_Count = "      & integer'image ( Self.virtual_member_function_Count)
--             & "    pure_virtual_member_function_Count = " & integer'image ( Self.pure_virtual_member_function_Count));
      return     Self.c_type_Kind                   = c_Class
        and then Self.my.component_Count            = 0
        and then Self.virtual_member_function_Count > 0
        and then Self.virtual_member_function_Count = pure_virtual_member_function_Count (Self);

   end is_interface_Type;



   function requires_Interfaces_C_Int_use (Self : access Item) return Boolean
   is
   begin
      return Self.my.requires_Interfaces_C_Int_use;
   end requires_Interfaces_C_Int_use;



   function requires_Interfaces_C_Unsigned_use (Self : access Item) return Boolean
   is
   begin
      return Self.my.requires_Interfaces_C_Unsigned_use;
   end requires_Interfaces_C_Unsigned_use;



   function requires_Interfaces_C_Unsigned_Char_use (Self : access Item) return Boolean
   is
   begin
      return Self.my.requires_Interfaces_C_Unsigned_Char_use;
   end requires_Interfaces_C_Unsigned_Char_use;



   function requires_Interfaces_C_Extensions_bool_use (Self : access Item) return Boolean
   is
   begin
      return Self.my.requires_Interfaces_C_Extensions_bool_use;
   end requires_Interfaces_C_Extensions_bool_use;



   function has_virtual_Destructor (Self : access Item) return Boolean
   is
   begin
      return Self.my.has_virtual_Destructor;
   end has_virtual_Destructor;


   procedure has_virtual_Destructor (Self : access Item;   Now : in Boolean := True)
   is
   begin
      Self.my.has_virtual_Destructor := Now;
   end has_virtual_Destructor;



   --------------------------------
   --  function_Pointer Subprograms
   --

   function accessed_Function  (Self : access Item) return access c_Function.item'class
   is
   begin
      return Self.my.accessed_Function;
   end accessed_Function;



   --------------------------------
   --  typedef_Function Subprograms
   --

   function typed_Function  (Self : access Item) return access c_Function.item'class
   is
   begin
      return Self.my.typed_Function;
   end typed_Function;



   -----------------------
   --  Typedef Subprograms
   --

   function base_Type (Self : access Item) return c_Type.view
   is
   begin
      return Self.my.base_Type;
   end base_Type;


end c_Type;
