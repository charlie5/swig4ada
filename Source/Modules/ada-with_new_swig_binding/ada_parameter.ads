with ada_Type;
limited with ada_Package;

with ada.Strings.unbounded;   use ada.Strings.unbounded;
with ada.containers.Vectors;


package ada_Parameter
--
--
--
is

   type Mode_kind is (in_mode, in_out_mode, access_mode, out_mode);


   type Item is tagged
      record
         Name    : unbounded_String;
         my_Type : ada_Type.view;

         --  old

         is_Pointer       : Boolean         := False;
         link_symbol_Code : unbounded_String;

      end record;

   type View is access all Item'Class;



   --  Containers
   --
   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;




   --  Forge
   --

   function construct     (the_Name : in unbounded_String;
                           the_Type : in ada_Type.view) return item'Class;


   function new_ada_Parameter (the_Name : in unbounded_String;
                               the_Type : in ada_Type.view) return View;




   --  Attributes
   --

   function required_Types         (Self : in ada_Parameter.Vector) return ada_Type.views;
   function context_required_Types (Self : in ada_Parameter.Vector) return ada_Type.views;

   function depends_on (Self : in ada_Parameter.Vector;   the_Type  : in     ada_Type.view)          return Boolean;
   function depends_on (Self : in ada_Parameter.Vector;   a_Package : access ada_Package.item'class) return Boolean;


end ada_Parameter;
