with
     ada_Type,
     ada.containers.Vectors,
     ada.Strings.unbounded;


package ada_Variable
--
-- Models an Ada variable.
--
is
   use ada.Strings.unbounded;

   package array_Bounds_Vectors is new ada.containers.Vectors (index_type   => Positive,
                                                               element_type => Integer);

   undefined_Bitfield : constant := -1;

   type Item is tagged
      record
         Name      : unbounded_String;
         my_Type   : ada_Type.view;
         Value     : unbounded_String;
         is_empty_String : Boolean := False; -- A constant whose value is a string of no characters, which 'Value' cannot tell from no value.
         link_Symbol : unbounded_String;     -- The C++ symbol of a variable which is declared in a namespace.
         is_raw_Storage : Boolean := False;  -- A record component which only reserves the storage of its type.

         bit_Field        : Integer                    := undefined_Bitfield;
         is_anonymous_Bits : Boolean                   := False;     -- A bit-field with no name, which only takes part in the layout of its record.
         is_base_Class     : Boolean                   := False;     -- A record component which is a base class of the class.
         member_Name       : unbounded_String;                        -- The name of the member in the wrapper file, for a check of its place.
         array_Bounds     : array_bounds_vectors.Vector;
         is_Pointer       : Boolean                    := False;
         is_class_Pointer : Boolean                    := False;
      end record;

   type View is access all item'Class;


   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;


   --  Forge
   --

   function new_ada_Variable (the_Name : in unbounded_String;
                              the_Type : in ada_Type.view;
                              Value    : in unbounded_String := null_unbounded_String) return View;

   --  Attributes
   --

   function is_Constant (Self : in Item'Class) return Boolean;


   --  Operations
   --

   procedure verify (Self : access Item);

end ada_Variable;
