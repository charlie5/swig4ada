with c_Type;
with ada.Strings.unbounded;   use ada.Strings.unbounded;
with ada.containers.Vectors;
with c_Declarable; use c_Declarable;


package c_Parameter
is

   type Mode_kind is (in_mode, in_out_mode, access_mode, out_mode);


   type Item is tagged
      record
         Name    : unbounded_String;
         my_Type : c_Type.view;

         --  old

         is_Pointer       : Boolean         := False;
         link_symbol_Code : unbounded_String;

      end record;

   type View is access all Item'Class;



   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;




   --  Forge
   --

   function construct     (the_Name : in unbounded_String;
                           the_Type : in c_Type.view) return item'Class;


   function new_c_Parameter (the_Name : in unbounded_String;
                             the_Type : in c_Type.view) return View;




   --  Attributes
   --

   function required_Types           (Self : in c_Parameter.Vector) return c_Declarable.c_Type_views;
   function depended_on_Declarations (Self : in c_Parameter.Vector) return c_Declarable.views;
   function depends_on               (Self : in c_Parameter.Vector;   the_Declarable : in c_Declarable.view) return Boolean;

   function depends_directly_on               (Self : in c_Parameter.Vector;   the_Declarable : in c_Declarable.view) return Boolean;
   function directly_depended_on_Declarations (Self : in c_Parameter.Vector) return c_Declarable.views;


end c_Parameter;
