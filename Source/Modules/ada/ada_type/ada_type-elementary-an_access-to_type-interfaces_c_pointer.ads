package ada_Type.elementary.an_access.to_type.interfaces_c_pointer
--
-- Models an 'interfaces.C.pointers' pointer type.
--
is

   type Item  is new ada_Type.elementary.an_access.to_type.item with private;

   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;


   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;


   --  Forge
   --

   function new_Item (declaration_Package   : access ada_Package.item'class := null;
                      Name                  : in     unbounded_String       := null_unbounded_String;
                      accessed_Type         : in     ada_Type.view) return View;


   --  Attributes
   --

   function  required_Types           (Self : in     Item) return ada_Type.views;

   overriding
   function  context_required_Types   (Self : access Item) return ada_Type.views;

   overriding
   function  depends_on               (Self : access Item;   a_Type : in ada_Type.view;
                                                             Depth  : in Natural) return Boolean;
   overriding
   function  depends_directly_on      (Self : access Item;   a_Type : in ada_Type.view;
                                                             Depth  : in Natural) return Boolean;

   procedure associated_array_Type_is (Self : access Item;   Now    : in ada_Type.view);



private

   type Item is new ada_Type.elementary.an_access.to_type.item with
      record
         associated_array_Type : ada_Type.view;
      end record;

end ada_Type.elementary.an_access.to_type.interfaces_c_pointer;

