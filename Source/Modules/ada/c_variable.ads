with
     c_Declarable,
     c_Type,
     ada.Containers.Vectors,
     ada.Strings.unbounded;


package c_Variable
--
-- Models a C variable.
--
is
   use ada.Strings.unbounded;


   package array_Bounds_Vectors is new ada.Containers.Vectors (index_Type   => Positive,
                                                               element_Type => Integer);

   undefined_Bitfield : constant := -1;

   type Item is new c_Declarable.Item with
      record
         Name             : unbounded_String;
         my_Type          : c_Type.view;
         Value            : unbounded_String;
         is_empty_String  : Boolean := False;     -- A constant whose value is a string of no characters, which 'Value' cannot tell from no value.
         from_Wrapper     : Boolean := False;     -- A constant with no value which Ada can state, which the wrapper defines and Ada imports.
         link_Symbol      : unbounded_String;     -- The C++ symbol of a variable which is declared in a namespace.
         owner_Class      : c_Type.view;          -- The class of a static member variable.

         bit_Field        : Integer := undefined_Bitfield;
         is_anonymous_Bits : Boolean := False;    -- A bit-field with no name, which only takes part in the layout of its class.
         member_Name       : unbounded_String;    -- The name of a public member variable in the wrapper file, for a check of its place.
         is_ignored_Member : Boolean := False;    -- A member which the interface file ignores, and which only reserves its storage.
         Line              : Natural := 0;        -- The line on which a member variable is declared, where that is known.
         smart_Words       : Natural := 0;        -- The addresses of a member which is a smart pointer of the standard library
                                                  -- through a typedef ('using shared_memory_holder = std::shared_ptr<...>').

         is_Static        : Boolean := False;
         is_class_Pointer : Boolean := False;
         is_Pointer       : Boolean := False;

         array_Bounds     : array_bounds_vectors.Vector;
      end record;

   type View is access all item'Class;


   --  Containers
   --

   package Vectors is new ada.Containers.Vectors (Positive, View);

   subtype Vector  is Vectors.Vector;
   subtype Cursor  is Vectors.Cursor;


   --  Forge
   --

   function construct      (Name    : in unbounded_String;
                            of_Type : in c_Type.view) return Item'Class;


   function new_c_Variable (Name    : in unbounded_String;
                            of_Type : in c_Type.view) return View;


   --  Attributes
   --

   overriding
   function  Name                (Self : access Item) return ada.Strings.unbounded.unbounded_String;

   overriding
   function  required_Types      (Self : access Item) return c_Declarable.c_Type_views;

   overriding
   function  depended_on_Declarations
                                 (Self : access Item) return c_Declarable.views;
   overriding
   function  depends_on          (Self : access Item;   a_Declarable : in c_Declarable.view) return Boolean;

   overriding
   function  depends_directly_on (Self : access Item;   a_Declarable : in c_Declarable.view) return Boolean;

   overriding
   function  directly_depended_on_Declarations
                                 (Self : access Item) return c_Declarable.views;


   --  Operations
   --

   procedure verify (Self : access Item);


end c_Variable;
