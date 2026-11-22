with
     swigMod.Binding,

     ada_type.a_Subtype,
     ada_Type.elementary.scalar.discrete.enumeration,
     ada_Type.elementary.scalar.real,
     ada_Type.elementary.an_access.to_type.interfaces_c_pointer,
     ada_Type.elementary.an_access.to_subProgram,
     ada_Type.composite.an_array,
     ada_Type.composite.a_record,
     ada_Utility,
     Logger;


--  old ...
--
with a_Namespace,
     ada_Context,
     ada_Type,
     ada_Variable,

     ada.Strings.fixed,
     ada.Strings.Maps.constants,
     ada.Characters.handling,
     ada.Containers.indefinite_hashed_Maps,
     ada.Strings.unbounded.Hash,
     ada.Exceptions,
     ada.Text_IO,
     pointer_Hash;


package body ada_Language.source_Generator
is
   use a_Namespace,
       ada_Package,
       ada_Variable,
       ada_Type,
       ada_Type.composite.a_record,
       ada_Context,
       ada_Utility,
       Logger,

       ada.Strings.Maps.constants,
       ada.Characters.handling,
       ada.Strings.Maps,
       ada.Text_IO,
       ada.Strings;


   function "+" (Self : in String) return unbounded_String
                 renames to_unbounded_String;

   function "+" (Self : in unbounded_String) return String
                 renames to_String;


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

   NL : constant String := new_line_Token;

   main_module_Name : unbounded_String;     -- The module whose specs are being written, set by 'generate' and 'layout_Checks'.



   function depends_on (Self         : access ada_Type.Item'Class;
                        a_Type       : in     ada_Type.view;
                        the_ada_Lang : access ada_Language.item)    return Boolean
   is
      pragma Unreferenced (the_ada_Lang);
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
      base_Classes            : constant ada_type.Vector  := Self.base_Classes;
   begin
      append (the_Source,  NL  &  "type "  &  Self.Name);

      if Self.is_Union
      then
         append (the_Source,  " (union_Variant : " & union_variant_type_Name & " := " & union_variant_type_Name & "'First)");
      end if;

      append (the_Source,  " is ");


      if not is_Empty (base_Classes)
      then
         if         Self.is_Abstract
           and then not Self.is_interface_Type
         then   -- Has a pure virtual function of its own, or does not implement one which it inherits.
            append (the_Source,  "abstract ");
         end if;

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

               append (the_Source,  Element (Cursor).declaration_package.qualified_Name & ".item");     -- The base class may be in another module.
               next   (Cursor);
            end loop;
         end;

         if Self.is_tagged_Type or Length (base_Classes) > 1
         then
            append (the_Source,  " with private");
         end if;

      else
         if Self.is_interface_Type
         then
            append (the_Source,  " limited interface");

         elsif Self.is_Virtual     -- Also true for a class whose only virtual member is one which is not bound.
         then
            if Self.is_Abstract
            then
               append (the_Source,  " abstract");
            end if;

            append (the_Source,  " tagged limited private");

         elsif Self.is_Nontrivial
         then
            append (the_Source,  " limited private");

         else
            append (the_Source,  " private");
         end if;
      end if;

      append (the_Source,  ";");

      return to_String (the_Source);
   end ada_Record_public_declaration_Text;

   pragma Unreferenced (ada_Record_public_declaration_Text);



   --  The layout of a record which GNAT would not lay out as C++ does.
   --
   --  GNAT does not lay out bit-fields as C does, nor place a member in the unused tail of a base class, so the
   --  place of every component of such a record is worked out here, by the rules of the
   --  System V ABI (which the Itanium C++ ABI follows), and written as a record representation clause. The sizes of the
   --  C types are those of the machine which generates the binding.
   --

   type component_Place is
      record
         First : Natural := 0;     -- In bits, from the start of the record.
         Size  : Natural := 0;
      end record;

   type component_Places is array (Positive range <>) of component_Place;


   function rounded_Up (Value : in Natural;   To : in Positive) return Natural
   is
   begin
      return ((Value + To - 1) / To) * To;
   end rounded_Up;



   function laid_Out (the_Record : in     ada_Type.composite.a_record.view;
                      Places     :    out component_Places;
                      Size       :    out Natural;
                      Alignment  :    out Natural;
                      data_Size  :    out Natural) return Boolean;
   --
   --  Gives the place of each component, and the size and alignment of the record, in bits. Returns False when
   --  the size of a component is not known.
   --
   --  'data_Size' is the size without the unused tail of the record. A base class which is not a plain structure
   --  takes only that much of a class derived from it, and one with no members takes none: the size of the place
   --  of such a component is then less than the size of its type.



   function is_plain_Structure (the_Record : in ada_Type.composite.a_record.view) return Boolean
   --
   --  True for a plain structure, as C++ lays one out: one whose unused tail a derived class leaves alone.
   --
   is
   begin
      if        not the_Record.is_layout_Pod
        or else the_Record.is_Virtual
      then
         return False;
      end if;

      for Each in 1 .. the_Record.component_Count
      loop
         declare
            the_Type : ada_Type.view := the_Record.Components (Each).my_Type;
         begin
            if the_Type.resolved_Type /= null
            then
               the_Type := the_Type.resolved_Type;
            end if;

            if the_Type.all in ada_Type.composite.an_array.item'Class
            then
               the_Type := ada_Type.composite.an_array.view (the_Type).element_Type;
            end if;

            if         the_Type.all in ada_Type.composite.a_record.item'Class
              and then not is_plain_Structure (ada_Type.composite.a_record.view (the_Type))
            then
               return False;     -- It has a member, or a base class, which is not one.
            end if;
         end;
      end loop;

      return True;
   end is_plain_Structure;



   function size_by_Name (the_Name : in String) return Natural
   --
   --  The size, in bits, of a standard type by its name in lower case, or 0. A pointer is one more than the size of an address.
   --
   is
   begin
      return (if    the_Name in "interfaces.c.strings.chars_ptr" | "system.address" | "swig.void_ptr"                     then Standard'Address_Size + 1

              elsif the_Name in   "interfaces.c.char"     | "interfaces.c.plain_char"  | "interfaces.c.signed_char" | "interfaces.c.unsigned_char"
                                | "swig.bool"             | "interfaces.c.extensions.bool" | "character" | "short_short_integer"
                                | "interfaces.integer_8"  | "interfaces.unsigned_8"                                        then 8

              elsif the_Name in   "interfaces.c.short"    | "interfaces.c.unsigned_short" | "short_integer"
                                | "interfaces.integer_16" | "interfaces.unsigned_16"                                       then 16

              elsif the_Name in "interfaces.c.int" | "interfaces.c.unsigned" | "integer" | "natural"                       then interfaces.C.int'Size

              elsif the_Name in "interfaces.integer_32" | "interfaces.unsigned_32" | "interfaces.c.c_float" | "float"      then 32

              elsif the_Name in   "interfaces.c.long" | "interfaces.c.unsigned_long" | "interfaces.c.size_t" | "interfaces.c.ptrdiff_t"
                                | "long_integer"                                                                           then interfaces.C.long'Size

              elsif the_Name in   "swig.long_long" | "swig.unsigned_long_long" | "interfaces.c.extensions.long_long"
                                | "interfaces.c.extensions.unsigned_long_long" | "long_long_integer"
                                | "interfaces.integer_64" | "interfaces.unsigned_64" | "interfaces.c.double" | "long_float" then 64

              elsif the_Name = "interfaces.c.long_double"                                                                   then interfaces.C.long_double'Size
              else  0);
   end size_by_Name;



   function size_Known (the_Type  : in     ada_Type.view;
                        Bounds    : in     ada_Variable.array_bounds_Vectors.Vector;
                        Size      :    out Natural;
                        Alignment :    out Natural) return Boolean
   --
   --  Gives the size and alignment, in bits, of a component of the type and array bounds.
   --
   is
      address_Size  : constant Natural := Standard'Address_Size;
      the_Type_Name : constant String  := to_Lower (to_String (the_Type.qualified_Name));
      the_Resolved  : constant ada_Type.view := (if the_Type.resolved_Type /= null then the_Type.resolved_Type else the_Type);
      the_Name      : constant String  := to_Lower (to_String (the_Resolved.qualified_Name));
      Count         :          Natural := 1;
      element_Type  :          ada_Type.view;
   begin
      Size      := 0;
      Alignment := 8;

      if not Bounds.is_Empty
      then   -- An array, whose type is that of an array with no bounds.
         for Bound of Bounds
         loop
            if Bound < 0
            then
               return False;
            end if;

            Count := Count * (Bound + 1);
         end loop;

         if the_Name in "interfaces.c.char_array" | "string"
         then
            Size := 8 * Count;
            return True;

         elsif the_Resolved.all in ada_Type.composite.an_array.item'Class
         then
            element_Type := ada_Type.composite.an_array.view (the_Resolved).element_Type;

            if not size_Known (element_Type, ada_Variable.array_bounds_Vectors.empty_Vector, Size, Alignment)
            then
               return False;
            end if;

            Size := Size * Count;
            return True;
         else
            return False;
         end if;
      end if;

      if the_Type_Name = "swig.std_strings.std_string"
      then   -- A string of the C++ standard library, whose record gives its layout in GNU libstdc++.
         Size      := 4 * address_Size;
         Alignment := address_Size;
         return True;
      end if;

      if        the_Resolved.all in ada_Type.elementary.an_access.item'Class
        or else size_by_Name (the_Type_Name) = address_Size + 1     -- (See 'size_by_Name'.)
        or else size_by_Name (the_Name)      = address_Size + 1
      then
         Size := address_Size;

      elsif size_by_Name (the_Type_Name) /= 0
      then
         Size := size_by_Name (the_Type_Name);

      elsif size_by_Name (the_Name) /= 0
      then
         Size := size_by_Name (the_Name);

      elsif the_Resolved.all in ada_Type.elementary.scalar.discrete.enumeration.item'Class
      then
         Size := ada_Type.elementary.scalar.discrete.enumeration.view (the_Resolved).object_Size;

         if Size = 0
         then
            Size := interfaces.C.int'Size;
         end if;

      elsif the_Resolved.all in ada_Type.composite.a_record.item'Class
      then
         declare
            the_Record : constant ada_Type.composite.a_record.view := ada_Type.composite.a_record.view (the_Resolved);
            the_Places :          component_Places (1 .. the_Record.component_Count);
            data_Size  :          Natural;
         begin
            return laid_Out (the_Record, the_Places, Size, Alignment, data_Size);
         end;
      else
         return False;
      end if;

      Alignment := Size;
      return True;
   end size_Known;



   function laid_Out (the_Record : in     ada_Type.composite.a_record.view;
                      Places     :    out component_Places;
                      Size       :    out Natural;
                      Alignment  :    out Natural;
                      data_Size  :    out Natural) return Boolean
   is
      the_Component   : access ada_Variable.item'Class;
      Position        :        Natural := 0;     -- The next free bit.
      component_Size  :        Natural;
      component_Align :        Natural;
   begin
      Size      := 0;
      Alignment := 8;
      data_Size := 0;
      Places    := [others => <>];

      --  The members of a class of an imported module are not collected, so its layout is not known here.
      --
      declare
         the_Name : constant String := to_Lower (to_String (the_Record.declaration_Package.qualified_Name));
         the_Main : constant String := to_Lower (to_String (main_module_Name));     -- Which may be within a namespace ('-namespace').
      begin
         if         the_Main /= ""
           and then the_Name /= the_Main
           and then not (         the_Name'Length > the_Main'Length
                         and then the_Name (the_Name'First .. the_Name'First + the_Main'Length) = the_Main & ".")
           and then not (the_Name'Length >= 5 and then the_Name (the_Name'First .. the_Name'First + 4) = "swig.")
           and then the_Name /= "swig"
         then
            return False;
         end if;
      end;

      if not the_Record.base_Classes.is_Empty
      then
         return False;     -- A type extension, which GNAT lays out after its parent.
      end if;

      if        the_Record.has_lost_Layout                               -- A base class or a member could not be bound.
        or else (         the_Record.component_Count = 0                 -- A class which is declared and never defined
                 and then the_Record.layout_Name = ""                    -- cannot be told from one with no members.
                 and then not the_Record.is_Virtual)
      then
         return False;
      end if;

      if the_Record.is_Virtual
      then   -- The pointer to the table of virtual functions comes first.
         Position  := Standard'Address_Size;
         Alignment := Standard'Address_Size;
      end if;

      for Each in 1 .. the_Record.component_Count
      loop
         the_Component := the_Record.Components (Each);

         if not size_Known (the_Component.my_Type, the_Component.array_Bounds, component_Size, component_Align)
         then
            dlog (  "The size of '" & the_Component.my_Type.qualified_Name & "' is not known, for member '" & the_Component.Name
                  & "' of '" & the_Record.declaration_Package.qualified_Name & "'.");
            return False;
         end if;

         if         the_Component.is_base_Class
           and then the_Component.my_Type.all in ada_Type.composite.a_record.item'Class
         then   -- A base class takes less than its size, where C++ uses its tail: all but the tail, or nothing if it has no members.
            declare
               the_Base    : constant ada_Type.composite.a_record.view := ada_Type.composite.a_record.view (the_Component.my_Type);
               base_Places :          component_Places (1 .. the_Base.component_Count);
               base_Size   :          Natural;
               base_Align  :          Natural;
               base_Data   :          Natural;
            begin
               if not laid_Out (the_Base, base_Places, base_Size, base_Align, base_Data)
               then
                  return False;
               end if;

               if         the_Base.component_Count = 0
                 and then not the_Base.is_Virtual
               then
                  component_Size := 0;

               elsif not is_plain_Structure (the_Base)
               then
                  component_Size := base_Data;
               end if;

               Position      := rounded_Up (Position, component_Align);
               Places (Each) := (First => Position, Size => component_Size);
               Position      := Position + component_Size;
               Alignment     := Natural'Max (Alignment, component_Align);
            end;

         elsif the_Record.is_Union
         then
            Places (Each) := (First => 0, Size => (if the_Component.bit_Field >= 0 then the_Component.bit_Field else component_Size));
            Size          := Natural'Max (Size, component_Size);
            Alignment     := Natural'Max (Alignment, component_Align);

         elsif the_Component.bit_Field = 0
         then   -- A bit-field of no width ends the unit which holds the bit-fields before it.
            Position := rounded_Up (Position, component_Size);

         elsif the_Component.bit_Field > 0
         then   -- A bit-field does not cross a unit of its own type.
            if Position / component_Size /= (Position + the_Component.bit_Field - 1) / component_Size
            then
               Position := rounded_Up (Position, component_Size);
            end if;

            Places (Each) := (First => Position, Size => the_Component.bit_Field);
            Position      := Position + the_Component.bit_Field;

            if not the_Component.is_anonymous_Bits     -- The type of a bit-field with no name does not align the record.
            then
               Alignment := Natural'Max (Alignment, component_Align);
            end if;

         else
            Position      := rounded_Up (Position, component_Align);
            Places (Each) := (First => Position, Size => component_Size);
            Position      := Position + component_Size;
            Alignment     := Natural'Max (Alignment, component_Align);
         end if;
      end loop;

      if not the_Record.is_Union
      then
         Size := Position;
      end if;

      if Size = 0
      then
         Size := 8;     -- A class with no members has the size of one byte.
      end if;

      data_Size := rounded_Up (Size, 8);
      Size      := rounded_Up (Size, Alignment);
      return True;
   end laid_Out;



   function needs_Layout (the_Record : in ada_Type.composite.a_record.view) return Boolean
   --
   --  True where GNAT would not lay the record out as C++ does: it has a bit-field, or a base class which takes
   --  less than its size. A type extension is left to GNAT, and its members are reached by functions.
   --
   is
      the_Places    : component_Places (1 .. the_Record.component_Count);
      the_Size      : Natural;
      the_Alignment : Natural;
      data_Size     : Natural;
      base_Size     : Natural;
      base_Align    : Natural;
   begin
      if        not the_Record.base_Classes.is_Empty
        or else the_Record.is_Union
      then
         return False;
      end if;

      if the_Record.contains_bit_Fields
      then
         return True;
      end if;

      if not laid_Out (the_Record, the_Places, the_Size, the_Alignment, data_Size)
      then
         return (for some Each in 1 .. the_Record.component_Count => the_Record.Components (Each).is_base_Class);     -- So that the warning is given.
      end if;

      for Each in 1 .. the_Record.component_Count
      loop
         if         the_Record.Components (Each).is_base_Class
           and then size_Known (the_Record.Components (Each).my_Type, ada_Variable.array_bounds_Vectors.empty_Vector, base_Size, base_Align)
           and then the_Places (Each).Size < base_Size
         then
            return True;
         end if;
      end loop;

      return False;
   end needs_Layout;



   function is_reduced_Base (the_Record : in ada_Type.composite.a_record.view;
                             Index      : in Positive;
                             Places     : in component_Places) return Boolean
   --
   --  True for a component which is a base class, and which takes less than the size of its type.
   --
   is
      the_Component : constant access ada_Variable.item'Class := the_Record.Components (Index);
      full_Size     :          Natural;
      full_Align    :          Natural;
   begin
      return          the_Component.is_base_Class
             and then size_Known (the_Component.my_Type, ada_Variable.array_bounds_Vectors.empty_Vector, full_Size, full_Align)
             and then Places (Index).Size < full_Size;
   end is_reduced_Base;



   function placed_Name (the_Record : in ada_Type.composite.a_record.view;
                         Index      : in Positive;
                         Places     : in component_Places) return String
   --
   --  The name of a component of a record which is laid out. A base class which takes less than its size is storage
   --  alone, as a component of its type would lie over the members which follow, and is reached by 'as_<base>'.
   --
   is
      the_Name : constant String := to_String (the_Record.Components (Index).Name);
   begin
      return the_Name & (if is_reduced_Base (the_Record, Index, Places) then "_storage" else "");
   end placed_Name;



   function ada_Record_private_declaration_Text (Self : in ada_Type.composite.a_record.view) return String
   is
      use ada_type.Vectors,
          ada.Containers;

      the_Source              :          unbounded_String;
      record_Start            :          Positive         := 1;     -- Where the declaration of the record begins.
      union_variant_type_Name : constant unbounded_String := Self.Name & "_variant";
      base_Classes            : constant ada_type.Vector  := Self.base_Classes;

      --  A union with no members has no variants to enumerate, and is declared as a plain record.
      --
      is_a_Union              : constant Boolean          :=          Self.is_Union
                                                             and then Self.component_Count > 0;
   begin
      if Self.is_interface_Type
      then
         return to_String (  NL & "type " & Self.Name & " is limited interface;"
                           & NL
                           & NL & "   pragma Convention (CPP, " & Self.Name & ");");
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


      if is_a_Union
      then
         append (the_Source,  NL & NL & "type " & union_variant_type_Name & " is (");

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


      record_Start := Length (the_Source) + 1;
      append (the_Source,  NL  &  "type "  &  Self.Name);

      if is_a_Union
      then
         append (the_Source,  " (union_Variant : " &  union_variant_type_Name & " := " & union_variant_type_Name & "'First)");
      end if;

      append (the_Source,  " is ");


      if not is_Empty (base_Classes)
      then
         if         Self.is_Abstract
           and then not Self.is_interface_Type
         then   -- Has a pure virtual function of its own, or does not implement one which it inherits.
            append (the_Source,  "abstract ");
         end if;

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

               append (the_Source,  Element (Cursor).declaration_package.qualified_Name & ".item");     -- The base class may be in another module.
               next   (Cursor);
            end loop;
         end;

         append (the_Source,  " with");

      else
         if Self.is_interface_Type
         then
            append (the_Source,  " limited interface");

         elsif Self.is_Virtual     -- Also true for a class whose only virtual member is one which is not bound.
         then
            if Self.is_Abstract
            then
               append (the_Source,  " abstract");
            end if;

            append (the_Source,  " tagged limited");

         elsif Self.is_Nontrivial     -- A C++ class which is passed and returned by reference, and which only C++ can construct.
         then
            append (the_Source,  " limited");
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
                  append (the_Source,  NL & "          null;");
               end if;

            else
               if is_a_Union
               then
                  append (the_Source, NL & "      case union_Variant is");
               end if;

               declare
                  use ada_Variable.array_bounds_Vectors;

                  the_Component : access ada_Variable.item'Class;
                  type_Modifier :        unbounded_String;
                  type_Name     :        unbounded_String;

                  multi_dimensional : Boolean := False;
                  flat_Length       : Natural := 0;

                  function is_a_later_Type_of_this_Package (the_Name : in unbounded_String) return Boolean
                  --
                  --  The record is 'Item' of its package, and the other types of the package (its array and pointer types) follow it.
                  --
                  is
                     my_Name : constant String  := to_String (Self.qualified_Name);
                     Dot     : constant Natural := ada.Strings.fixed.Index (my_Name, ".", going => ada.Strings.Backward);
                  begin
                     return     Dot /= 0
                       and then Length (the_Name) > Dot
                       and then Slice (the_Name, 1, Dot) = my_Name (my_Name'First .. Dot)
                       and then ada.Strings.fixed.Index (Slice (the_Name, Dot + 1, Length (the_Name)), ".") = 0
                       and then to_String (the_Name) /= my_Name;
                  end is_a_later_Type_of_this_Package;

                  the_Places        : component_Places (1 .. Self.component_Count);
                  the_Size          : Natural;
                  the_Alignment     : Natural;
                  data_Size         : Natural;
                  is_laid_Out       : constant Boolean :=          needs_Layout (Self)
                                                          and then laid_Out (Self, the_Places, the_Size, the_Alignment, data_Size);
                  Shown             : Natural := 0;     -- The components which are declared.
               begin
                  for Each in 1 .. Self.component_Count
                  loop
                     the_Component := Self.Components (Each);

                     if the_Component.is_anonymous_Bits
                     then
                        goto next_Component;     -- It has no component, and only takes part in the layout.
                     end if;

                     if         is_laid_Out
                       and then is_reduced_Base (Self, Each, the_Places)
                     then   -- A base class of which C++ uses the tail: storage for the rest of it, or nothing where it has no members.
                        if the_Places (Each).Size > 0
                        then
                           append (the_Source,   NL & "         " & placed_Name (Self, Each, the_Places) & " : aliased interfaces.C.char_array (1 .."
                                               & Natural'Image (the_Places (Each).Size / 8) & ");");
                           Shown := Shown + 1;
                        end if;

                        goto next_Component;
                     end if;

                     Shown         := Shown + 1;
                     type_Modifier := null_unbounded_String;     -- A bit-field is not aliased.

                     if is_a_Union
                     then
                        append (the_Source,  NL & "         when " & the_component.Name & "_variant =>");
                     end if;

                     if         the_Component.my_Type.all                                     in ada_type.a_Subtype.Item'Class
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

                     if         type_Modifier = "access"
                       and then is_a_later_Type_of_this_Package (type_Name)
                     then   -- A pointer to a type which this package declares after the record (a pointer to a pointer to the class itself).
                        type_Modifier := null_unbounded_String;
                        type_Name     := to_unbounded_String ("system.Address");
                     end if;

                     if the_Component.is_raw_Storage
                     then   -- Bytes of the size of the type, as the type itself may be abstract, and would be constructed.
                        type_Modifier := to_unbounded_String ("aliased");
                        type_Name     :=   "interfaces.C.char_array (1 .. Standard." & the_Component.my_type.qualified_Name     -- From 'Standard', as a component which the
                                         & "'Object_Size / interfaces.C.char'Size)";                                           -- record inherits may have the name of the module.
                     end if;

                     if Natural (Length (the_Component.array_Bounds)) > 1
                     then   -- An array of more than one dimension has a type of its own, declared ahead of the record.
                        if         the_Component.my_Type.all in ada_Type.composite.an_array.item'Class
                          and then (for all Bound of the_Component.array_Bounds => Bound >= 0)
                        then
                           declare
                              the_Bounds : unbounded_String;
                           begin
                              for Bound of the_Component.array_Bounds
                              loop
                                 append (the_Bounds,   (if the_Bounds = "" then "" else ", ")
                                                     & "interfaces.C.size_t range 0 .." & Natural'Image (Bound));
                              end loop;

                              type_Name := the_Component.Name & "_Array";

                              insert (the_Source,
                                      record_Start,
                                        NL & "   type " & to_String (type_Name) & " is array (" & to_String (the_Bounds) & ") of aliased "
                                      & to_String (ada_Type.composite.an_array.view (the_Component.my_Type).element_Type.qualified_Name) & ";"
                                      & NL & "   pragma Convention (C, " & to_String (type_Name) & ");" & NL);
                           end;

                           multi_dimensional := True;
                        else
                           flat_Length := 1;     -- Laid out as C has it, in an array of one dimension.

                           for Bound of the_Component.array_Bounds
                           loop
                              flat_Length := flat_Length * (Bound + 1);
                           end loop;
                        end if;
                     end if;

                     append (the_Source,  NL & "         " & the_Component.Name  & " : " & type_Modifier & " " & type_Name);


                     if multi_dimensional
                     then
                        multi_dimensional := False;

                     elsif flat_Length > 0
                     then
                        append (the_Source, " (0 .." & Natural'Image (flat_Length - 1) & ")");
                        flat_Length := 0;

                     elsif not is_Empty (the_component.array_Bounds)
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


                     if         the_Component.bit_Field > 0
                       and then the_Component.my_Type.resolved_Type.all not in ada_type.elementary.scalar.discrete.Enumeration.item'Class
                     then   -- A bit-field holds the values which its bits allow.
                        declare
                           the_type_Name : constant String  := to_Lower (to_String (the_Component.my_Type.resolved_Type.qualified_Name));
                           is_a_Char     : constant Boolean :=        the_type_Name in "interfaces.c.char" | "interfaces.c.plain_char" | "character"
                                                               or else to_Lower (to_String (the_Component.my_Type.qualified_Name)) = "swig.bool";
                           is_Unsigned   : constant Boolean :=        ada.Strings.fixed.Index (the_type_Name, "unsigned") /= 0
                                                               or else ada.Strings.fixed.Index (the_type_Name, "size_t")   /= 0;
                           the_Bits      : constant String  := Natural'Image (the_Component.bit_Field);
                        begin
                           if is_a_Char
                           then
                              append (the_Source,   " range " & type_Name & "'Val (0) .. " & type_Name & "'Val (2**" & the_Bits & " - 1)");
                           elsif is_Unsigned
                           then
                              append (the_Source,   " range 0 .. 2**" & the_Bits & " - 1");
                           else
                              append (the_Source,   " range -2**" & Natural'Image (the_Component.bit_Field - 1)
                                                  & " .. 2**"     & Natural'Image (the_Component.bit_Field - 1) & " - 1");
                           end if;
                        end;
                     end if;

                     append (the_Source,  ";");

                     <<next_Component>>
                  end loop;

                  if Shown = 0
                  then
                     append (the_Source,  NL & "          null;");
                  end if;
               end;


               if is_a_Union
               then
                  append (the_Source,  NL & "      end case;");
               end if;
            end if;

            append (the_Source,  NL & "      end record");
         end;
      end if;

      append (the_Source,  ";" & NL & NL);


      if is_a_Union
      then
         append (the_Source,  "   pragma unchecked_Union (" & Self.Name & ");" & NL & NL);
      end if;

      return to_String (the_Source);
   end ada_Record_private_declaration_Text;



   --  nb: The size of a 'subtype enumeration_type_subtype is enumeration_type' is different to the size of the enumeration_type itself !
   --      todo: Add design note.
   --      todo: Should we try to force the subtype to the same size as its base enumeration type ?

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

      append (the_Source,  ");");


      --  nb: Enumeration representation clauses and pragmas need to be done immediately after the type's declaration
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

      if Self.object_Size /= 0
      then   -- The C++ enumeration names its underlying type, so it is not of the size of an 'int'.
         append (the_Source,   "   for " & Self.Name & "'Size use" & Natural'Image (Self.object_Size) & ";" & NL);
      end if;

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
            if needs_Layout (the_Record)
            then
               declare
                  the_Places    : component_Places (1 .. the_Record.component_Count);
                  the_Size      : Natural;
                  the_Alignment : Natural;
                  data_Size     : Natural;
                  the_Component : access ada_Variable.item'Class;
               begin
                  if not laid_Out (the_Record, the_Places, the_Size, the_Alignment, data_Size)
                  then
                     warn (Layout, "Unable to lay out '" & the_Record.declaration_Package.qualified_Name
                                 & "' as C++ does, as the size of one of its members is not known. Its record may not match the layout of its class.");
                  else
                     append (the_Source,
                               NL & NL
                             & "   for " & the_Record.Name & " use" & NL
                             & "      record"                        );

                     for Each in 1 .. the_Record.component_Count
                     loop
                        the_Component := the_Record.Components (Each);

                        if         not the_Component.is_anonymous_Bits
                          and then the_Places (Each).Size > 0
                        then
                           append (the_Source,   NL & "         " & placed_Name (the_Record, Each, the_Places) & " at 0 range"
                                               & Natural'Image (the_Places (Each).First) & " .."
                                               & Natural'Image (the_Places (Each).First + the_Places (Each).Size - 1) & ";");
                        end if;
                     end loop;

                     append (the_Source,  NL & "      end record;" & NL);

                     if not the_Record.is_Virtual
                     then
                        append (the_Source,   "   for " & the_Record.Name & "'Size use"      & Natural'Image (the_Size)                          & ";" & NL
                                            & "   for " & the_Record.Name & "'Alignment use" & Natural'Image (the_Alignment / system.Storage_Unit) & ";" & NL);
                     end if;
                  end if;
               end;
            end if;


            if             the_Record.is_constructed_by_Cpp
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
                                  the_ada_Lang       : access ada_Language.item) return unbounded_String
   is
      pragma Unreferenced (the_ada_Lang);
      use ada_Parameter.Vectors;

      the_Source     :          unbounded_String;

      all_Parameters : constant ada_Parameter.Vector := Self.Parameters;
      num_Parameters : constant Natural              := Natural (all_Parameters.length);
      has_Parameters : constant Boolean              := num_Parameters > 0;

   begin
      append (the_Source,  NL & NL);

      if Self.is_Overriding
      then
         append (the_Source,  "   overriding" & NL);
      end if;

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
                  name_is_overloaded     : constant        Boolean                := the_name.overload_Count > 1;  -- todo: overload_Count suggests the number of times a name has been overloaded ... whereas this is the acutal number of times a name has been used
                  the_Mode               :                 unbounded_String;

                  using_access_Mode      : constant        Boolean
                    :=          the_Parameter.my_Type.resolved_Type.all in ada_type.elementary.an_Access.to_Subprogram.item'Class
                       and then to_Lower (the_Parameter.my_Type.resolved_Type.qualified_Name) /= "interfaces.c.strings.chars_ptr";

                  Type_is_from_limited_With : constant Boolean := declaration_Package.Context.limited_Withs (parameter_type_Package);
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

                  if         the_Parameter          = Element (First (all_Parameters))     -- Is 1st parameter
                    and then the_Parameter.Name     = "Self"                               -- Is a class 'Self' parameter
                    and then parameter_type_Package = declaration_Package                  -- (todo: simpler/clearer to add a flag to ada_Parameter ?)
                  then
                     if             the_Parameter.my_Type.all in ada_Type.composite.a_record.item'Class
                       and then not ada_Type.composite.a_record.view (the_Parameter.my_Type).is_Virtual
                     then
                        append (the_Mode, "in");        -- For non-virtual C struct's and class's.
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
                     if         Type_is_from_limited_With
                       and then the_Parameter.my_Type.resolved_Type.all in ada_Type.elementary.an_access.to_Type.item'Class
                     then
                        append (the_Mode,  "access");
                        limited_Pointer_base_Type := Access_to_Type_view (the_Parameter.my_Type.resolved_Type).accessed_Type;
                     else
                        append (the_Mode,  "in");
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
            elsif      Self.return_Type.resolved_Type.all in ada_Type.elementary.an_access.to_Type.item'Class
              and then declaration_Package.Context.limited_Withs
                         (ada_Type.elementary.an_access.to_Type.view (Self.return_Type.resolved_Type).accessed_Type.declaration_Package.all'Access)
            then   -- Only a limited view of the package of the accessed type is had, in which its pointer type cannot be seen.
               append (the_Source,
                       "access " & qualified_Name (ada_Type.elementary.an_access.to_Type.view (Self.return_Type.resolved_Type).accessed_Type));
            else
               append (the_Source,
                       qualified_Name (Self.return_Type)); -- .resolved_Type));
            end if;


            if (        return_type_Package.cpp_class_Type /= null
                and then return_type_Package.cpp_class_Type.all'Access = Self.return_Type    -- The return type is the main type of a class package.
                and then return_type_Package.cpp_class_Type.is_Virtual
                and then return_type_Package /= declaration_Package)                         -- The return type is not the main type of the functions package.
              or (         Self.is_Constructor
                  and then declaration_Package.models_a_virtual_cpp_Class)                   -- Only a virtual class is modelled as a tagged type.
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



   function declaration_Text (Self : ada_Type.view;   the_ada_Lang : access ada_Language.item) return String
   is
      the_Source : unbounded_String;
   begin
      if    Self.all in ic_Pointer_Class
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
                                                       the_ada_Lang       => the_ada_Lang));
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
            if         Self.accessed_Type.all in ada_Type.composite.a_record.item'Class            -- Add forward declaration of a class type,
              and then depends_on (Self.accessed_Type,  ada_Type.view (Self),  the_ada_Lang)       -- if that is what we reference.
            then
               append (the_Source, "   type " & Self.accessed_Type.Name & ";" & NL & NL);
            end if;

            append (the_Source,  "   type " & Self.Name & " is access all "  &  Self.accessed_Type.qualified_Name);

            if         Self.accessed_Type.all in  ada_Type.composite.a_record.item'Class
              and then ada_Type.composite.a_record.view (Self.accessed_Type).is_tagged_Type
            then
               append (the_Source,  "'Class ");
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
               declare
                  instantiation_Name : constant String          :=  "C_" & (+Self.Name) & "s";
                  accessed_Type      : constant ada_Type.view   :=  ic_Pointer_view (Self.base_Type).accessed_Type;
                  accessed_type_Name : constant String          := +accessed_Type.qualified_Name;
                  resolved_Type      : constant ada_Type.view   :=  accessed_Type.resolved_Type;
                  default_Terminator :          unbounded_String;
                  is_Abstract        :          Boolean := False;
                  is_Limited         :          Boolean := False;
                  is_Tagged          :          Boolean := False;
               begin
                  if    resolved_Type.all in ada_Type.elementary.an_access.item'Class  -- ada_Type.elementary.an_access.item'Class
                  then
                     default_Terminator := +"null";
                  elsif resolved_Type.all in ada_Type.composite.a_record.item'Class
                  then
                     declare
                        the_Record : constant ada_Type.composite.a_record.view := ada_Type.composite.a_record.view (resolved_Type);
                     begin
                        is_Abstract        := the_Record.is_Abstract;
                        is_Limited         := the_Record.is_tagged_Type or else the_Record.is_Nontrivial;
                        is_Tagged          := the_Record.is_tagged_Type;
                        default_Terminator := +"(others => <>)";
                     end;
                  elsif resolved_Type.all in ada_Type.elementary.scalar.discrete.enumeration.item'Class
                  then
                     default_Terminator := +accessed_type_Name & "'Val (0)";
                  elsif resolved_Type.qualified_Name = "system.Address"
                  then   -- Such as opaque structs and incomplete classes.
                     default_Terminator := +"system.null_Address";
                  elsif resolved_Type.all in ada_Type.composite.an_array.item'Class
                  then
                     default_Terminator := +"(others => <>)";     -- With parentheses, as a binding may be compiled as Ada 2012 or earlier.
                  elsif resolved_Type.all in ada_Type.elementary.scalar.real.item'Class
                  then
                     default_Terminator := +"0.0";
                  else
                     default_Terminator := +"0";
                  end if;

                  if is_Abstract or is_Limited   -- Abstract and limited types cannot be used with interfaces.C.Pointers.
                  then
                     --  A pointer to a virtual class may point to an object of any class derived from
                     --  it, as it may in C++, and a call through it dispatches.
                     --
                     return to_String (  "   type " & Self.Name & " is access all " & ic_Pointer_view (Self.base_Type).accessed_Type.qualified_Name
                                       & (if is_Tagged then "'Class" else "") & ";");
                  else
                     return
                         "   package " & instantiation_Name & " is new interfaces.c.Pointers (Index              => interfaces.c.size_t,"              & NL
                       & "                                                                    Element            => " & accessed_type_Name & ","       & NL
                       & "                                                                    element_Array      => " & accessed_type_Name & "_Array," & NL
                       & "                                                                    default_Terminator => " & (+default_Terminator) & ");"   & NL
                       & NL
                       & "subtype " & (+Self.Name) & " is " & instantiation_Name & ".Pointer;";
                  end if;
               end;
            else
               --  A subtype of an enumeration of another package (an enumeration of a class, which had to be declared in the
               --  top package: see the transformer) is given its literals too, so that they may be named as those of the class.
               --
               if         Self.renames_its_Literals
                 and then Self.base_Type.all in ada_Type.elementary.scalar.discrete.enumeration.item'Class
               then
                  declare
                     use ada_Type.elementary.scalar.discrete.enumeration.enum_literal_Vectors;

                     the_Enumeration : constant ada_Type.elementary.scalar.discrete.enumeration.view
                       := ada_Type.elementary.scalar.discrete.enumeration.view (Self.base_Type);
                     the_Literals    : constant ada_Type.elementary.scalar.discrete.enumeration.enum_literal_Vectors.Vector
                       := the_Enumeration.Literals;
                     the_Text        : unbounded_String
                       := "   subtype " & Self.Name & " is " & Self.base_Type.qualified_Name & ";" & NL;
                  begin
                     for Each in 1 .. Natural (Length (the_Literals))
                     loop
                        if not (for some Prior in 1 .. Each - 1 => Element (the_Literals, Prior).Name = Element (the_Literals, Each).Name)
                        then
                           append (the_Text,   NL & "   function " & Element (the_Literals, Each).Name & " return " & Self.Name
                                             & " renames " & Self.base_Type.declaration_Package.qualified_Name & "." & Element (the_Literals, Each).Name & ";");
                        end if;
                     end loop;

                     return to_String (the_Text);
                  end;
               end if;

               return to_String ("   subtype " & Self.Name & " is " & Self.base_Type.qualified_Name & ";");
            end if;
         end;
      end if;

      return to_String (the_Source);
   end declaration_Text;



   function overload_resolution_Source (Self                 : access ada_subprogram.item'Class;
                                        declaration_Package  : access ada_Package   .item'Class;
                                        unique_function_Name : in     unbounded_String;
                                        namespace_Prefix     : in     unbounded_String;
                                        the_ada_Lang         : access ada_Language.item) return unbounded_String
   is
      the_Source : unbounded_String;

   begin
      --  The 'overloaded subprogram' with a unique name, which is actually imported from 'C'.
      --
      append (the_Source,  specification_Source (Self => Self,
                                                 declaration_package => declaration_Package,
                                                 using_name          => unique_function_Name,
                                                 namespace_Prefix    => namespace_Prefix,
                                                 the_ada_Lang => the_ada_Lang));
      append (the_Source,  ";" & NL & NL);

      append (the_Source, Self.pragma_import_Source (declaration_package  => declaration_Package,
                                                     unique_function_name => unique_function_Name,
                                                     in_cpp_Mode          => True));

      --  Provide body for public subprogram spec, by renaming the 'overloaded subprogram' with the unique name.
      --
      append (the_Source,  specification_Source (Self => Self,
                                                 declaration_package => declaration_Package,
                                                 using_name          => Self.Name,
                                                 namespace_Prefix    => namespace_Prefix,
                                                 the_ada_Lang => the_ada_Lang));

      append (the_Source,  NL & "   renames " & unique_function_Name & ";" & NL & NL);

      return the_Source;
   end overload_resolution_Source;



   procedure write_Spec (for_Package : in unbounded_String;
                         Source      : in unbounded_String)
   is
      use swigMod.Binding;

      output_Directory : unbounded_String := +SWIG_output_directory.all'Access;
      lowcase_Name     : unbounded_String := for_Package;
      the_File         : ada.Text_IO.File_type;

   begin
      if output_Directory = ""
      then
         append (output_Directory,  ".");
      end if;

      translate   (lowcase_Name,  lower_case_Map);
      replace_All (lowcase_Name,  ".",  "-");

      declare
         file_Name : constant String := to_String (output_Directory & "/" & lowcase_Name & ".ads");
      begin
         create (the_File,  out_File,  file_Name);
         put    (the_File,  to_String (Source));
         close  (the_File);

      exception
         when E : name_Error | use_Error | device_Error =>
            if is_Open (the_File)
            then
               close (the_File);
            end if;

            log ("Unable to write package file: '" & file_Name & "'");
            raise Aborted with "Unable to write package file '" & file_Name & "': " & ada.Exceptions.exception_Message (E);
      end;
   end write_Spec;



   procedure emit_Spec (the_Package      : access ada_Package.item'Class;
                        in_cpp_Mode      : in     Boolean;
                        with_IC_Pointers : in     Boolean;
                        the_ada_Lang     : access ada_Language.item)
   is
      use ada_subprogram.Vectors,
          ada_Type      .Vectors,
          ada_variable  .Vectors;

      all_Variables       : constant ada_variable.Vector   := the_Package.Variables;
      all_Subprograms     : constant ada_subprogram.Vector := the_Package.Subprograms;

      all_Types           : constant ada_Type.Vector       := the_Package.Types;
      main_Types          :          ada_Type.Vector;
      ic_pointer_Types    :          ada_Type.Vector;

      use Ada.Containers;
      declaration_Count   : constant Count_Type :=   Length (all_Variables)
                                                   + Length (all_Subprograms)
                                                   + Length (all_Types);

      spec_Source         : aliased  unbounded_String;
      spec_Source_private : aliased  unbounded_String;
      spec_Source_final   :          unbounded_String;     -- Placed at the end of the private part, after the import pragmas.

      package name_Maps is new ada.Containers.indefinite_hashed_Maps (Key_type        => unbounded_String,
                                                                      Element_type    => String,
                                                                      Hash            => ada.Strings.unbounded.Hash,
                                                                      equivalent_Keys => "=");
      variable_Names : name_Maps.Map;     -- The Ada name of each variable in the package, keyed by its C name.


      function accessed_Package (the_Type : in ada_Type.view) return ada_Package.view
      --
      --  The package of the type which a pointer type accesses, or null when 'the_Type' is not a pointer to a type.
      --
      is
         the_resolved_Type : constant ada_Type.view := the_Type.resolved_Type;
      begin
         if         the_resolved_Type /= null
           and then the_resolved_Type.all in ada_Type.elementary.an_access.to_Type.item'Class
         then
            return ada_Package.view (ada_Type.elementary.an_access.to_Type.view (the_resolved_Type).accessed_Type.declaration_Package);
         else
            return null;
         end if;
      end accessed_Package;



      function is_mutually_dependent (the_Type : in ada_Type.view) return Boolean
      --
      --  True when 'the_Type' is a pointer to a type of another package, a subprogram of which has a parameter or result
      --  of a type of this package. The two package specifications cannot both 'with' each other, so this package
      --  uses a limited view of the other, which suffices for a pointer.
      --
      is
         the_other_Package : constant ada_Package.view := accessed_Package (the_Type);

         function is_of_this_Package (the_other_Type : in ada_Type.view) return Boolean
         is
         begin
            return        accessed_Package (the_other_Type) = ada_Package.view (the_Package)
                  or else (         the_other_Type.resolved_Type /= null
                           and then ada_Package.view (the_other_Type.resolved_Type.declaration_Package) = ada_Package.view (the_Package));
         end is_of_this_Package;

      begin
         if        the_other_Package  = null
           or else the_other_Package  = ada_Package.view (the_Package)
           or else the_other_Package.cpp_class_Type = null
         then
            return False;
         end if;

         for each_Subprogram of the_other_Package.Subprograms
         loop
            if         each_Subprogram.return_Type /= null
              and then is_of_this_Package (each_Subprogram.return_Type)
            then
               return True;
            end if;

            for each_Parameter of each_Subprogram.Parameters
            loop
               if         each_Parameter.Name /= "Self"
                 and then is_of_this_Package (each_Parameter.my_Type)
               then
                  return True;
               end if;
            end loop;
         end loop;

         return False;
      end is_mutually_dependent;



      function is_a_Class_of_another_Package (the_Type : in ada_Type.view) return Boolean
      --
      --  True when 'the_Type' is the record of a class or structure of another package, which has a member of a type of this
      --  package (a structure nested in a class, with a member of an enumeration of the class, which a function of the class
      --  returns). That package needs the whole of this one, and the two package specifications cannot both 'with' each other.
      --  So this package uses a limited view of the other, which suffices for a parameter or result of a subprogram.
      --
      is
      begin
         if         the_Type.all in ada_Type.composite.a_record.item'Class
           and then ada_Package.view (the_Type.declaration_Package) /= ada_Package.view (the_Package)
           and then the_Type.declaration_Package.cpp_class_Type = ada_Type.composite.a_record.view (the_Type)
         then
            for Each of ada_Type.composite.a_record.view (the_Type).Components
            loop
               declare
                  the_member_Type : constant ada_Type.view := (if Each.my_Type.resolved_Type /= null then Each.my_Type.resolved_Type
                                                                                                     else Each.my_Type);
               begin
                  if         the_member_Type.all not in ada_Type.elementary.an_access.item'Class     -- A limited view suffices for a pointer.
                    and then (       ada_Package.view (Each.my_Type   .declaration_Package) = ada_Package.view (the_Package)
                              or else ada_Package.view (the_member_Type.declaration_Package) = ada_Package.view (the_Package))
                  then
                     return True;
                  end if;
               end;
            end loop;
         end if;

         return False;
      end is_a_Class_of_another_Package;



      function is_unusable_Array (the_Type : in ada_Type.view) return Boolean
      --
      --  An array type cannot be declared when its element type is an abstract C++ class or is an
      --  unconstrained array. Nor can a subtype of such an array type.
      --
      is
      begin
         if         the_Type.all in subType_class
           and then subType_view (the_Type).base_Type.all in ic_Pointer_class
         then   -- Nor can a pointer to an unconstrained array, 'interfaces.C.Pointers' requiring a definite element.
            declare
               the_accessed_Type : constant ada_Type.view := ic_Pointer_view (subType_view (the_Type).base_Type).accessed_Type;
            begin
               return        (         the_accessed_Type.all in an_Array_class
                              and then an_Array_view (the_accessed_Type).is_Unconstrained)
                     or else is_unusable_Array (the_accessed_Type);
            end;

         elsif the_Type.all in subType_class
         then
            return is_unusable_Array (subType_view (the_Type).base_Type);

         elsif the_Type.all in an_Array_class
         then
            declare
               the_element_Type : constant ada_Type.view := an_Array_view (the_Type).element_Type;
            begin
               return        (         the_element_Type.resolved_Type.all in a_Record_class
                              and then a_Record_view (the_element_Type.resolved_Type).is_Abstract)
                     or else (         the_element_Type.all in an_Array_class
                              and then an_Array_view (the_element_Type).is_Unconstrained)
                     or else is_unusable_Array (the_element_Type);
            end;
         end if;

         return False;
      end is_unusable_Array;



      function is_a_Subprogram_of_the_Package (Name : in String) return Boolean
      is
      begin
         for each_Subprogram of all_Subprograms
         loop
            if to_Lower (to_String (each_Subprogram.Name)) = to_Lower (Name)
            then
               return True;
            end if;
         end loop;

         return False;
      end is_a_Subprogram_of_the_Package;



      function ada_Name_of (the_Variable : in ada_Variable.view) return String
      --
      --  C is case sensitive, so a variable may differ only in case from a type, an enumeration literal or a function
      --  declared in the same package (such as 'enum E {slap} Slap;'). The variable is then prefixed.
      --
      is
         the_Name : constant String := to_String (to_ada_Identifier (the_Variable.Name));
      begin
         for each_Subprogram of all_Subprograms
         loop
            if to_Lower (to_String (each_Subprogram.Name)) = to_Lower (the_Name)
            then
               return "the_" & the_Name;
            end if;
         end loop;

         for each_Type of all_Types
         loop
            if to_Lower (to_String (each_Type.Name)) = to_Lower (the_Name)     -- A constant 'FLAGS' and a type 'Flags'.
            then
               return "the_" & the_Name;
            end if;

            if each_Type.all in ada_Type.elementary.scalar.discrete.enumeration.item'Class
            then
               for each_Literal of ada_Type.elementary.scalar.discrete.enumeration.view (each_Type).Literals
               loop
                  if to_Lower (to_String (each_Literal.Name)) = to_Lower (the_Name)
                  then
                     return "the_" & the_Name;
                  end if;
               end loop;
            end if;
         end loop;

         for each_Package of the_ada_Lang.Module_top.Ada.new_Packages     -- A variable 'a' and a class 'A', which has a child package.
         loop
            if         each_Package.Parent.qualified_Name = the_Package.qualified_Name
              and then to_Lower (to_String (each_Package.ada_Name)) = to_Lower (the_Name)
            then
               return "the_" & the_Name;
            end if;
         end loop;

         return the_Name;
      end ada_Name_of;

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
      dlog ("");
      log  ("Creating package '"            & to_String (the_Package.qualified_Name) & "'");
      dlog ("'emit_Spec' - package name: '" & to_String (the_Package.qualified_Name) & "'");

      if   the_Package.is_Core
        or (        declaration_Count = 0
            and not the_Package.is_global_Namespace)
      then
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

            if         the_Package.models_a_constructed_cpp_Class
              and then (
                        the_Type.all in ic_Pointer_Class

                        or else (         the_Type.all in ada_Type.a_subType.item'Class
                                 and then ada_type.a_subType.view (the_Type).base_Type.all in ic_Pointer_Class)

                        or else (         the_Type.all                              in an_array_class
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

      append (spec_Source,  "-- This file is generated by SWIG. Please do not modify by hand." & NL &
                            "--"                                                               & NL);

      emit_Withs :
      declare
         the_Context                              :          ada_Context.item renames the_Package.Context.all;
         with_of_swig_Required                    :          Boolean          := False;        -- Used for special case where variable of i.c.char_Array is transformed to a Swig.indefinate_char_Array.
         with_of_interfaces_c_extensions_Required : constant Boolean          := False;        -- Ditto, but for opaque stucts and incomplete classes.
         with_of_interfaces_c_Required            :          Boolean          := True;
         with_of_system_Required                  :          Boolean          := False;        -- For pointers whose terminator is 'system.null_Address'.

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

                  elsif is_mutually_dependent (the_Parameter.my_Type)
                  then
                     the_Context.add (ada_Type.elementary.an_Access.to_Type.view (the_Parameter.my_Type.resolved_Type).accessed_Type,
                                      is_access => True);

                  elsif is_a_Class_of_another_Package (the_Parameter.my_Type)
                  then
                     the_Context.add (the_Parameter.my_Type,
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

                  elsif is_mutually_dependent (the_return_Type)
                  then
                     the_Context.add (ada_Type.elementary.an_access.to_type.view (the_return_Type.resolved_Type).accessed_Type,
                                      is_access => True);

                  elsif is_a_Class_of_another_Package (the_return_Type)
                  then
                     the_Context.add (the_return_Type,
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
               if         the_Type.all                          in subType_class
                 and then subType_view (the_Type).base_Type.all in ic_Pointer_class
                 and then ic_Pointer_view (subType_view (the_Type).base_Type).accessed_Type.resolved_Type.qualified_Name = "system.Address"
               then
                  with_of_system_Required := True;
               end if;

               if the_Type.all in ada_Type.composite.a_Record.item'Class
               then
                  declare
                     the_record_Type    : constant ada_Type.composite.a_record.view := a_Record_view (the_Type);
                     the_component_Type :          ada_Type.view;
                  begin
                     for Each in 1 .. the_record_Type.component_Count
                     loop
                        the_component_Type := the_record_Type.Components (Each).my_Type;

                        if not (         the_component_Type.all in subType_class                                      -- Ignore Self referential pointer.
                                and then                      subType_view (the_component_Type).base_Type.all           in Access_to_Type_class
                                and then Access_to_Type_view (subType_view (the_component_Type).base_Type).accessed_Type = the_record_Type.all'Access)
                        then
                           if         the_component_Type.all                          in subType_class                -- Ignore Self referential pointer.
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
            append (spec_Source,   "with Swig;" &  NL);                          -- todo: May result in a redundant withing of 'Swig' package.
         end if;

         if with_of_interfaces_c_extensions_Required
         then   -- Ensure interfaces.C.extensions is with'ed in case of opaque struct's or imcomplete classes.
            append (spec_Source,   "with interfaces.C.extensions;" &  NL);       -- todo: May result in a redundant withing of package.
         end if;

         if with_of_interfaces_c_Required
         then
            append (spec_Source,   "with Interfaces.C;" &  NL & NL);
            append (spec_Source,   "use  Interfaces.C;" &  NL);
         end if;

         if with_IC_Pointers
         then
            append (spec_Source,   "with interfaces.C.Pointers;" &  NL);
         end if;

         if             the_Package.models_a_virtual_cpp_Class
           and then not the_Package.models_an_interface_Type
         then
            with_of_system_Required := False;     -- 'System' is with'ed below.
         end if;

         if with_of_system_Required
         then
            append (spec_Source,   "with System;" &  NL);
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

      -- todo: This 'if' does nothing !
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
               function to_Hash is new pointer_Hash (ada_Type.view);
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
                  then -- Sorting is complete.
                     is_Sorted := True;
                  end if;
               end loop primary;
            end loop;
         end sort_types_by_dependence;


         --  A pointer type is an instance of 'interfaces.C.Pointers', which takes the array type of what it points
         --  to. The sort above does not know of that, and in a class which refers to itself (a list node, say) can
         --  leave the pointer ahead of the array.
         --
         place_each_array_before_its_Pointer :
         declare
            Index : Positive := 1;
         begin
            while Index <= Natural (Length (main_Types))
            loop
               declare
                  the_Pointer : constant ada_Type.view := Element (main_Types, Index);
                  Moved       :          Boolean       := False;
               begin
                  if         the_Pointer.all in subType_class
                    and then subType_view (the_Pointer).base_Type.all in ic_Pointer_class
                  then
                     for Later in Index + 1 .. Natural (Length (main_Types))
                     loop
                        declare
                           the_Array : constant ada_Type.view := Element (main_Types, Later);
                        begin
                           if         the_Array.all in an_Array_class
                             and then an_Array_view (the_Array).element_Type = ic_Pointer_view (subType_view (the_Pointer).base_Type).accessed_Type
                           then
                              delete (main_Types, Later);
                              insert (main_Types, Before => Index, new_Item => the_Array);
                              Moved := True;
                              exit;
                           end if;
                        end;
                     end loop;
                  end if;

                  if not Moved
                  then
                     Index := Index + 1;
                  else
                     Index := Index + 2;     -- Past the array and the pointer.
                  end if;
               end;
            end loop;
         end place_each_array_before_its_Pointer;


         for Each in 1 .. Natural (Length (main_Types))
         loop
            the_Type := Element (main_Types,  Each);

            if not is_unusable_Array (the_Type)
            then
               if not (        Tail (the_Type.Name, 5) = "_view"
                       or else Tail (the_Type.Name, 6) = "_array"
                       or else the_Type.all in ic_Pointer_Class)
               then
                  append (spec_Source, "   -- " & the_Type.Name       & NL);
                  append (spec_Source, "   -- "                       & NL);
               end if;

               append (spec_Source,  declaration_Text (the_Type, the_ada_Lang) & NL & NL);

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


      --  Emit variables.
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
            use ada_Variable.array_bounds_Vectors;
            the_Variable : constant ada_Variable.view := Element (all_Variables,  Each);
         begin
            if         the_Variable.is_Constant
              and then the_Variable.Value /= ""
              and then the_Variable.my_Type.resolved_Type.all in ada_Type.elementary.an_access.to_subProgram.item'Class
              and then not is_a_Subprogram_of_the_Package (to_String (the_Variable.Value))
            then   -- The constant is completed by the access of a function of this package, so there must be one.
               warn (not_Bound, "Unable to bind the constant '" & the_Variable.Name & "', whose value '" & the_Variable.Value
                              & "' does not name a function of its package.");
               goto next_Variable;
            end if;

            variable_Names.include (the_Variable.Name, ada_Name_of (the_Variable));

            verify (the_Variable);

            append (spec_Source,  NL & "   " & variable_Names.Element (the_Variable.Name) & " : ");

            if         the_Variable.is_Constant
              and then the_Variable.my_Type = the_ada_Lang.name_Map_of_ada_Type.Element (+"interfaces.c.int")
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


               if         Natural (Length (the_Variable.array_Bounds)) > 1
                 and then the_Variable.my_Type.all in ada_Type.composite.an_array.item'Class
                 and then (for all Bound of the_Variable.array_Bounds => Bound >= 0)
               then   -- An array of more than one dimension.
                  append (spec_Source, "array (");

                  for Each in 1 .. Integer (Length (the_Variable.array_Bounds))
                  loop
                     append (spec_Source,   (if Each > 1 then ", " else "")
                                          & "interfaces.C.size_t range 0 .." & Natural'Image (Element (the_Variable.array_Bounds, Each)));
                  end loop;

                  append (spec_Source,   ") of aliased "
                                       & ada_Type.composite.an_array.view (the_Variable.my_Type).element_Type.qualified_Name);

               elsif      the_Variable.my_Type.all in ada_type.elementary.an_access.to_type.item'Class
                 and then to_Lower (the_Variable.my_Type.qualified_Name) /= "interfaces.c.strings.chars_ptr"
               then
                  append (spec_Source,  ada_Type.elementary.an_access.to_type.view (the_Variable.my_Type).accessed_Type.resolved_Type.qualified_Name);
               else
                  append (spec_Source,  the_Variable.my_Type.qualified_Name);
               end if;


               if         Natural (Length (the_Variable.array_Bounds)) > 1
                 and then the_Variable.my_Type.all in ada_Type.composite.an_array.item'Class
                 and then (for all Bound of the_Variable.array_Bounds => Bound >= 0)
               then
                  null;     -- Its bounds are in its type.

               elsif not is_Empty (the_variable.array_Bounds)
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
                        append (spec_Source, "0 .. interfaces.C.size_t'Last");     -- The length of the C array is not known.
                     else
                        append (spec_Source, "0 .." & Natural'Image (Element (the_variable.array_Bounds, Each)));
                     end if;
                  end loop;

                  append (spec_Source, ")");
               end if;
            end if;


            if         the_Variable.is_Constant
              and then the_Variable.Value /= ""
              and then the_Variable.my_Type.resolved_Type.all in ada_Type.elementary.an_access.to_subProgram.item'Class
            then   -- The value is a function of the package. Taking its access freezes the function, which must not occur
                   -- before its import pragma, so the constant is deferred and completed at the end of the private part.
               append (spec_Source_final,    NL & "   " & variable_Names.Element (the_Variable.Name)
                                           & " : aliased constant " & the_Variable.my_Type.qualified_Name
                                           & " := " & to_ada_Identifier (the_Variable.Value) & "'Access;" & NL);

            elsif the_Variable.is_Constant
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
                     replace_All (the_Variable.Value, "U", "");          -- todo: Do we need a 'u' replace also ?
                  end if;

                  declare
                     --  The size of a C type ('sizeof(int)') is given by the size of its Ada type.
                     --
                     the_Value   : constant String := to_String (the_Variable.Value);
                     is_a_sizeof : constant Boolean :=          the_Value'Length > 8
                                                       and then the_Value (the_Value'First .. the_Value'First + 6) = "sizeof("
                                                       and then the_Value (the_Value'Last) = ')';
                  begin
                     if         is_a_sizeof
                       and then the_ada_Lang.name_Map_of_c_type.contains (+the_Value (the_Value'First + 7 .. the_Value'Last - 1))
                       and then the_ada_Lang.c_type_Map_of_ada_type.contains (the_ada_Lang.name_Map_of_c_type.Element
                                                                                (+the_Value (the_Value'First + 7 .. the_Value'Last - 1)))
                     then
                        append (spec_Source,
                                  " := "
                                & the_ada_Lang.c_type_Map_of_ada_type.Element (the_ada_Lang.name_Map_of_c_type.Element
                                                                                 (+the_Value (the_Value'First + 7 .. the_Value'Last - 1))).qualified_Name
                                & "'Size / interfaces.C.char'Size");
                     elsif      the_Variable.my_Type.resolved_Type.all in ada_Type.elementary.scalar.discrete.enumeration.item'Class
                       and then the_Value'Length > 0
                       and then (for all Each of the_Value => Each in '0' .. '9')
                     then   -- A constant of an enumeration type, whose value is known by its representation.
                        append (spec_Source,  " := " & the_Variable.my_Type.qualified_Name & "'Enum_Val (" & the_Value & ")");
                     else
                        append (spec_Source,  " := " & the_Variable.Value);
                     end if;
                  end;
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
                     if the_Variable.link_Symbol /= ""
                     then
                        return the_Variable.link_Symbol;

                     elsif in_cpp_Mode
                     then                               -- todo: Need to use proper storage class ?
                        return the_Variable.Name;     -- A variable which is in no namespace has its own name as its symbol.

                     else
                        return the_Variable.Name;
                     end if;
                  end link_Symbol;

               begin
                  append (spec_Source_private,   NL & "   pragma import (" & import_Convention & ", "
                                               & variable_Names.Element (the_Variable.Name)
                                               & ", """ & link_Symbol & """);");
               end emit_import_Pragma;
            end if;
         end;

         <<next_Variable>>
      end loop;


      emit_ic_pointer_Types :
      declare
         the_Type : ada_Type.view;
      begin
         for Each in 1 .. Natural (Length (ic_pointer_Types))
         loop
            the_Type := Element (ic_pointer_Types,  Each);

            begin
               if not is_unusable_Array (the_Type)
               then
                  if not (        Tail (the_Type.Name, 5) = "_view"
                          or else Tail (the_Type.Name, 6) = "_array"
                          or else the_Type.all in ic_Pointer_Class)
                  then
                     append (spec_Source, "   -- " & the_Type.Name & NL);
                     append (spec_Source, "   -- "                 & NL);
                  end if;

                  append (spec_Source,  declaration_Text (the_Type, the_ada_Lang) & NL & NL);

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


      emit_Subprograms :
      declare
         functions_Namespace : a_Namespace.item;
         Cursor              : ada_subprogram.Cursor := First (all_Subprograms);
      begin
         while has_Element (Cursor)
         loop
            functions_Namespace.add_Name (Element (Cursor).Name);                -- Build functions 'namespace' to help with overloading.
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
--                    log ("emit to view conversion subprog: '" & the_Subprogram.Name & "'");
                  declare
                     class_Type : constant ada_Type.view :=  the_Subprogram.return_Type;
                     class_Name : constant String        := +class_Type.declaration_Package.ada_Name;
                  begin
                     append (spec_Source,  "   function to_View    (Self : in " & class_Name & "_Pointer) return " & class_Name & ".view;" & NL);
                  end;

               elsif the_Subprogram.is_to_pointer_Conversion
               then
--                    log ("emit to pointer conversion subprog: '" & the_Subprogram.Name & "'");
                  declare
                     class_Type : constant ada_Type.view :=  the_Subprogram.Parameters.Element (1).my_Type;
                     class_Name : constant String        := +class_Type.declaration_Package.ada_Name;
                  begin
                     append (spec_Source,  "   function to_Pointer (Self : in " & class_Name & ".view)    return " & class_Name & "_Pointer;" & NL);
                  end;

               else
                  declare
                     the_Name             : constant a_namespace.Name_view := functions_Namespace.fetch_Name (the_Subprogram.Name);
                     is_overloaded        : constant Boolean               := the_Name.overload_Count > 1   and then   not the_Subprogram.is_Abstract;
                     unique_function_Name :          unbounded_String;

                     --  A uniquely named twin of an overload would be a further primitive of a virtual class, and so take
                     --  a slot of its own in the C++ vtable. An import pragma cannot be used either, as it applies to all
                     --  prior overloads. An aspect applies to its own declaration only.
                     --
                     imported_by_Aspect   : constant Boolean               :=          is_overloaded
                                                                              and then the_Package.models_a_virtual_cpp_Class
                                                                              and then not the_Subprogram.is_Constructor;
                  begin
                     if         the_Subprogram.access_Mode /= ada_subProgram.private_Access
                       and not (         the_Subprogram.is_Destructor
                                and then is_interface_Type (the_Package.cpp_class_Type))    -- todo: Destructors and interface types together upsets vTable.
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
                                                                    the_ada_Lang       => the_ada_Lang));
                        if imported_by_Aspect
                        then
                           if the_Package.models_an_interface_Type
                           then
                              append (spec_Source,  NL & "     with Convention => CPP");
                           else
                              append (spec_Source,  NL & "     with Import, Convention => CPP, External_Name => """
                                                       & the_Subprogram.member_function_link_Symbol_for (in_cpp_Mode) & """");
                           end if;
                        end if;

                        append (spec_Source,  ";");

                        declare
                           the_Source : access Unbounded_String;
                        begin
                           if the_Subprogram.is_Constructor
                           then
                              the_Source := spec_Source_private'Unchecked_Access;
                           else
                              the_Source := spec_Source_private'Unchecked_Access;
                           end if;

                           if         is_overloaded
                             and then the_Subprogram.is_Constructor
                             and then the_Package.models_a_constructed_cpp_Class
                           then   -- A C++ constructor cannot be renamed, so its pragma directly follows its own declaration.
                              append (spec_Source,
                                      the_Subprogram.pragma_CPP_Constructor_Source (declaration_package  => the_Package.all'Access,
                                                                                    unique_function_name => the_Subprogram.Name,
                                                                                    in_cpp_Mode          => in_cpp_Mode));
                           elsif imported_by_Aspect
                           then
                              null;

                           elsif is_overloaded
                           then
                              append (the_Source.all,
                                      overload_resolution_Source (Self                 => the_Subprogram,
                                                                  declaration_package  => the_Package.all'Access,
                                                                  unique_function_name => unique_function_Name,
                                                                  namespace_Prefix     => null_unbounded_String,
                                                                  the_ada_Lang         => the_ada_Lang));
                           elsif the_Subprogram.is_Constructor
                           then
                              append (the_Source.all,
                                      the_Subprogram.pragma_CPP_Constructor_Source (declaration_package  => the_Package.all'Access,
                                                                                    unique_function_name => unique_function_Name,
                                                                                    in_cpp_Mode          => in_cpp_Mode));
                           else
                              append (the_Source.all,
                                      the_Subprogram.pragma_import_Source (declaration_package  => the_Package.all'Access,
                                                                           unique_function_name => unique_function_Name,
                                                                           in_cpp_Mode          => in_cpp_Mode));
                           end if;
                        end;
                     end if;
                  end;
               end if;
            end;

            next (Cursor);
         end loop;

         append (spec_Source,   NL & NL & NL & NL);
      end emit_Subprograms;


      if             the_Package.models_a_virtual_cpp_Class
        and then not the_Package.models_an_interface_Type
        and then not the_Package.cpp_class_Type.is_Abstract
      then
         append (spec_Source_private,   NL & NL & NL & "   package conversions is new System.Address_To_Access_Conversions (Item);" &  NL);
      end if;

      append (spec_Source_private, spec_Source_final);

      if spec_Source_private /= ""
      then
         append (spec_Source,   NL & NL & NL & NL & NL & NL
                              & "private"
                              & NL & NL & NL
                              & spec_Source_private
                              & NL & NL);
      end if;

      append (spec_Source,  NL & NL & "end " & the_Package.qualified_Name & ";");

      write_Spec (for_Package => the_Package.qualified_Name,
                  Source      => spec_Source);
   end emit_Spec;



   procedure emit_guard_Spec (the_Package : access ada_Package.item'Class)
   --
   --  Emits a 'Guards' child package for a C++ class which has a virtual destructor.
   --  A guard calls the destructor of its target object, when the guard leaves its scope.
   --
   is
      use ada_Subprogram.Vectors;

      has_virtual_Destructor : Boolean := False;
      Source                 : unbounded_String;

   begin
      if        not the_Package.models_a_virtual_cpp_Class
        or else     the_Package.cpp_class_Type = null
        or else     is_interface_Type (the_Package.cpp_class_Type)
      then
         return;
      end if;

      for Each of the_Package.Subprograms
      loop
         if         Each.is_Destructor
           and then Each.is_Virtual
           and then Each.access_Mode /= ada_Subprogram.private_Access
           and then Each.Name         = "destruct_0"
         then
            has_virtual_Destructor := True;
         end if;
      end loop;

      if not has_virtual_Destructor
      then
         return;
      end if;

      append (Source,  "-- This file is generated by SWIG. Please do not modify by hand." & NL &
                       "--"                                                               & NL);
      append (Source,  "with swig.Guards;" & NL & NL);
      append (Source,  "package " & the_Package.qualified_Name & ".Guards is new swig.Guards (Item, destruct_0);" & NL);

      write_Spec (for_Package => the_Package.qualified_Name & ".Guards",
                  Source      => Source);
   end emit_guard_Spec;



   function layout_Checks (Self : access ada_Language.item) return String
   --
   --  Gives, for the wrapper file, a check of the layout which each class is taken to have: its size, and the place
   --  of each of its public members. The checks are made when the wrapper file is compiled, so a record which does not
   --  match its class does not build, where it would otherwise read and write the wrong storage.
   --
   --  Every class whose layout can be worked out is checked. With '-no-check-layout' only a class whose record has
   --  been laid out here is (see 'needs_Layout'), as that layout is for the machine which generated the binding.
   --  The checks are left out of a compilation which defines 'SWIG_ADA_NO_LAYOUT_CHECKS'.
   --
   is
      the_Checks : unbounded_String;
      Count      : Natural := 0;


      procedure check (the_Record : in ada_Type.composite.a_record.view)
      is
         the_Name      : constant String := to_String (the_Record.layout_Name);
         the_Places    :          component_Places (1 .. the_Record.component_Count);
         the_Size      :          Natural;
         the_Alignment :          Natural;
         data_Size     :          Natural;
      begin
         if        the_Name = ""
           or else (the_Record.component_Count = 0 and then not the_Record.is_Virtual)        -- With no members, there is nothing to misplace (and C gives it no size).
           or else not the_Record.base_Classes.is_Empty                                       -- A type extension, which is left to GNAT.
           or else not (Self.all_layout_Checks or else needs_Layout (the_Record))
           or else not laid_Out (the_Record, the_Places, the_Size, the_Alignment, data_Size)
         then
            return;
         end if;

         --  The class is named by a typedef, as its own name may hold a comma, which a macro cannot take.
         --
         Count := Count + 1;

         declare
            the_Type : constant String := "swig_ada_layout_" & ada.Strings.fixed.Trim (Natural'Image (Count), ada.Strings.Left);
         begin
            append (the_Checks,   "typedef " & the_Name & " " & the_Type & ";" & NL
                                & "SWIG_ADA_LAYOUT_CHECK (sizeof (" & the_Type & ") ==" & Natural'Image (the_Size / 8)
                                & ", ""swig4ada: the Ada record of '" & the_Name & "' has not the size of its class."")" & NL);

            if         not the_Record.is_Union
              and then ada.Strings.fixed.Index (the_Name, "std::") /= 1     -- A library file gives the members of a standard class names of its own.
            then
               for Each in 1 .. the_Record.component_Count
               loop
                  declare
                     the_Component : constant access ada_Variable.item'Class := the_Record.Components (Each);
                  begin
                     if         the_Component.member_Name /= ""
                       and then the_Component.bit_Field < 0
                       and then not the_Component.is_base_Class
                       and then Index (the_Component.member_Name, "__") /= 1     -- A name which belongs to the implementation may differ where
                     then                                                           -- the wrapper is compiled ('__int_p_cs_precedes' of 'struct lconv').
                        append (the_Checks,   "SWIG_ADA_LAYOUT_CHECK (SWIG_ADA_OFFSET_OF (" & the_Type & ", " & to_String (the_Component.member_Name) & ") =="
                                            & Natural'Image (the_Places (Each).First / 8)
                                            & ", ""swig4ada: the member '" & to_String (the_Component.member_Name) & "' of the Ada record of '" & the_Name
                                            & "' is not where its class has it."")" & NL);
                     end if;
                  end;
               end loop;
            end if;
         end;
      end check;

   begin
      for Each of Self.Module_top.Ada.new_Packages
      loop
         if Each.cpp_class_Type /= null
         then
            check (Each.cpp_class_Type);
         end if;
      end loop;

      if the_Checks = ""
      then
         return "";
      end if;

      return (
                     NL
                   & "/* The layout which the Ada records take their classes to have. A check which fails means that a record" & NL
                   & "   does not match its class on this machine, and that the binding must be generated again here." & NL
                   & "   Defining SWIG_ADA_NO_LAYOUT_CHECKS leaves the checks out. */" & NL
                   & NL
                   & "#if    !defined (SWIG_ADA_NO_LAYOUT_CHECKS) \" & NL
                   & "    && (   (defined (__cplusplus) && __cplusplus >= 201103L) \" & NL
                   & "        || (!defined (__cplusplus) && defined (__STDC_VERSION__) && __STDC_VERSION__ >= 201112L))" & NL
                   & NL
                   & "#include <stddef.h>" & NL
                   & NL
                   & "#if defined (__cplusplus)" & NL
                   & "#  define SWIG_ADA_LAYOUT_CHECK(Condition, Message)  static_assert (Condition, Message);" & NL
                   & "#else" & NL
                   & "#  define SWIG_ADA_LAYOUT_CHECK(Condition, Message)  _Static_assert (Condition, Message);" & NL
                   & "#endif" & NL
                   & NL
                   & "#if defined (__GNUC__)" & NL
                   & "#  define SWIG_ADA_OFFSET_OF(Type, Member)  __builtin_offsetof (Type, Member)" & NL
                   & "#else" & NL
                   & "#  define SWIG_ADA_OFFSET_OF(Type, Member)  offsetof (Type, Member)" & NL
                   & "#endif" & NL
                   & NL
                   & "#if defined (__GNUC__) && defined (__cplusplus)" & NL
                   & "#  pragma GCC diagnostic push" & NL
                   & "#  pragma GCC diagnostic ignored ""-Winvalid-offsetof""" & NL
                   & "#endif" & NL
                   & NL
                   & to_String (the_Checks)
                   & NL
                   & "#if defined (__GNUC__) && defined (__cplusplus)" & NL
                   & "#  pragma GCC diagnostic pop" & NL
                   & "#endif" & NL
                   & NL
                   & "#endif" & NL);
   end layout_Checks;



   procedure generate (Self : access ada_Language.item)
   is
   begin
      main_module_Name := Self.Module_top.Ada.Package_top.qualified_Name;

      emit_Spec (Self.Module_top.Ada.Package_top,              Self.in_cpp_Mode,  with_IC_Pointers => False, the_ada_Lang => Self);
      emit_Spec (Self.Module_top.Ada.Package_binding,          Self.in_cpp_Mode,  with_IC_Pointers => False, the_ada_Lang => Self);
      emit_Spec (Self.Module_top.Ada.Package_pointers,         Self.in_cpp_Mode,  with_IC_Pointers => True,  the_ada_Lang => Self);
      emit_Spec (Self.Module_top.Ada.Package_pointer_pointers, Self.in_cpp_Mode,  with_IC_Pointers => True,  the_ada_Lang => Self);

      declare
         use ada_package.Vectors;
         Cursor : ada_package.vector_Cursor := Self.Module_top.Ada.new_Packages.First;
      begin
         while has_Element (Cursor)
         loop
            emit_Spec       (Element (Cursor),  Self.in_cpp_Mode,  with_IC_Pointers => True, the_ada_Lang => Self);
            emit_guard_Spec (Element (Cursor));
            next (Cursor);
         end loop;
      end;

      for Each of Self.imported_Classes_defined_here
      loop
         declare
            the_Package : constant ada_Package.view := Self.c_namespace_Map_of_ada_Package.Element (Each.nameSpace.all'Access);
         begin
            emit_Spec       (the_Package,  Self.in_cpp_Mode,  with_IC_Pointers => True, the_ada_Lang => Self);
            emit_guard_Spec (the_Package);
         end;
      end loop;
   end generate;


end ada_Language.source_Generator;
