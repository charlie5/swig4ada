with ada_Type;
with ada_Parameter;
limited with ada_Package;

with ada.Strings.unbounded;   use ada.Strings.unbounded;
with ada.containers.Vectors;


package ada_Subprogram
--
--
--
is

   type access_Mode is (unknown, public_access, protected_access, private_access);


   type Item is tagged
      record
         Name               : unbounded_String;
         Parameters         : ada_Parameter.Vector;
         return_Type        : ada_Type.view;

         --  old

         is_Constructor     : Boolean              := False;
         is_Destructor      : Boolean              := False;
         is_Virtual         : Boolean              := False;
         is_Abstract        : Boolean              := False;
         returns_an_Access  : Boolean              := False;

         is_to_view_Conversion      : Boolean              := False;
         is_to_pointer_Conversion   : Boolean              := False;


         constructor_Symbol : unbounded_String;

         access_Mode : ada_Subprogram.access_Mode := Unknown;


         link_Symbol    : unbounded_String;

      end record;


   type View is access all item'Class;




   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;




   --  Forge
   --

   function construct (the_Name     : in unbounded_String;
                       return_Type  : in ada_Type.view) return Item'class;


   function new_ada_Subprogram (the_Name  : in unbounded_String;
                                 return_Type  : in ada_Type.view) return View;




   --  Attributes
   --

   function is_Procedure (Self : access Item) return Boolean;
   function is_Function  (Self : access Item) return Boolean;


   function required_Types         (Self : access Item) return ada_Type.views;
   function context_required_Types (Self : access Item) return ada_Type.views;

   function depends_on          (Self : access Item;   a_Type : in     ada_Type.view) return Boolean;
   function depends_directly_on (Self : access Item;   a_Type : in     ada_Type.view) return Boolean;

   function depends_on          (Self : access Item;   a_Package : access ada_Package.item'class) return Boolean;


   function depends_on_any_pointer  (Self : access Item) return Boolean;



   function pragma_import_Source       (Self : access Item;   declaration_Package  : access ada_Package.item'class;
                                                              unique_function_Name : in     unbounded_String;
                                                              in_cpp_Mode          : in     Boolean)           return unbounded_String;


   function member_function_link_Symbol_for (Self        : access Item;
                                             in_cpp_Mode : in     Boolean) return unbounded_String;



   --  Operations
   --

   procedure verify (Self : access Item);


end ada_Subprogram;
