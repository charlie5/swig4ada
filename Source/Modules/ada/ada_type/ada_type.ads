with
     ada.Containers.Vectors,
     ada.Strings.unbounded.Hash,
     ada.Containers.hashed_Maps;

limited
with
     ada_Package;


package ada_Type
--
-- Models an Ada type.
--
is
   use ada.Strings.unbounded;


   type Item  is abstract tagged private;

   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;



   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector  is Vectors.Vector;
   subtype Cursor  is Vectors.Cursor;


   package name_Maps_of_ada_type is new ada.containers.hashed_Maps (unbounded_String,
                                                                    ada_Type.view,
                                                                    ada.Strings.unbounded.Hash, "=");



   --  Core Types
   --

   type an_import_Convention is (Unknown, import_as_C, import_as_CPP);



   --  Attributes
   --

   function  required_Types          (Self : access Item) return ada_Type.views     is abstract;
   function  context_required_Types  (Self : access Item) return ada_Type.views     is abstract;

   function  depends_on              (Self : access Item;   a_Type : in ada_Type.view;
                                                            Depth     : in     Natural)  return Boolean   is abstract;
   function  depends_directly_on     (Self : access Item;   a_Type : in ada_Type.view;
                                                            Depth  : in Natural)        return Boolean   is abstract;

   function  depends_on              (Self : access Item;   a_Package : access ada_Package.item'Class;
                                                            Depth     : in     Natural) return Boolean   is abstract;


   procedure Name_is                 (Self : access Item;   Now : in unbounded_String);
   function  Name                    (Self : access Item)     return unbounded_String;
   function  qualified_Name          (Self : access Item)     return unbounded_String;


   procedure declaration_Package_is  (Self : access Item;   Now : access ada_Package.item'Class);
   function  declaration_Package     (Self : access Item)  return access ada_Package.item'Class;


   function  is_ultimately_Unsigned  (Self : access Item'Class) return Boolean;
   function  resolved_Type           (Self : access Item)       return ada_Type.view   is abstract;

   function  Image                   (Self : access Item)  return String;
   function  Image                   (Self : in     Views) return String;



   --  Operations
   --

   procedure verify (Self : access Item) is null;




private

   package unbounded_string_Vectors is new ada.containers.Vectors (Positive, unbounded_String);
   use unbounded_string_Vectors;


   type Item is abstract tagged
      record
         declaration_Package : access ada_Package.item'Class;
         Name                :        unbounded_String;
      end record;

end ada_Type;
