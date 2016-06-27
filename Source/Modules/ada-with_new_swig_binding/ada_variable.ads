with ada_Type;
--  with package_Member;
with ada.containers.Vectors;
with ada.Strings.unbounded;    use ada.Strings.unbounded;


package ada_Variable
--
--
--
is

   package array_Bounds_Vectors is new ada.containers.Vectors (index_type   => Positive,
                                                               element_type => Integer);

   type Item is tagged
      record
         Name      : unbounded_String;
         my_Type   : ada_Type.view;
         Value     : unbounded_String;

         --  old
         bit_Field : Integer                           := -1;             -- '-1' indicates 'undefined'
         array_Bounds     : array_bounds_vectors.Vector;
--           is_Constant      : Boolean                    := False;
         is_Pointer       : Boolean                    := False;
         is_class_Pointer : Boolean                    := False;
      end record;


   type View is access all item'Class;



   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;




   --  Forge
   --

   function new_ada_Variable (the_Name : in unbounded_String;
                              the_Type : in ada_Type.view;
                              Value    : in unbounded_String := null_unbounded_String) return View;



   --  Attributes
   --

   function is_Constant (Self : in Item'Class) return Boolean;



   --  Operations
   --

   procedure verify (Self : access Item);


end ada_Variable;
