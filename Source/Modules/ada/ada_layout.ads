with
     ada_Type.composite.a_record;


package ada_Layout
--
-- The layout of a record which GNAT would not lay out as C++ does.
--
-- GNAT does not lay out bit-fields as C does, nor place a member in the unused tail of a base class, so the
-- place of every component of such a record is worked out here, by the rules of the System V ABI (which the
-- Itanium C++ ABI follows), to be written as a record representation clause. The sizes of the C types are
-- those of the machine which generates the binding.
--
is
   procedure main_Module_is (Name : in String);
   --
   -- Names the module whose specs are being written. The members of a class of any other module (one which is
   -- imported) are not collected, so the layout of such a class is not known here.


   type component_Place is
      record
         First : Natural := 0;     -- In bits, from the start of the record.
         Size  : Natural := 0;
      end record;

   type component_Places is array (Positive range <>) of component_Place;


   function laid_Out (the_Record : in     ada_Type.composite.a_record.view;
                      Places     :    out component_Places;
                      Size       :    out Natural;
                      Alignment  :    out Natural;
                      data_Size  :    out Natural) return Boolean;
   --
   -- Gives the place of each component, and the size and alignment of the record, in bits. Returns False when
   -- the size of a component is not known.
   --
   -- 'data_Size' is the size without the unused tail of the record. A base class which is not a plain structure
   -- takes only that much of a class derived from it, and one with no members takes none: the size of the place
   -- of such a component is then less than the size of its type.


   function needs_Layout (the_Record : in ada_Type.composite.a_record.view) return Boolean;
   --
   -- True where GNAT would not lay the record out as C++ does: it has a bit-field, or a base class which takes
   -- less than its size. A type extension is left to GNAT, and its members are reached by functions.


   function is_plain_Structure (the_Record : in ada_Type.composite.a_record.view) return Boolean;
   --
   -- True for a plain structure, as C++ lays one out: one whose unused tail a derived class leaves alone.


   function is_reduced_Base (the_Record : in ada_Type.composite.a_record.view;
                             Index      : in Positive;
                             Places     : in component_Places) return Boolean;
   --
   -- True for a component which is a base class, and which takes less than the size of its type.


   function placed_Name (the_Record : in ada_Type.composite.a_record.view;
                         Index      : in Positive;
                         Places     : in component_Places) return String;
   --
   -- The name of a component of a record which is laid out. A base class which takes less than its size is storage
   -- alone, as a component of its type would lie over the members which follow, and is reached by 'as_<base>'.

end ada_Layout;
