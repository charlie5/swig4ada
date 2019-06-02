with
     ada_Context,
     ada_Type.composite.a_record,
     ada_Type,
     ada_Subprogram,
     ada_Variable,

     ada.Strings.unbounded,
     ada.containers.Vectors,
     ada.containers.hashed_Sets,
     ada.unchecked_Conversion;


package ada_Package
--
-- Models an Ada package.
--
is
   use ada.strings.Unbounded;

   type Item is tagged private;
   type View is access all Item'class;


   -- Containers
   --

   --  Vector

   package Vectors is new ada.containers.Vectors (Positive, View);

   subtype Vector        is Vectors.Vector;
   subtype vector_Cursor is Vectors.Cursor;

   --  Set

   function to_Hash is new ada.unchecked_Conversion (View, ada.containers.Hash_type);
   function equivalent_Views (Left : View;   Right : View) return Boolean renames "=";

   package Sets is new ada.containers.hashed_Sets (View, to_Hash, equivalent_Views);

   subtype Set        is sets.Set;
   subtype set_Cursor is sets.Cursor;


   --  Forge
   --

   function new_ada_Package (Name    : in String;
                             Parent  : in View    := null;
                             is_Core : in Boolean := False) return View;


   --  Attributes
   --

   type a_Kind is (Binding, module_Import, header_Import, Core);

   function  Kind                       (Self : access Item)     return a_Kind;
   procedure Kind_is                    (Self : access Item;   Now : in a_Kind);


   function  Parent                     (Self : access Item)     return access Item;

   function  has_Ancestor               (Self : access Item;   possible_Ancestor : access ada_Package.item'Class)
                                                                 return Boolean;
   function  Name                       (Self : access Item)     return unbounded_String;
   procedure Name_is                    (Self : access Item;   Now : in String);

   function  qualified_Name             (Self : access Item)     return unbounded_String;

   function  is_Module                  (Self : access Item)     return Boolean;
   procedure is_Module                  (Self : access Item);

   function  is_Core                    (Self : access Item)     return Boolean;
   procedure is_Core                    (Self : access Item);

   procedure is_Unknown                 (Self : access Item);

   procedure is_enum_Proxy              (Self : access Item);


   procedure is_global_Namespace        (Self : access Item);
   function  is_global_Namespace        (Self : access Item)     return Boolean;


   function  models_a_virtual_cpp_Class (Self : access Item)     return Boolean;
   function  models_an_interface_Type   (Self : access Item)     return Boolean;


   procedure add                        (Self : access Item;   new_Subprogram : in ada_Subprogram.view);
   procedure add                        (Self : access Item;   new_Variable   : in ada_Variable.view);

   procedure add                        (Self : access Item;   new_Type       : in ada_Type.view);
   procedure rid                        (Self : access Item;   the_Type       : in ada_Type.view);

   procedure models_cpp_class_Type      (Self : access Item;   new_Class      : in ada_Type.composite.a_record.view);
   function  cpp_class_Type             (Self : access Item)                return ada_Type.composite.a_record.view;
   --
   --  The modeled cpp_class_Type for the c++ class which the 'Self' ada_Package models.
   --  Returns 'null' when 'Self' does not model a c++ class.

   function Context                     (Self : access Item) return access ada_Context.item;
   function Subprograms                 (Self : access Item) return ada_subprogram.Vector;
   function Variables                   (Self : access Item) return ada_variable.Vector;
   function Types                       (Self : access Item) return ada_type.Vector;

   function type_name_needs_Standard_prefix (Self : access Item'class;   Name     : in String;
                                                                         the_Type : in ada_Type.view) return Boolean;

   function Depends_on                      (Self : access Item;         Other    : in ada_Package.view;
                                                                         Depth    : in     Natural)  return Boolean;

   --  Operations
   --

   procedure verify (Self : access Item);



private

   type Item is tagged
      record
         a_Kind                : ada_Package.a_Kind;
         a_Parent              : ada_Package.view;
         a_Name                : unbounded_String;

         a_is_Module           : Boolean := False;
         a_is_Import           : Boolean := False;
         a_is_Core             : Boolean := False;
         a_is_enum_Proxy       : Boolean := False;
         a_is_global_Namespace : Boolean := False;
         a_is_Unknown          : Boolean := False;

         Context               : aliased ada_Context.item;

         a_Subprograms         : ada_Subprogram.Vector;
         a_Variables           : ada_Variable  .Vector;
         a_Types               : ada_Type      .Vector;

         a_cpp_class_Type      : ada_Type.composite.a_record.view;   -- Convenience access to the 'c++ class' ada_Type which the package models.
      end record;

end ada_Package;
