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

         bit_Field        : Integer := undefined_Bitfield;

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
