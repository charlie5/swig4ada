with
     ada_Type,
     ada_Parameter,
     ada.Strings.unbounded,
     ada.Containers.Vectors;

limited
with
     ada_Package;


package ada_Subprogram
--
-- Models an Ada subprogram.
--
is
   use ada.Strings.unbounded;


   type access_Mode is (unknown, public_access, protected_access, private_access);

   type Item is tagged
      record
         Name               : unbounded_String;
         Parameters         : ada_Parameter.Vector;
         return_Type        : ada_Type.view;

         is_Constructor     : Boolean := False;
         is_Destructor      : Boolean := False;
         is_Virtual         : Boolean := False;
         is_Abstract        : Boolean := False;
         is_Overriding      : Boolean := False;
         returns_an_Access  : Boolean := False;

         is_to_view_Conversion    : Boolean := False;
         is_to_pointer_Conversion : Boolean := False;

         constructor_Symbol : unbounded_String;
         access_Mode        : ada_Subprogram.access_Mode := Unknown;
         link_Symbol        : unbounded_String;
      end record;

   type View is access all item'Class;


   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;


   --  Forge
   --
   function construct          (the_Name    : in unbounded_String;
                                return_Type : in ada_Type.view) return Item'Class;

   function new_ada_Subprogram (the_Name    : in unbounded_String;
                                return_Type : in ada_Type.view) return View;

   --  Attributes
   --
   function is_Procedure           (Self : access Item) return Boolean;
   function is_Function            (Self : access Item) return Boolean;

   function required_Types         (Self : access Item) return ada_Type.views;
   function context_required_Types (Self : access Item) return ada_Type.views;

   function depends_on             (Self : access Item;   a_Type : in ada_Type.view;
                                                          Depth  : in Natural) return Boolean;

   function depends_directly_on    (Self : access Item;   a_Type : in ada_Type.view;
                                                          Depth  : in Natural) return Boolean;

   function depends_on             (Self : access Item;   a_Package : access ada_Package.item'class;
                                                          Depth     : in     Natural) return Boolean;

   function depends_on_any_pointer (Self : access Item) return Boolean;

   function pragma_import_Source   (Self : access Item;   declaration_Package  : access ada_Package.item'Class;
                                                          unique_function_Name : in     unbounded_String;
                                                          in_cpp_Mode          : in     Boolean) return unbounded_String;

   function pragma_CPP_Constructor_Source (Self : access Item;   declaration_Package  : access ada_Package.item'Class;
                                                                 unique_function_Name : in     unbounded_String;
                                                                 in_cpp_Mode          : in     Boolean) return unbounded_String;

   function member_function_link_Symbol_for (Self : access Item;   in_cpp_Mode : in Boolean) return unbounded_String;


   --  Operations
   --
   procedure verify (Self : access Item);

end ada_Subprogram;
