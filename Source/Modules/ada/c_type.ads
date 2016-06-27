with
     c_Declarable,
     GMP.discrete,

     ada.Containers.Vectors,
     ada.Containers.hashed_Maps,
     ada.Strings.unbounded.Hash;

limited
with
     c_nameSpace,
     c_Function,
     c_Variable;


package c_Type
--
--  Models any kind of C type.
--
is
   use ada.Strings.unbounded;


   type Item  is new c_Declarable.item with private;

   type View  is access all Item;
   type Views is array (Positive range <>) of View;



   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;


   package name_Maps_of_c_type is new ada.Containers.hashed_Maps (unbounded_String,
                                                                  c_Type.view,
                                                                  ada.strings.Unbounded.Hash, "=");


   --  Core Types
   --
   type a_c_type_Kind is (Unknown,
                          array_Type,
                          opaque_Struct,
                          incomplete_Class,
                          c_Class,
                          Enum,
                          standard_c_Type,    -- Models a c/c++ standard type (int, float, std::string, ie anything with a dedicated typemap).
                          function_Pointer,
                          typedef_Function,
                          type_Pointer,
                          Typedef,
                          virtual_class_Pointer);

   type an_import_Convention is (Unknown, import_as_C, import_as_CPP);



   --  Forge
   --

   function new_virtual_class_Pointer       (nameSpace           : access c_nameSpace.item'Class := null;
                                             Name                : in     unbounded_String       := null_unbounded_String;
                                             base_Type           : in     c_Type.view) return c_Type.view;

   function virtual_class_Pointer_construct (nameSpace           : access c_nameSpace.item'Class := null;
                                             Name                : in     unbounded_String       := null_unbounded_String;
                                             base_Type           : in     c_Type.view) return c_Type.item;



   function new_Typedef          (nameSpace           : access c_nameSpace.item'Class := null;
                                  Name                : in     unbounded_String       := null_unbounded_String;
                                  base_Type           : in     c_Type.view) return c_Type.view;

   function Typedef_construct    (nameSpace           : access c_nameSpace.item'Class := null;
                                  Name                : in     unbounded_String       := null_unbounded_String;
                                  base_Type           : in     c_Type.view) return c_Type.item;

   function new_type_Pointer     (nameSpace           : access c_nameSpace.item'class := null;
                                  Name                : in     unbounded_String       := null_unbounded_String;
                                  accessed_Type       : in     c_Type.view) return c_Type.view;



   function new_function_Pointer (nameSpace           : access c_nameSpace.item'Class := null;
                                  Name                : in     unbounded_String       := null_unbounded_String;
                                  accessed_Function   : access c_Function.item'Class) return c_Type.view;

   function new_typedef_Function (nameSpace           : access c_nameSpace.item'Class := null;
                                  Name                : in     unbounded_String       := null_unbounded_String;
                                  typed_Function      : access c_Function.item'Class) return c_Type.view;



   function new_array_Type       (nameSpace           : access c_nameSpace.item'class := null;
                                  Name                : in     unbounded_String       := null_unbounded_String;
                                  element_Type        : in     c_Type.view) return c_Type.view;



   function new_standard_c_Type  (nameSpace           : access c_nameSpace.item'Class;              -- tbd: rename to 'standard_c_type' to core_c_type
                                  Name                : in     unbounded_String) return c_Type.view;


   function c_opaque_Struct_construct
                                 (nameSpace           : access c_nameSpace.item'Class;
                                  Name                : in     unbounded_String) return c_Type.item;

   function new_opaque_Struct    (nameSpace           : access c_nameSpace.item'Class;
                                  Name                : in     unbounded_String) return c_Type.view;


   function c_incomplete_Class_construct
                                 (nameSpace           : access c_nameSpace.item'Class;
                                  Name                : in     unbounded_String) return c_Type.item;

   function new_incomplete_Class (nameSpace           : access c_nameSpace.item'Class;
                                  Name                : in     unbounded_String) return c_Type.view;


   function Enum_construct       (nameSpace           : access c_nameSpace.item'Class;
                                  Name                : in     unbounded_String) return c_Type.item;

   function new_Enum             (nameSpace           : access c_nameSpace.item'Class;
                                  Name                : in     unbounded_String) return c_Type.view;

   function c_Class_construct    (nameSpace           : access c_nameSpace.item'Class;
                                  Name                : in     unbounded_String) return c_Type.item;

   function new_c_Class          (nameSpace           : access c_nameSpace.item'class;
                                  Name                : in     unbounded_String) return c_Type.view;

   function new_unknown_Type                                                     return c_Type.view;
   --
   --  Returned object is *mutable*.




   --  Attributes
   --

   function c_type_Kind               (Self : access Item)     return a_c_type_Kind;


   procedure Name_is                  (Self : access Item;   Now : in unbounded_String);
   overriding
   function  Name                     (Self : access Item)     return unbounded_String;
   function  qualified_Name           (Self : access Item)     return unbounded_String;


   procedure nameSpace_is             (Self : access Item;   Now : access c_nameSpace.item'class);
   function  nameSpace                (Self : access Item)  return access c_nameSpace.item'class;

   procedure import_Convention_is     (Self : access Item;   Now : in an_import_Convention);


   overriding
   function  required_Types           (Self : access Item)     return c_declarable.c_Type_views;   -- the types on which this type depends.
   overriding
   function  depends_on               (Self : access Item;   a_Declarable : in     c_Declarable.view) return Boolean;

   overriding
   function  depends_directly_on      (Self : access Item;   a_Declarable : in     c_Declarable.view) return Boolean;
   overriding
   function  directly_depended_on_Declarations
                                      (Self : access Item) return c_Declarable.views;

   function  is_Ignored               (Self : access Item) return Boolean;
   procedure ignore                   (Self : access Item);


   function  ultimate_base_Type       (Self : access Item) return c_Type.view;
   function  is_ultimately_Unsigned   (Self : access Item) return Boolean;

   procedure resolved_Type_is         (Self : access Item;   Now : in c_Type.view);
   function  resolved_Type            (Self : access Item)     return c_Type.view;


   function  context_required_Type    (Self : access Item) return c_Type.view;
   overriding
   function  depended_on_Declarations (Self : access Item) return c_Declarable.views;




   --  Operations
   --

   procedure verify (Self : access Item);




   --  'type_Pointer' Attributes
   --

   function accessed_Type (Self : access Item) return c_Type.view;



   --  'Enum' Attributes
   --

   type enum_Literal is
      record
         Name  : unbounded_String;
         Value : gmp.discrete.Integer;
      end record;

   package enum_literal_Vectors is new ada.containers.Vectors (Positive, enum_Literal);


   procedure add_Literal                  (Self : access Item;   Name         : in unbounded_String;
                                                                 Value        : in gmp.discrete.Integer);
   function  contains_Literal             (Self : access Item;   Named        : in     String)            return Boolean;

   procedure add_transformed_Literal      (Self : access Item;   literal_Name : in     unbounded_String);
   function  contains_transformed_Literal (Self : access Item;   Named        : in     unbounded_String)  return Boolean;

   function  Literals                     (Self : access Item) return enum_literal_vectors.Vector;



   --  'array_Type' Attributes
   --
   unConstrained : constant := -1;

   type array_dimension_upper_Bounds is array (Positive range <>) of Integer;


   function  element_Type                 (Self : access Item) return c_Type.view;
   procedure add_array_Dimension          (Self : access Item;   upper_Bound : in     Integer := unConstrained);

   function  is_Unconstrained             (Self : access Item) return Boolean;

   function  array_dimension_Count        (Self : access Item) return Natural;
   function  array_Dimensions_upper_Bound (Self : access Item) return array_dimension_upper_Bounds;



   --  'c_Class' Attributes
   --

   type record_Components is array (Positive range <>) of access c_Variable.item'Class;


   function  use_type_Text                       (Self : access Item) return String;

   function  is_Limited                          (Self : access Item) return Boolean;
   function  is_tagged_Type                      (Self : access Item) return Boolean;
   function  is_Virtual                          (Self : access Item) return Boolean;
   function  is_Union                            (Self : access Item) return Boolean;

   function  virtual_member_function_Count       (Self : access Item) return Natural;
   function  pure_virtual_member_function_Count  (Self : access Item) return Natural;
   function  total_virtual_member_function_Count (Self : access Item) return Natural;
   function  is_interface_Type                   (Self : access Item) return Boolean;

   procedure add_Base                            (Self : access Item;   base_Class    : in     c_Type.view);
   function  base_Classes                        (Self : access Item) return c_Type.Vector;

   procedure add_Component                       (Self : access Item;   new_Component : access c_Variable.item'Class);
   function  component_Count                     (Self : access Item) return Natural;
   function  Components                          (Self : access Item) return record_Components;

   procedure is_Union                            (Self : access Item);

   function contains_bit_Fields                  (Self : access Item) return Boolean;

   function requires_Interfaces_C_Int_use             (Self : access Item) return Boolean;
   function requires_Interfaces_C_Unsigned_use        (Self : access Item) return Boolean;
   function requires_Interfaces_C_Unsigned_Char_use   (Self : access Item) return Boolean;
   function requires_Interfaces_C_Extensions_bool_use (Self : access Item) return Boolean;



   --  'function_Pointer' Attributes
   --

   function accessed_Function  (Self : access Item) return access c_Function.item'Class;



   --  'typedef_Function' Attributes
   --

   function typed_Function  (Self : access Item) return access c_Function.item'Class;



   --  'Typedef' Attributes
   --

   function base_Type (Self : access Item) return c_Type.view;




private

   package unbounded_string_Vectors is new ada.containers.Vectors (Positive, unbounded_String);
   use unbounded_string_Vectors;


   type Item_mutable (c_type_Kind : a_c_type_Kind := Unknown) is
      record
         nameSpace         : access c_nameSpace.item'class;
         Name              :        unbounded_String;
         import_Convention :        an_import_Convention := Unknown;

         resolved_Type     :        c_Type.view;                           -- tbd: move this to 'Unknown' variant.
         Ignore            :        Boolean              := False;

         case c_type_Kind is
            when array_Type =>
               element_Type                 : c_Type.view;

               array_dimension_Count        : Natural                               := 0;
               array_Dimensions_upper_Bound : array_dimension_upper_Bounds (1 .. 55);

            when c_Class =>
               base_Classes                 : c_Type.Vector;

               Components                   : record_Components (1 .. 500);         -- C++ class member variables (tbd: rename ?).
               component_Count              : Natural                     := 0;

               is_Union                                  : Boolean        := False;
               requires_Interfaces_C_Int_use             : Boolean        := False;
               requires_Interfaces_C_Unsigned_use        : Boolean        := False;
               requires_Interfaces_C_Unsigned_Char_use   : Boolean        := False;
               requires_Interfaces_C_Extensions_bool_use : Boolean        := False;

            when Enum =>
               Literals                     : enum_literal_vectors.Vector;
               transformed_literals_Names   : unbounded_string_vectors.Vector;

            when function_Pointer =>
               accessed_Function            : access c_Function.item'Class;     -- Subprogram definition of an 'access subprogram' type declaration.

            when typedef_Function =>
               typed_Function               : access c_Function.item'Class;     -- Subprogram definition of an 'access subprogram' type declaration.

            when type_Pointer =>
               accessed_Type                : c_Type.view;                      -- The base type to which the access refers.

            when Typedef =>
               base_Type                    : c_Type.view;                      -- The base type of the typedef (ie, the 'int' in   'typedef  int  Index_Type;').

            when virtual_class_Pointer =>
               pointee_Type                 : c_Type.view;                      -- The pointed to virtual class type.

            when Unknown
               | opaque_Struct
               | incomplete_Class
               | standard_c_Type  =>
               null;
         end case;
      end record;


   type Item is new c_Declarable.item with
      record
         My : Item_mutable;
      end record;


end c_Type;



--- Design notes:
--

--  Using a mutable variant type to allow for object morphing.
--  This avoids the need for adding a level of indirection to cope with forward declared and forward 'referred' types.
--  The mutable type is wrapped in a record to allow access type use (since a mutable object allocated via 'new' becomes immmutable).
--  The wrapper type is tagged to allow 'object.operation' notation.
--  Note that the rules have changed for mutable types in Ada'05, and the wrapper is now not strictly necessary.
