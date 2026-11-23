with
     ada_Variable;


package ada_Type.composite.a_record
--
-- Models an Ada 'record'.
--
is

   type Item is new ada_Type.composite.item with private;

   type View  is access all Item;
   type Views is array (Positive range <>) of View;


   --  Containers
   --

   package Vectors is new ada.Containers.Vectors (Positive, View);

   subtype Vector is Vectors.Vector;
   subtype Cursor is Vectors.Cursor;


   --  Forge
   --

   function new_Item (declaration_Package : access ada_Package.item'Class := null;
                      Name                : in     unbounded_String       := null_unbounded_String) return View;


   --  Attributes
   --

   type record_Components      is array (Positive range <>) of access ada_Variable.item'Class;
   type record_Components_view is access record_Components;

   function  use_type_Text  (Self : access Item) return String;

   function  is_Limited     (Self : access Item) return Boolean;
   function  is_tagged_Type (Self : access Item) return Boolean;
   function  is_Virtual     (Self : access Item) return Boolean;
   function  is_Abstract    (Self : access Item) return Boolean;

   function  is_Union       (Self : access Item) return Boolean;
   procedure is_Union       (Self : access Item);
   procedure has_virtual_Members (Self : access Item);

   procedure has_nontrivial_Members (Self : access Item);
   procedure is_not_layout_Pod      (Self : access Item);
   procedure lose_Layout            (Self : access Item);
   function  has_lost_Layout        (Self : access Item) return Boolean;              -- It has lost a base class or a member, and does not match its class.
   procedure has_an_unknown_Base    (Self : access Item);
   function  has_an_unknown_Base    (Self : access Item) return Boolean;              -- A base class of its class, or of one of those, was never shown to SWIG.
   procedure layout_Name_is         (Self : access Item;   Now : in unbounded_String);
   function  layout_Name            (Self : access Item) return unbounded_String;     -- The name of the class in the wrapper file, or null.
   function  is_layout_Pod          (Self : access Item) return Boolean;
   --
   --  The C++ class declares a destructor or a copy constructor.

   function  is_Nontrivial  (Self : access Item) return Boolean;
   --
   --  The C++ class is not trivially copyable: it declares a destructor or a copy constructor, or has a base class
   --  or a member which does. C++ passes and returns such a class by reference, and only C++ can construct it.

   function  is_constructed_by_Cpp (Self : access Item) return Boolean;
   --
   --  True for a virtual class and for one which is not trivial. Either is a limited
   --  type of convention CPP, whose objects are made by an imported C++ constructor.

   function  virtual_member_function_Count       (Self : access Item) return Natural;
   function  pure_virtual_member_function_Count  (Self : access Item) return Natural;
   function  total_virtual_member_function_Count (Self : access Item) return Natural;
   function  is_interface_Type                   (Self : access Item) return Boolean;

   procedure add_Base        (Self : access Item;   base_Class : in ada_Type.view);
   function  base_Classes    (Self : access Item) return ada_Type.Vector;

   procedure add_Component   (Self : access Item;   new_Component : access ada_Variable.item'Class);
   function  component_Count (Self : access Item) return Natural;
   function  Components      (Self : access Item) return record_Components;

   function contains_bit_Fields (Self : access Item) return Boolean;

   function requires_Interfaces_C_Int_use             (Self : access Item) return Boolean;
   function requires_Interfaces_C_Unsigned_use        (Self : access Item) return Boolean;
   function requires_Interfaces_C_Unsigned_Char_use   (Self : access Item) return Boolean;
   function requires_Interfaces_C_Extensions_bool_use (Self : access Item) return Boolean;

   overriding
   procedure verify         (Self : access Item);

   overriding
   function  required_Types (Self : access Item) return ada_Type.views;

   overriding
   function  context_required_Types
                            (Self : access Item) return ada_Type.views;
   overriding
   function  depends_on     (Self : access Item;   a_Type    : in     ada_Type.view;
                                                   Depth     : in     Natural) return Boolean;
   overriding
   function  depends_directly_on
                            (Self : access Item;   a_Type    : in     ada_Type.view;
                                                   Depth     : in     Natural) return Boolean;
   overriding
   function  depends_on     (Self : access Item;   a_Package : access ada_Package.item'Class;
                                                   Depth     : in     Natural) return Boolean;
   overriding
   function resolved_Type (Self : access Item) return ada_Type.view;



private

   type Item is new ada_Type.composite.item with
      record
         base_Classes    : ada_Type.Vector;

         Components      : record_Components_view := new record_Components (1 .. 16);     -- In storage which grows as components are added ('make_Room').
         component_Count : Natural := 0;

         is_Union                                  : Boolean := False;
         has_virtual_Members                       : Boolean := False;
         has_nontrivial_Members                    : Boolean := False;
         is_not_layout_Pod                         : Boolean := False;
         layout_Name                               : unbounded_String;
         has_lost_Layout                           : Boolean := False;
         has_an_unknown_Base                       : Boolean := False;
         requires_Interfaces_C_Int_use             : Boolean := False;
         requires_Interfaces_C_Unsigned_use        : Boolean := False;
         requires_Interfaces_C_Unsigned_Char_use   : Boolean := False;
         requires_Interfaces_C_Extensions_bool_use : Boolean := False;
      end record;

end ada_Type.composite.a_record;
