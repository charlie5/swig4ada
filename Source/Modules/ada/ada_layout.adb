with
     ada_Type.elementary.scalar.discrete.enumeration,
     ada_Type.elementary.an_access,
     ada_Type.composite.an_array,
     ada_Package,
     ada_Variable,
     Logger,

     ada.Strings.unbounded,
     ada.Characters.handling,
     interfaces.C;


package body ada_Layout
is
   use ada_Type,
       ada_Type.composite.a_record,
       Logger,
       ada.Strings.unbounded,
       ada.Characters.handling;


   main_module_Name : unbounded_String;


   procedure main_Module_is (Name : in String)
   is
   begin
      main_module_Name := to_unbounded_String (Name);
   end main_Module_is;



   function rounded_Up (Value : in Natural;   To : in Positive) return Natural
   is
   begin
      return ((Value + To - 1) / To) * To;
   end rounded_Up;



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

end ada_Layout;
