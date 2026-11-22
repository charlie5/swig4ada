with
     ada_Type.a_subType,
     ada_Type.elementary.an_access.to_type,

     ada_Utility,
     ada_Package,
     ada_Subprogram,

     ada.Characters.handling;

package body ada_Type.composite.a_record
is
   --  Forge
   --

   procedure make_Room (Self : access Item)
   --
   --  Makes room for one more component, where there is none. A record may have any number of components.
   --
   is
   begin
      if Self.component_Count = Self.Components'Last
      then
         declare
            Larger : constant record_Components_view := new record_Components (1 .. 2 * Self.Components'Last);
         begin
            Larger (1 .. Self.component_Count) := Self.Components (1 .. Self.component_Count);
            Self.Components                    := Larger;
         end;
      end if;
   end make_Room;



   function new_Item (declaration_Package : access ada_Package.item'Class := null;
                      Name                : in     unbounded_String       := null_unbounded_String) return View
   is
   begin
      return new ada_Type.composite.a_record.item'(declaration_Package => declaration_Package,
                                                   Name                => Name,
                                                   others              => <>);
   end new_Item;


   --  Attributes
   --

   overriding
   function  required_Types    (Self : access Item) return ada_Type.views
   is
   begin
      return Self.context_required_Types;   -- todo ...
   end required_Types;


   overriding
   function context_required_Types (Self : access Item) return ada_Type.views
   is
      the_Types          : ada_Type.views (1 .. Self.component_Count);
      the_component_Type : ada_Type.view;
      Count              : Natural := 0;
   begin
      for Each in the_Types'Range
      loop
         the_component_Type := Self.Components (Each).my_Type;

         if not (         the_component_Type.all                            in ada_type.a_subType.item'Class     -- Ignore Self referential pointer.
                 and then a_subType.view (the_component_Type).base_Type.all in elementary.an_Access.to_type.item'Class
                 and then elementary.an_Access.to_type.view (a_subType.view (the_component_Type).base_Type).accessed_Type = Self.all'Access)
         then
            Count            := Count + 1;
            the_Types (Each) := the_component_Type;
         end if;
      end loop;

      return the_Types (1 .. Count);
   end context_required_Types;


   overriding
   function  depends_on (Self : access Item;   a_Type : in ada_Type.view;
                                               Depth  : in Natural) return Boolean
   is
      the_component_Type : ada_Type.view;
   begin
      for Each in 1 .. Self.component_Count
      loop
         the_component_Type := Self.Components (Each).my_Type;

         if not (         the_component_Type.all                            in ada_type.a_Subtype          .item'Class
                 and then a_subType.view (the_component_Type).base_Type.all in elementary.an_Access.to_type.item'Class     -- Detect and ignore a Self-referential pointer.

                 and then elementary.an_Access.to_type.view (a_subType.view (the_component_Type).base_Type).accessed_Type = Self.all'Access)
         then
            if        the_component_Type.all'Access = a_Type
              or else the_component_Type.depends_on (a_Type, Depth + 1)
            then
               return True;
            end if;
         end if;
      end loop;

      return False;
   end depends_on;


   overriding
   function depends_directly_on (Self : access Item;   a_Type : in ada_Type.view;
                                                       Depth  : in Natural) return Boolean
   is
      the_component_Type : ada_Type.view;
   begin
      if Depth > 10     -- Break circular type dependencies.
      then
         return True;
      end if;

      for Each in 1 .. Self.component_Count
      loop
         the_component_Type := Self.Components (Each).my_Type;

         if the_component_Type.all'Access = a_Type then
            return True;
         end if;
      end loop;

      return False;
   end depends_directly_on;


   overriding
   function depends_on (Self : access Item;   a_Package : access ada_Package.item'Class;
                                              Depth     : in     Natural) return Boolean
   is
      the_component_Type : ada_Type.view;
   begin
      if Depth > 10     -- Break circular type dependency.
      then
         return True;
      end if;

      for Each in 1 .. Self.component_Count
      loop
         the_component_Type := Self.Components (Each).my_Type;

         if not (         the_component_Type.all                            in ada_type.a_Subtype          .item'Class
                 and then a_subType.view (the_component_Type).base_Type.all in elementary.an_Access.to_type.item'Class     -- Detect and ignore a Self-referential pointer.

                 and then elementary.an_Access.to_type.view (a_subType.view (the_component_Type).base_Type).accessed_Type = Self.all'Access)
         then
            if        the_component_Type.declaration_Package = a_Package
              or else the_component_Type.depends_on (a_Package, Depth + 1)
            then
               return True;
            end if;
         end if;
      end loop;

      --  A record needs the whole of the package of each of its base classes, as it does that of a component.
      --
      for Each of Self.base_Classes
      loop
         if        Each.declaration_Package = a_Package
           or else Each.depends_on (a_Package, Depth + 1)
         then
            return True;
         end if;
      end loop;

      return False;
   end depends_on;


   overriding
   procedure verify (Self : access Item)
   is
      use ada_Package;
   begin
      transform_non_virtual_base_Classes_to_record_Components:
      declare
         use ada_Type.Vectors, ada_Variable;

         Cursor   : ada_Type.Cursor := Last (Self.base_Classes);      -- We go in reverse so the order is correct using prepend (below).
         the_Base : ada_Type.composite.a_record.view;
      begin
         while has_Element (Cursor)
         loop
            the_Base := ada_Type.composite.a_record.view (Element (Cursor));

            if not is_Virtual (the_Base)
            then
               delete (Self.base_Classes, Cursor);
               Cursor := Last (Self.base_Classes);

               -- Prepend the base type.
               --
               make_Room (Self);
               Self.component_Count                        := Self.component_Count + 1;
               Self.Components (2 .. Self.component_Count) := Self.Components (1 .. Self.component_Count - 1);
               Self.Components (1)                         := new_ada_Variable (the_name => the_Base.declaration_package.Name & "_base",
                                                                                the_type => the_Base.all'Access);
            else
               previous (Cursor);
            end if;
         end loop;
      end transform_non_virtual_base_Classes_to_record_Components;

      --  Correct component Identifier names.
      --
      for Each in 1 .. Self.component_Count
      loop
         Self.Components (Each).Name := ada_Utility.to_ada_Identifier (Self.Components (Each).Name);
      end loop;

      --  Detect if 'use' of interfaces.c.int, unsigned, etc, is required.
      --
      for Each in 1 .. Self.component_Count
      loop
         if Self.Components (Each).bit_Field /= ada_Variable.undefined_Bitfield
         then
            if Self.Components (Each).my_Type.qualified_Name = "interfaces.c.Int"
            then
               Self.requires_Interfaces_C_Int_use := True;

            elsif Self.Components (Each).my_Type.qualified_Name = "interfaces.c.Unsigned"
            then
               Self.requires_Interfaces_C_Unsigned_use := True;

            elsif Self.Components (Each).my_Type.qualified_Name = "interfaces.c.unsigned_Char"
            then
               Self.requires_Interfaces_C_Unsigned_use := True;

            elsif Self.Components (Each).my_Type.qualified_Name = "interfaces.c.extensions.bool"
            then
               Self.requires_Interfaces_C_Extensions_bool_use := True;
            end if;
         end if;
      end loop;
   end verify;



   function contains_bit_Fields (Self : access Item) return Boolean
   is
      use ada_Variable;
   begin
      for Each in 1 .. Self.component_Count
      loop
         if Self.Components (Each).bit_Field /= undefined_Bitfield then
            return True;
         end if;
      end loop;

      return False;
   end contains_bit_Fields;



   function use_type_Text (Self : access Item) return String
   is
      use ada.Characters.handling;
      the_Source : unbounded_String;
   begin
      --  Components which are bitfields, and are signed, require a 'use type ...' so that the negation operator '-' is visible
      --  during the components '... range -2**n .. 2**n - 1;' definition.
      --
      declare
         use ada_Utility;
         the_Component : access ada_Variable.item'Class;
      begin
         for Each in 1 .. Self.component_Count
         loop
            the_Component := Self.Components (Each);

            if the_Component.bit_Field /= ada_Variable.undefined_Bitfield
            then
               if Index (+to_Lower (+the_Component.my_Type.Name),
                         "unsigned") = 0
               then -- Must be signed.
                  declare
                     the_Text : constant String := to_String ("   use type " & the_Component.my_Type.qualified_Name & ";");
                  begin
                     if Index (the_Source, the_Text) = 0
                     then -- Don't include more than once.
                        append (the_Source,  the_Text);
                     end if;
                  end;
               end if;
            end if;
         end loop;
      end;

      return to_String (the_Source);
   end use_type_Text;



   procedure add_Base (Self       : access Item;
                       base_Class : in     ada_Type.view)
   is
      use ada_Type.Vectors;
   begin
      append (Self.base_Classes, base_Class);
   end add_Base;



   function base_Classes (Self : access Item) return ada_Type.Vector
   is
   begin
      return Self.base_Classes;
   end base_Classes;



   procedure add_Component (Self          : access Item;
                            new_Component : access ada_Variable.item'Class)
   is
   begin
      make_Room (Self);
      Self.component_Count                   := Self.component_Count + 1;
      Self.Components (Self.component_Count) := new_Component;
   end add_Component;



   function component_Count (Self : access Item) return Natural
   is
   begin
      return Self.component_Count;
   end component_Count;



   function  Components (Self : access Item) return record_Components
   is
   begin
      return Self.Components (1 .. Self.component_Count);
   end Components;



   procedure is_Union (Self : access Item)
   is
   begin
      Self.is_Union := True;
   end is_Union;



   procedure has_virtual_Members (Self : access Item)
   is
   begin
      Self.has_virtual_Members := True;
   end has_virtual_Members;



   procedure has_nontrivial_Members (Self : access Item)
   is
   begin
      Self.has_nontrivial_Members := True;
   end has_nontrivial_Members;



   procedure is_not_layout_Pod (Self : access Item)
   is
   begin
      Self.is_not_layout_Pod := True;
   end is_not_layout_Pod;



   procedure lose_Layout (Self : access Item)
   is
   begin
      Self.has_lost_Layout := True;
   end lose_Layout;



   function has_lost_Layout (Self : access Item) return Boolean
   is
   begin
      return Self.has_lost_Layout;
   end has_lost_Layout;



   procedure layout_Name_is (Self : access Item;   Now : in unbounded_String)
   is
   begin
      Self.layout_Name := Now;
   end layout_Name_is;



   function layout_Name (Self : access Item) return unbounded_String
   is
   begin
      return Self.layout_Name;
   end layout_Name;



   function is_layout_Pod (Self : access Item) return Boolean
   is
   begin
      return not Self.is_not_layout_Pod;
   end is_layout_Pod;



   function is_Nontrivial (Self : access Item) return Boolean
   is
   begin
      if Self.is_Union     -- A union is bound as an unchecked union, whose discriminant a type of convention CPP may not have.
      then
         return False;
      end if;

      if Self.has_nontrivial_Members
      then
         return True;
      end if;

      for Each of Self.base_Classes
      loop
         if View (Each).is_constructed_by_Cpp
         then
            return True;
         end if;
      end loop;

      for Each in 1 .. Self.component_Count
      loop
         declare
            the_Type : constant ada_Type.view := (if Self.Components (Each).my_Type = null then null
                                                                                         else Self.Components (Each).my_Type.resolved_Type);
         begin
            if the_Type = null
            then
               null;

            elsif      the_Type.all in Item'Class                  -- Among them a C++ 'std::string'.
              and then View (the_Type).is_constructed_by_Cpp
            then
               return True;
            end if;
         end;
      end loop;

      return False;
   end is_Nontrivial;



   function is_constructed_by_Cpp (Self : access Item) return Boolean
   is
   begin
      return        Self.is_Virtual
            or else Self.is_Nontrivial;
   end is_constructed_by_Cpp;



   function virtual_member_function_Count (Self : access Item) return Natural
   is
      use ada_Subprogram.Vectors;
      the_Count : Natural := 0;

   begin
      for Subprogram of Self.declaration_Package.Subprograms
      loop
         if Subprogram.is_Virtual
         then
            the_Count := the_Count + 1;
         end if;
      end loop;

      return the_Count;
   end virtual_member_function_Count;



   function is_Union (Self : access Item) return Boolean
   is
   begin
      return Self.is_Union;
   end is_Union;



   function is_Virtual (Self : access Item) return Boolean
   is
   begin
      return total_virtual_member_function_Count (Self) > 0;
   end is_Virtual;


   function unimplemented_pure_virtual_Functions (Self : access Item) return ada_Subprogram.Vector
   --
   --  The pure virtual functions of the class, and those of its base classes which the class does not implement.
   --
   is
      use ada_Subprogram.Vectors,
          ada_Type      .Vectors;
      use type ada.Containers.Count_type;

      own_Subprograms : constant ada_Subprogram.Vector := Self.declaration_Package.Subprograms;
      the_Functions   :          ada_Subprogram.Vector;

      function is_implemented (the_Function : in ada_Subprogram.view) return Boolean
      is
      begin
         for Each of own_Subprograms
         loop
            if          Each.Name                 = the_Function.Name
              and then  Each.Parameters.Length    = the_Function.Parameters.Length
              and then  Each.is_Virtual
              and then  not Each.is_Abstract
            then
               return True;
            end if;
         end loop;

         return False;
      end is_implemented;

   begin
      for Each of own_Subprograms
      loop
         if          Each.is_Virtual
            and then Each.is_Abstract
         then
            the_Functions.append (Each);
         end if;
      end loop;

      for each_Base of Self.base_Classes
      loop
         for Each of ada_Type.composite.a_record.view (each_Base).unimplemented_pure_virtual_Functions
         loop
            if not is_implemented (Each)
            then
               the_Functions.append (Each);
            end if;
         end loop;
      end loop;

      return the_Functions;
   end unimplemented_pure_virtual_Functions;



   function is_Abstract (Self : access Item) return Boolean
   is
   begin
      return not unimplemented_pure_virtual_Functions (Self).is_Empty;
   end is_Abstract;



   function is_tagged_Type (Self : access Item) return Boolean
   is
   begin
      return         Self.is_virtual
        and then not Self.is_interface_Type;
   end is_tagged_Type;



   function is_Limited (Self : access Item) return Boolean
   is
      use ada_Type.Vectors;
      Cursor : ada_Type.Cursor := First (Self.base_Classes);
   begin
      while has_Element (Cursor)
      loop
         if ada_Type.composite.a_record.view (Element (Cursor)).is_interface_Type then
            return True;
         end if;

         next (Cursor);
      end loop;

      return False;
   end is_Limited;



   function pure_virtual_member_function_Count (Self : access Item) return Natural
   is
      use ada_Subprogram.Vectors;
      the_Count       :          Natural               := 0;
      the_Subprograms : constant ada_Subprogram.Vector := Self.declaration_package.Subprograms;
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
      use ada_Type.Vectors;
      the_Count : Natural := virtual_member_function_Count (Self);
   begin
      if         the_Count = 0
        and then Self.has_virtual_Members
      then
         the_Count := 1;
      end if;

      for Each in 1 .. Natural (Length (Self.base_Classes))
      loop
         the_Count := the_Count + ada_Type.composite.a_record.view (Self.base_Classes.Element (Each)).total_virtual_member_function_Count;
      end loop;

      return the_Count;
   end total_virtual_member_function_Count;



   function  is_interface_Type (Self : access Item) return Boolean
   --
   --  A C++ class which has only pure virtual functions and no data members is not modelled as an Ada interface.
   --  An interface is laid out as a secondary base of the classes which derive from it, which matches C++ only
   --  when the class is used as a second or later base class, and multiple inheritance is not supported.
   --  Such a class is modelled as an abstract tagged type, like any other abstract class.
   --
   is
      pragma Unreferenced (Self);
   begin
      return False;
   end is_interface_Type;



   function requires_Interfaces_C_Int_use (Self : access Item) return Boolean
   is
   begin
      return Self.requires_Interfaces_C_Int_use;
   end requires_Interfaces_C_Int_use;



   function requires_Interfaces_C_Unsigned_use (Self : access Item) return Boolean
   is
   begin
      return Self.requires_Interfaces_C_Unsigned_use;
   end requires_Interfaces_C_Unsigned_use;



   function requires_Interfaces_C_Unsigned_Char_use (Self : access Item) return Boolean
   is
   begin
      return Self.requires_Interfaces_C_Unsigned_Char_use;
   end requires_Interfaces_C_Unsigned_Char_use;



   function requires_Interfaces_C_Extensions_bool_use (Self : access Item) return Boolean
   is
   begin
      return Self.requires_Interfaces_C_Extensions_bool_use;
   end requires_Interfaces_C_Extensions_bool_use;



   overriding
   function resolved_Type (Self : access Item) return ada_Type.view
   is
   begin
      return Self.all'Access;
   end resolved_Type;


end ada_Type.composite.a_record;
