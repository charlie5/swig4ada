with
     c_Variable,
     c_nameSpace,
     c_Function,
     ada_Utility,
     Logger,

     ada.Characters.handling;


package body c_Type
is
   use enum_literal_Vectors,
       GMP.discrete,
       c_nameSpace,
       ada_Utility,
       Logger,

       ada.Characters.handling;


   -----------
   --  Globals
   --

   NL : constant String := new_line_Token;

   function "+" (Self : in String) return ada.Strings.unbounded.unbounded_String
     renames ada.Strings.unbounded.to_unbounded_String;


   ---------
   --  Forge
   --

   function virtual_class_Pointer_construct (nameSpace           : access c_nameSpace.item'Class := null;
                                             Name                : in     unbounded_String       := null_unbounded_String;
                                             base_Type           : in     c_Type.view) return c_Type.item
   is
   begin
      return (c_Declarable.item with My => (c_type_Kind       => virtual_class_Pointer,
                                            nameSpace         => nameSpace,
                                            Name              => Name,
                                            import_Convention => Unknown,
                                            Ignore            => False,
                                            pointee_Type      => base_Type,
                                            resolved_Type     => null));
   end virtual_class_Pointer_construct;



   function new_virtual_class_Pointer (nameSpace : access c_nameSpace.item'class := null;
                                       Name      : in     unbounded_String       := null_unbounded_String;
                                       base_Type : in     c_Type.view) return c_Type.view
   is
   begin
      return new c_Type.item' (virtual_class_Pointer_construct (nameSpace, Name, base_Type));
   end new_virtual_class_Pointer;



   function Typedef_construct (nameSpace : access c_nameSpace.item'Class := null;
                               Name      : in     unbounded_String       := null_unbounded_String;
                               base_Type : in     c_Type.view) return c_Type.item
   is
   begin
      return (c_Declarable.item with My => (c_type_Kind       => Typedef,
                                            nameSpace         => nameSpace,
                                            Name              => Name,
                                            import_Convention => Unknown,
                                            Ignore            => False,
                                            base_Type         => base_Type,
                                            resolved_Type     => null));
   end Typedef_construct;



   function new_Typedef (nameSpace : access c_nameSpace.item'Class := null;
                         Name      : in     unbounded_String       := null_unbounded_String;
                         base_Type : in     c_Type.view) return c_Type.view
   is
   begin
      return new c_Type.item' (Typedef_construct (nameSpace,  Name,  base_Type));
   end new_Typedef;



   function new_type_Pointer (nameSpace     : access c_nameSpace.item'Class := null;
                              Name          : in     unbounded_String       := null_unbounded_String;
                              accessed_Type : in     c_Type.view) return c_Type.view
   is
   begin
      return new c_Type.item' (c_Declarable.item with My => (c_type_Kind      => type_Pointer,
                                                            nameSpace         => nameSpace,
                                                            Name              => Name,
                                                            import_Convention => Unknown,
                                                            accessed_Type     => accessed_Type,
                                                            others            => <>));
   end new_type_Pointer;



   function new_function_Pointer (nameSpace         : access c_nameSpace.item'Class := null;
                                  Name              : in     unbounded_String       := null_unbounded_String;
                                  accessed_Function : access c_Function.item'Class) return c_Type.view
   is
   begin
      return new c_Type.item' (c_Declarable.item with My => (c_type_Kind       => function_Pointer,
                                                             nameSpace         => nameSpace,
                                                             Name              => Name,
                                                             accessed_Function => accessed_Function,
                                                             others            => <>));
   end new_function_Pointer;



   function new_typedef_Function (nameSpace      : access c_nameSpace.item'Class := null;
                                  Name           : in     unbounded_String       := null_unbounded_String;
                                  typed_Function : access c_Function.item'Class) return c_Type.view
   is
   begin
      return new c_Type.item' (c_Declarable.item with My => (c_type_Kind    => typedef_Function,
                                                             nameSpace      => nameSpace,
                                                             Name           => Name,
                                                             typed_function => typed_Function,
                                                             others         => <>));
   end new_typedef_Function;



   function new_array_Type (nameSpace    : access c_nameSpace.item'Class := null;
                            Name         : in     unbounded_String       := null_unbounded_String;
                            element_Type : in     c_Type.view) return c_Type.view
   is
   begin
      return new c_Type.item' (c_Declarable.item with My => (c_type_Kind  => array_Type,
                                                             nameSpace    => nameSpace,
                                                             Name         => Name,
                                                             element_Type => element_Type,
                                                             others       => <>));
   end new_array_Type;



   function new_standard_c_Type (nameSpace : access c_nameSpace.item'Class;
                                 Name      : in     unbounded_String) return c_Type.view
   is
   begin
      return new c_Type.item' (c_Declarable.item with My => (c_type_Kind         => standard_c_Type,
                                                             nameSpace           => nameSpace,
                                                             Name                => Name,
                                                             import_Convention   => Unknown,
                                                             others              => <>));
   end new_standard_c_Type;



   function c_opaque_Struct_construct (nameSpace : access c_nameSpace.item'Class;
                                       Name      : in     unbounded_String) return c_Type.item
   is
   begin
      return c_Type.item' (c_Declarable.item with My => (c_type_Kind       => opaque_Struct,
                                                         nameSpace         => nameSpace,
                                                         Name              => Name,
                                                         import_Convention => Unknown,
                                                         others            => <>));
   end c_opaque_Struct_construct;




   function new_opaque_Struct (nameSpace : access c_nameSpace.item'Class;
                               Name      : in     unbounded_String) return c_Type.view
   is
   begin
      return new c_Type.item' (c_Declarable.item with My => (c_type_Kind       => opaque_Struct,
                                                             nameSpace         => nameSpace,
                                                             Name              => Name,
                                                             import_Convention => Unknown,
                                                             others            => <>));
   end new_opaque_Struct;



   function c_incomplete_Class_construct (nameSpace : access c_nameSpace.item'Class;
                                          Name      : in     unbounded_String) return c_Type.item
   is
   begin
      return c_Type.item' (c_Declarable.item with My => (c_type_Kind       => incomplete_Class,
                                                         nameSpace         => nameSpace,
                                                         Name              => Name,
                                                         import_Convention => Unknown,
                                                         others            => <>));
   end c_incomplete_Class_construct;



   function new_incomplete_Class (nameSpace : access c_nameSpace.item'Class;
                                  Name      : in     unbounded_String) return c_Type.view
   is
   begin
      return new c_Type.item' (c_Declarable.item with My => (c_type_Kind       => incomplete_Class,
                                                             nameSpace         => nameSpace,
                                                             Name              => Name,
                                                             import_Convention => Unknown,
                                                             others            => <>));
   end new_incomplete_Class;



   function Enum_construct (nameSpace : access c_nameSpace.item'Class;
                            Name      : in     unbounded_String) return c_Type.item
   is
   begin
      return (c_Declarable.item with My => (c_type_Kind       => Enum,
                                            nameSpace         => nameSpace,
                                            Name              => Name,
                                            import_Convention => Unknown,
                                            others            => <>));
   end Enum_construct;



   function new_Enum (nameSpace : access c_nameSpace.item'Class;
                      Name      : in     unbounded_String) return c_Type.view
   is
   begin
      return new c_Type.item' (Enum_construct (nameSpace,  Name));
   end new_Enum;



   function c_Class_construct (nameSpace : access c_nameSpace.item'Class;
                               Name      : in     unbounded_String) return c_Type.item
   is
   begin
      return (c_Declarable.item with My => (c_type_Kind       => c_Class,
                                            nameSpace         => new_c_nameSpace (to_String (Name),  nameSpace.all'Access),
                                            Name              => Name,
                                            import_Convention => Unknown,
                                            others            => <>));
   end c_Class_construct;



   function new_c_Class (nameSpace : access c_nameSpace.item'Class;
                         Name      : in      unbounded_String) return c_Type.view
   is
   begin
      return new c_Type.item' (c_Class_construct (nameSpace,  Name));
   end new_c_Class;



   function new_unknown_Type return c_Type.view    -- nb: Returned object is *mutable*.
   is
   begin
      return new c_Type.item;   -- Default is a mutable object of c_type_Kind 'Unknown'.
   end new_unknown_Type;



   --------------
   --  Attributes
   --

   --  General
   --

   function c_type_Kind (Self : access Item) return a_c_type_Kind
   is
   begin
      return Self.my.c_type_Kind;
   end c_type_Kind;



   procedure Name_is (Self : access Item;   Now  : in unbounded_String)
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
      if Self.my.nameSpace = null
      then
         dlog ("Null nameSpace !");
      end if;

      if Self.my.nameSpace.Name = "std"
      then
         return Self.my.Name;
      else
         return Self.my.nameSpace.qualified_Name & "." & Self.my.Name;
      end if;
   end qualified_Name;



   procedure nameSpace_is (Self : access Item;   Now : access c_nameSpace.item'Class)
   is
   begin
      Self.my.nameSpace := Now;
   end nameSpace_is;



   function nameSpace (Self : access Item) return access c_nameSpace.item'Class
   is
   begin
      return Self.my.nameSpace;
   end nameSpace;



   function is_Ignored (Self : access Item) return Boolean
   is
   begin
      return Self.my.Ignore;
   end is_Ignored;


   procedure ignore (Self : access Item)
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



   function ultimate_base_Type (Self : access Item) return c_Type.view
   is
   begin
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
      return Index (to_Lower (Self.ultimate_base_Type.Name), "unsigned") /= 0;
   end is_ultimately_Unsigned;



   procedure resolved_Type_is (Self : access Item;   Now : in c_Type.view)
   is
   begin
      Self.my.resolved_Type := Now;
   end resolved_Type_is;



   function resolved_Type (Self : access Item) return c_Type.view   -- todo: Move this into 'Language' ... it's app code.
   is
   begin
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
               | Enum                  -- todo: When moved to 'Language', make 'Enum' type resolve to 'interfaces.C.int'.
               | Unknown =>

               return Self.all'Access;

            when type_Pointer =>
               return Self.my.accessed_Type.resolved_Type;

            when array_Type =>
               return Self.my.element_Type.resolved_Type;

            when Typedef =>
               return Self.my.base_Type.resolved_Type;

            when virtual_class_Pointer =>
               return Self.my.pointee_Type.resolved_Type;
         end case;

      else
         return Self.all'Access;
      end if;
   end resolved_Type;



   function context_required_Type (Self : access Item) return c_Type.view
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
            | Enum
            | Unknown =>

            return Self.all'Access;

         when type_Pointer =>
            return Self.my.accessed_Type;

         when array_Type =>
            return Self.my.element_Type;

         when Typedef =>
            return Self.my.base_Type;

         when virtual_class_Pointer =>
            return null;
      end case;
   end context_required_Type;


   overriding
   function  depended_on_Declarations (Self : access Item) return c_Declarable.views
   is
      use c_Declarable;
   begin
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
                  end if;
               end loop;

               return the_Types (1 .. Count);
            end;

         when opaque_Struct
            | incomplete_Class
            | Enum
            | standard_c_Type
            | Unknown =>

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
      end case;
   end depended_on_Declarations;


   overriding
   function required_Types (Self : access Item) return c_Declarable.c_Type_views
   is
   begin
      case Self.my.c_type_Kind
      is
         when array_Type =>
            return (1 => Self.my.element_Type);

         when c_Class =>
            declare
               the_Types : c_Declarable.c_Type_views (1 .. Self.my.component_Count);
               Count     : Natural := 0;
            begin
               for Each in the_Types'Range
               loop
                  if         Self.my.Components (Each).my_Type.c_type_Kind   = type_Pointer   -- Detect and ignore a Self-referential pointer.
                    and then Self.my.Components (Each).my_Type.accessed_Type = Self           --
                  then
                     Count             := Count + 1;
                     the_Types (Count) := Self.my.Components (Each).my_Type.resolved_Type;
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
      end case;
   end required_Types;


   overriding
   function depends_on (Self : access Item;   a_Declarable : in c_Declarable.view) return Boolean
   is
      use type c_Declarable.view;
   begin
      raise Program_Error;   -- todo: Resolve this.

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

                  if not (         the_component_Type.c_type_Kind   = type_Pointer     -- Detect and ignore a Self-referential pointer.
                          and then the_component_Type.accessed_Type = Self)            --
                  then
                     if        the_component_Type.all'Access = a_Declarable
                       or else the_component_Type.depends_on (a_Declarable)
                     then
                        return True;
                     end if;
                  end if;
               end loop;

               return False;
            end;

         when opaque_Struct
            | incomplete_Class
            | Enum
            | standard_c_Type
            | Unknown =>

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
      end case;

   end depends_on;


   overriding
   function depends_directly_on (Self : access Item;   a_Declarable : in c_Declarable.view) return Boolean
   is
      use type c_Declarable.view;
   begin
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
                     if the_component_Type.all'Access = a_Declarable
                     then
                        return True;
                     end if;
                  end if;
               end loop;

               return False;
            end;

         when opaque_Struct
            | incomplete_Class
            | Enum
            | standard_c_Type
            | Unknown =>
            return False;

         when function_Pointer =>
            return Self.my.accessed_Function.all'Access = a_Declarable;

         when typedef_Function =>
            return Self.my.typed_Function.all'Access = a_Declarable;

         when type_Pointer =>
            return Self.my.accessed_Type.all'Access = a_Declarable;

         when Typedef =>
            return Self.my.base_Type.all'Access = a_Declarable;

         when virtual_class_Pointer =>
            return False;
      end case;
   end depends_directly_on;


   overriding
   function  directly_depended_on_Declarations (Self : access Item) return c_Declarable.views
   is
      use c_Declarable;
   begin
      case Self.my.c_type_Kind
      is
         when array_Type =>
            return    (1 => Self.my.element_Type.all'Access);

         when c_Class =>
            declare
               the_depended_on_Declarations : c_Declarable.views (1 .. Self.my.component_Count);
            begin
               for Each in the_depended_on_Declarations'Range
               loop
                  the_depended_on_Declarations (Each) := Self.my.Components (Each).my_Type.all'Access;
               end loop;

               return the_depended_on_Declarations;
            end;

         when opaque_Struct
            | incomplete_Class
            | Enum
            | standard_c_Type
            | Unknown =>
            return (1 .. 0 => <>);

         when function_Pointer =>
            return   Self.my.accessed_Function.all'Access
                   & Self.my.accessed_Function.directly_depended_on_Declarations;

         when typedef_Function =>
            return   Self.my.typed_Function.all'Access
                   & Self.my.typed_Function.directly_depended_on_Declarations;

         when type_Pointer =>
            return (1 => Self.my.accessed_Type.all'Access);

         when Typedef =>
            return (1 => Self.my.base_Type.all'Access);

         when virtual_class_Pointer =>
            return (1 .. 0 => <>);
      end case;
   end directly_depended_on_Declarations;



   procedure verify (Self : access Item)
   is
   begin
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
            null;

         when type_Pointer =>
            null;

         when Typedef =>
            null;

         when Unknown =>
            null;

         when c_Class =>
            transform_non_virtual_base_Classes_to_record_Components :
            declare
               use c_variable,
                   c_Type.Vectors;
               Cursor   : c_Type.Cursor := Last (Self.my.base_Classes);      -- We go in reverse so the order is correct using prepend (below).
               the_Base : c_Type.view;
            begin
               while has_Element (Cursor)
               loop
                  the_Base := Element (Cursor);

                  if not is_Virtual (the_Base)
                  then
                     delete   (Self.my.base_Classes, Cursor);
                     Cursor := Last (Self.my.base_Classes);

                     Self.my.component_Count                           := Self.my.component_Count + 1;                            -- Prepend the base type.
                     Self.my.Components (2 .. Self.my.component_Count) := Self.my.Components (1 .. Self.my.component_Count - 1);  --
                     Self.my.Components (1)                            := new_c_Variable (name => +"TODO55", -- the_Base.my.nameSpace.Name & "_base",
                                                                                          of_type => null);  -- the_Base);
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

            --  Detect if 'use' of interfaces.c.int, unsigned, etc, is required.
            --
            for Each in 1 .. Self.my.component_Count
            loop
               if Self.my.Components (Each).bit_Field /= c_Variable.undefined_Bitfield
               then
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
               replace_Element (Self.my.Literals, Each, (name  => to_ada_Identifier (Element (Self.my.Literals, Each).Name),
                                                         value => Element (Self.my.Literals, Each).Value));
            end loop;

            correct_any_name_Clash :
            declare
               Clash_found : Boolean := False;       -- Occurs when any of an enun's literals matches its name (disregarding case).
            begin

               for Each in 1 .. Natural (Length (Self.my.Literals))
               loop
                  if to_Lower (+Element (Self.my.Literals, Each).Name) = to_Lower (+Self.my.Name)
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
               function less_than (Left, Right : enum_Literal) return Boolean
               is
               begin
                  return Left.Value < Right.Value;
               end less_than;

               package Sorter is new enum_literal_vectors.generic_Sorting ("<" => less_than);
            begin
               Sorter.sort (Self.my.Literals);
            end sort_Literals;
      end case;
   end verify;



   function contains_bit_Fields (Self : access Item) return Boolean
   is
      use c_Variable;
   begin
      for Each in 1 .. Self.my.component_Count
      loop
         if Self.my.Components (Each).bit_Field /= undefined_Bitfield
         then
            return True;
         end if;
      end loop;

      return False;
   end contains_bit_Fields;


   ----------------------------
   --  'array_Type' Subprograms
   --

   function element_Type (Self : access Item) return c_Type.view
   is
   begin
      return Self.my.element_Type;
   end element_Type;



   procedure add_array_Dimension (Self : access Item;   upper_Bound : in Integer := unConstrained)
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



   function array_dimension_Count (Self : access Item) return Natural
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

   procedure add_Literal (Self : access Item;   Name  : in unbounded_String;
                                                Value : in gmp.discrete.Integer)
   is
   begin
      append (Self.my.Literals, (name => Name,
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
      append (Self.my.transformed_literals_Names, literal_Name);
   end add_transformed_Literal;



   function contains_transformed_Literal (Self  : access Item;
                                          Named : in     unbounded_String)  return Boolean
   is
   begin
      return contains (Self.my.transformed_literals_Names, Named);
   end contains_transformed_Literal;



   function Literals (Self : access Item) return enum_literal_Vectors.Vector
   is
   begin
      return Self.my.Literals;
   end Literals;


   -------------------------
   --  'c_Class' Subprograms
   --

   function  use_type_Text (Self : access Item) return String
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
               use c_Variable;
               the_Component : access c_Variable.item;
            begin
               for Each in 1 .. Self.my.component_Count
               loop
                  the_Component := Self.my.Components (Each);

                  if the_Component.bit_Field /= undefined_Bitfield
                  then
                     if Index (to_unbounded_String (to_Lower (to_String (the_Component.my_Type.Name))), "unsigned") = 0
                     then -- Must be signed.
                        declare
                           the_Text : constant String := to_String (NL & "   use type " & the_Component.my_Type.qualified_Name & ";");
                        begin
                           if Index (the_Source, the_Text) = 0   -- Don't include more than once.
                           then
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
      append (Self.my.base_Classes, base_Class);
   end add_Base;



   function base_Classes (Self : access Item) return c_Type.Vector
   is
   begin
      return Self.my.base_Classes;
   end base_Classes;



   procedure add_Component (Self          : access Item;
                            new_Component : access c_Variable.item'Class)
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


   function Components (Self : access Item) return record_Components
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
         if Element (Self.my.nameSpace.Subprograms, Each).is_Virtual
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
      return         is_Virtual        (Self)
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



   function pure_virtual_member_function_Count (Self : access Item) return Natural
   is
      use c_Function.Vectors;
      the_Count       :          Natural           := 0;
      the_Subprograms : constant c_Function.Vector := Self.my.nameSpace.Subprograms;
   begin
      for Each in 1 .. Natural (Length (the_Subprograms))
      loop
         if          Element (the_Subprograms, Each).is_Virtual
            and then Element (the_Subprograms, Each).is_Abstract
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

   function accessed_Function  (Self : access Item) return access c_Function.item'Class
   is
   begin
      return Self.my.accessed_Function;
   end accessed_Function;



   --------------------------------
   --  typedef_Function Subprograms
   --

   function typed_Function  (Self : access Item) return access c_Function.item'Class
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
