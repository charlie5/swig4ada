limited with c_Type;

with ada.Strings.unbounded;
with ada.containers.Vectors;


package c_Declarable
--
--
--
is

   type Item is abstract tagged private;
   type View is access all Item'class;
   type Views is array (Positive range <>) of View;



   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;




   --  Attributes
   --

   function Name (Self : access Item) return ada.Strings.Unbounded.unbounded_String   is abstract;



   type c_Type_views is array (Positive range <>) of access c_Type.Item'Class;

   function  required_Types (Self : access Item) return c_Type_views   is abstract;
   --
   --  The types on which this type depends.


   function depended_on_Declarations          (Self   : access Item)                                               return c_Declarable.views    is abstract;
   function directly_depended_on_Declarations (Self   : access Item)                                               return c_Declarable.views    is abstract;

   function depends_on               (Self   : access Item;   a_Declarable : in     c_Declarable.view)    return Boolean               is abstract;
   function depends_directly_on      (Self   : access Item;   a_Declarable : in     c_Declarable.view)    return Boolean               is abstract;




private

   type Item is abstract tagged
      record
         null;
      end record;

end c_Declarable;
