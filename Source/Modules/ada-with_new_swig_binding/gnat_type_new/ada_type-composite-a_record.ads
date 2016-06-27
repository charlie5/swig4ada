with ada_Variable;

package ada_Type.composite.a_record
--
--
--
is

   type Item is new ada_Type.composite.item with private;

   type View  is access all Item;
   type Views is array (Positive range <>) of View;



   --  Containers
   --

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;



   --  Forge
   --

   function new_Item (declaration_Package : access ada_Package.item'class := null;
                      Name                : in     unbounded_String       := null_unbounded_String) return View;



   --  Attributes
   --

   type record_Components is array (Positive range <>) of access ada_Variable.item'class;


   function  use_type_Text                       (Self : access Item) return String;

   function  is_Limited                          (Self : access Item) return Boolean;
   function  is_tagged_Type                      (Self : access Item) return Boolean;
   function  is_Virtual                          (Self : access Item) return Boolean;

   function  is_Union                            (Self : access Item) return Boolean;
   procedure is_Union                            (Self : access Item);



   function  virtual_member_function_Count       (Self : access Item) return Natural;
   function  pure_virtual_member_function_Count  (Self : access Item) return Natural;
   function  total_virtual_member_function_Count (Self : access Item) return Natural;
   function  is_interface_Type                   (Self : access Item) return Boolean;

   procedure add_Base                            (Self : access Item;   base_Class    : in     ada_Type.view);
   function  base_Classes                        (Self : access Item) return ada_Type.Vector;

   procedure add_Component                       (Self : access Item;   new_Component : access ada_Variable.item'class);
   function  component_Count                     (Self : access Item) return Natural;
   function  Components                          (Self : access Item) return record_Components;


   function contains_bit_Fields (Self : access Item) return Boolean;


   function requires_Interfaces_C_Int_use             (Self : access Item) return Boolean;
   function requires_Interfaces_C_Unsigned_use        (Self : access Item) return Boolean;
   function requires_Interfaces_C_Unsigned_Char_use   (Self : access Item) return Boolean;
   function requires_Interfaces_C_Extensions_bool_use (Self : access Item) return Boolean;


   overriding
   procedure verify                 (Self : access Item);

   overriding
   function  required_Types         (Self : access Item) return ada_Type.views;
   overriding
   function  context_required_Types (Self : access Item) return ada_Type.views;

   overriding
   function  depends_on             (Self : access Item;   a_Type    : in     ada_Type.view) return Boolean;
   overriding
   function  depends_directly_on    (Self : access Item;   a_Type    : in     ada_Type.view) return Boolean;

   overriding
   function  depends_on             (Self : access Item;   a_Package : access ada_Package.item'class) return Boolean;

   overriding
   function resolved_Type (Self : access Item) return ada_Type.view;



private

   type Item is new ada_Type.composite.item with
      record
         base_Classes    : ada_Type.Vector;

         Components      : record_Components (1 .. 500);         -- c++ class member variables (tbd: rename ?)
         component_Count : Natural                     := 0;

         is_Union                                  : Boolean := False;
         requires_Interfaces_C_Int_use             : Boolean := False;
         requires_Interfaces_C_Unsigned_use        : Boolean := False;
         requires_Interfaces_C_Unsigned_Char_use   : Boolean := False;
         requires_Interfaces_C_Extensions_bool_use : Boolean := False;
      end record;

end ada_Type.composite.a_record;

