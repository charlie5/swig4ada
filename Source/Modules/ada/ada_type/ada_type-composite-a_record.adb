with
     ada_Type.a_subType,
     ada_Type.elementary.an_access.to_type,

     ada_Utility,
     ada_Package,
     ada_Subprogram,

     ada.Characters.Handling;


package body ada_Type.composite.a_record
is

   --  Forge
   --

   function new_Item (declaration_Package : access ada_Package.item'class := null;
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
      return Self.context_required_Types;   -- tbd ...
   end required_Types;



   overriding
   function  context_required_Types    (Self : access Item) return ada_Type.views   -- tbd:  This looks more like app code .. move to source_generaotr ?
   is
      the_Types          : ada_Type.views (1 .. Self.component_Count);
      the_component_Type : ada_Type.view;

      Count              : Natural := 0;
   begin
      for Each in the_Types'Range
      loop
--           log ("JJJJJJJJJJJJJJJJJJ: " & Self.my_view_type.qualified_Name & "     " & Self.my.Components (Each).my_Type.resolved_Type.qualified_Name);
         the_component_Type := Self.Components (Each).my_Type;

         if not (         the_component_Type.all in ada_type.a_subType.item'Class                                                       -- ignore Self referential pointer
                 and then a_subType.view (the_component_Type).base_Type.all in elementary.an_Access.to_type.item'Class
                 and then elementary.an_Access.to_type.view (a_subType.view (the_component_Type).base_Type).accessed_Type = Self.all'Access)
         then
            Count := Count + 1;

--              if         the_component_Type.c_type_Kind = a_subType                                                         -- ignore Self referential pointer
--                and then the_component_Type.base_Type.all in ada_Type.elementary.an_access.to_type.item'Class
--                and then ada_Type.elementary.an_access.to_type.view (the_component_Type.base_Type).accessed_Type = Self.all'access)
--              then
--                 null;
--              end if;

            --  the_Types (Count) := the_component_Type.resolved_Type;
            the_Types (Each) := the_component_Type;
         end if;
      end loop;

      return the_Types (1 .. Count);
   end context_required_Types;




   overriding
   function  depends_on            (Self : access Item;   a_Type    : in     ada_Type.view;
                                                          Depth     : in     Natural) return Boolean
   is
      the_component_Type : ada_Type.view;
   begin
      for Each in 1 .. Self.component_Count
      loop
         the_component_Type := Self.Components (Each).my_Type;

         if not (         the_component_Type.all                            in ada_type.a_Subtype          .item'Class
                 and then a_subType.view (the_component_Type).base_Type.all in elementary.an_Access.to_type.item'Class                         -- Detect and ignore a Self-referential pointer.

                 and then elementary.an_Access.to_type.view (a_subType.view (the_component_Type).base_Type).accessed_Type = Self.all'Access)
         then
            if        the_component_Type.all'Access = a_Type
              or else the_component_Type.depends_on (a_Type, Depth + 1)
            then
               return True;
            end if;
         else
            null; -- log ("Self referential record pointer detected !");
         end if;
      end loop;

      return False;
   end depends_on;




   overriding
   function  depends_directly_on   (Self : access Item;   a_Type    : in     ada_Type.view;
                                                          Depth     : in     Natural) return Boolean
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

--           if not (         the_component_Type.c_type_Kind = a_Subtype
--                   and then the_component_Type.base_Type.all in ada_Type.elementary.an_access.to_type.item'class               -- detect and ignore a Self-referential pointer
--                   and then ada_Type.elementary.an_access.to_type.view (the_component_Type.base_Type).accessed_Type = Self.all'access)   --
--           then
            if the_component_Type.all'Access = a_Type then
               return True;
            end if;
--           else
--              null; --log ("Self referential record pointer detected !");
--           end if;
      end loop;

      return False;
   end depends_directly_on;




   overriding
   function  depends_on             (Self : access Item;   a_Package : access ada_Package.item'Class;
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
                 and then a_subType.view (the_component_Type).base_Type.all in elementary.an_Access.to_type.item'Class                         -- Detect and ignore a Self-referential pointer.

                 and then elementary.an_Access.to_type.view (a_subType.view (the_component_Type).base_Type).accessed_Type = Self.all'Access)
         then
            if        the_component_Type.declaration_Package = a_Package
              or else the_component_Type.depends_on (a_Package, Depth + 1)
            then
               return True;
            end if;
         else
            null; -- log ("Self referential record pointer detected !");
         end if;
      end loop;

      return False;
   end depends_on;



   overriding
   procedure verify (Self : access Item)
   is
      use ada_Package;
   begin
--      log ("verifying type: '" & Self.my.Name & "'");

      transform_non_virtual_base_Classes_to_record_Components:
      declare
         use ada_Type.Vectors, ada_Variable;

         Cursor   : ada_Type.Cursor                 := Last (Self.base_Classes);      -- we go in reverse so the order is correct using prepend (below).
         the_Base : ada_Type.composite.a_record.view;
      begin
         while has_Element (Cursor)
         loop
            the_Base := ada_Type.composite.a_record.view (Element (Cursor));

            if not is_Virtual (the_Base)
            then
               delete   (Self.base_Classes, Cursor);
               Cursor := Last (Self.base_Classes);

               Self.component_Count                        := Self.component_Count + 1;                            -- prepend the base type
               Self.Components (2 .. Self.component_Count) := Self.Components (1 .. Self.component_Count - 1);  --
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


      --  Detect if 'use' of interfaces.c.int or unsigned, is required.
      --
      for Each in 1 .. Self.component_Count
      loop
         if Self.Components (Each).bit_Field /= -1
         then
            --  log ("RRRRRRRRRRRRRRRRR: '" & Self.my.Components (Each).my_Type.Name & "'");
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
   begin
      for Each in 1 .. Self.component_Count
      loop
         if Self.Components (Each).bit_Field /= -1 then
            return True;
         end if;
      end loop;

      return False;
   end contains_bit_Fields;



   function  use_type_Text (Self : access Item) return String
   is
      use ada.Characters.Handling;
      the_Source : unbounded_String;
   begin
      --  components which are bitfields, and are signed, require a 'use type ...' so that the negation operator '-' is visible
      --  during the components '... range -2**n .. 2**n - 1;' definition.
      --
      declare
         the_Component : access ada_Variable.item'Class;
--           bit_Count     :        Natural                := 0;
      begin
         for Each in 1 .. Self.component_Count
         loop
            the_Component := Self.Components (Each);

            if the_Component.bit_Field /= -1
            then
               if Index (to_unbounded_String (to_Lower (to_String (the_Component.my_Type.Name))), "unsigned") = 0
               then   -- Must be signed.
                  declare
                     the_Text : constant String := to_String ("   use type " & the_Component.my_Type.qualified_Name & ";");
                  begin
                     if Index (the_Source, the_Text) = 0
                     then   -- Don't include more than once.
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
      append (Self.base_Classes,  base_Class);
   end add_Base;



   function base_Classes (Self : access Item) return ada_Type.Vector
   is
   begin
      return Self.base_Classes;
   end base_Classes;



   procedure add_Component (Self          : access Item;
                            new_Component : access ada_Variable.item'class)
   is
   begin
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



   function virtual_member_function_Count (Self : access Item) return Natural
   is
      use ada_Subprogram.Vectors;
      the_Count : Natural := 0;
   begin
      for Each in 1 .. Natural (Length (Self.declaration_Package.Subprograms))
      loop
         if Element (Self.declaration_Package.Subprograms,  Each).is_Virtual
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


   function is_Abstract (Self : access Item) return Boolean
   is
   begin
      return pure_virtual_member_function_Count (Self) > 0;
   end is_Abstract;



   function is_tagged_Type (Self : access Item) return Boolean
   is
   begin
      return         is_virtual        (Self)
        and then not is_interface_Type (Self);
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




   function pure_virtual_member_function_Count  (Self : access Item) return Natural
   is
      use ada_Subprogram.Vectors;
      the_Count       :          Natural               := 0;
      the_Subprograms : constant ada_Subprogram.Vector := Self.declaration_package.Subprograms;
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
      use ada_Type.Vectors;
      the_Count : Natural := virtual_member_function_Count (Self);
   begin
      for Each in 1 .. Natural (Length (Self.base_Classes))
      loop
         the_Count := the_Count  +  ada_Type.composite.a_record.view (Self.base_Classes.Element (Each)).total_virtual_member_function_Count;
      end loop;

      return the_Count;
   end total_virtual_member_function_Count;




   function  is_interface_Type (Self : access Item) return Boolean
   is
   begin
--        log ("'is_interface_Type' -   record_component_Count = " & integer'image (Self.a_cpp_class_Type.record_component_Count)
--             & "    virtual_member_function_Count = "      & integer'image ( Self.virtual_member_function_Count)
--             & "    pure_virtual_member_function_Count = " & integer'image ( Self.pure_virtual_member_function_Count));

      return     Self.all in ada_type.composite.a_Record.item'Class
        and then Self.component_Count               = 0
        and then Self.virtual_member_function_Count > 0
        and then Self.virtual_member_function_Count = pure_virtual_member_function_Count (Self);

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
