with
     c_Declarable,
     c_Type,
     c_Parameter,

     ada.Strings.unbounded,
     ada.Containers.Vectors;

limited
with
     c_nameSpace;


package c_Function
--
-- Models a C function.
--
is
   use ada.Strings.unbounded;

   type access_Mode is (Unknown, public_Access, protected_Access, private_Access);

   type Item is new c_Declarable.item with
      record
         Name        : unbounded_String;
         Parameters  : c_Parameter.Vector;
         return_Type : c_Type.view;

         is_Static     : Boolean := False;
         is_Virtual    : Boolean := False;
         is_Abstract   : Boolean := False;
         is_Overriding : Boolean := False;

         is_Constructor    : Boolean := False;
         is_Destructor     : Boolean := False;
         returns_an_Access : Boolean := False;

         is_to_view_Conversion    : Boolean := False;
         is_to_pointer_Conversion : Boolean := False;

         access_Mode : c_function.access_Mode := Unknown;

         constructor_Symbol : unbounded_String;
         link_Symbol        : unbounded_String;
      end record;

   type View is access all item'Class;


   --------------
   --  Containers
   --
   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;


   ---------
   --  Forge
   --
   function construct      (the_Name    : in unbounded_String;
                            return_Type : in c_Type.view) return Item'Class;


   function new_c_Function (the_Name    : in unbounded_String;
                            return_Type : in c_Type.view) return View;


   --------------
   --  Attributes
   --

   function is_Procedure              (Self : access Item) return Boolean;
   function is_Function               (Self : access Item) return Boolean;

   function member_function_link_Symbol_for
                                      (Self : access Item;   in_cpp_Mode : in Boolean) return unbounded_String;

   overriding
   function Name                      (Self : access Item) return ada.Strings.Unbounded.unbounded_String;

   overriding
   function  required_Types           (Self : access Item) return c_declarable.c_Type_views;

   overriding
   function  depended_on_Declarations (Self : access Item) return c_Declarable.views;

   overriding
   function  depends_on               (Self : access Item;   a_Declarable : in c_Declarable.view) return Boolean;

   overriding
   function  depends_directly_on      (Self : access Item;   a_Declarable : in c_Declarable.view) return Boolean;

   overriding
   function  directly_depended_on_Declarations
                                      (Self : access Item) return c_Declarable.views;

   --------------
   --  Operations
   --
   procedure verify (Self : access Item);

end c_Function;
