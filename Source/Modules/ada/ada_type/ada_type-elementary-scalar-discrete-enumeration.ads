with
     gmp.Discrete;


package ada_Type.elementary.scalar.discrete.enumeration
--
--  Models an enumeration type.
--
is

   type Item  is new ada_Type.elementary.scalar.discrete.item with private;

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

   type enum_Literal is
      record
         Name  : unbounded_String;
         Value : gmp.discrete.Integer;
      end record;

   package enum_literal_Vectors is new ada.containers.Vectors (Positive, enum_Literal);


   procedure add_Literal                  (Self : access Item;   Name         : in unbounded_String;
                                                                 Value        : in gmp.discrete.Integer);
   function  contains_Literal             (Self : access Item;   Named        : in String)           return Boolean;

   procedure add_transformed_Literal      (Self : access Item;   literal_Name : in unbounded_String);
   function  contains_transformed_Literal (Self : access Item;   Named        : in unbounded_String) return Boolean;

   function  Literals                     (Self : access Item) return enum_literal_vectors.Vector;

   overriding
   function context_required_Types        (Self : access Item) return ada_Type.views;


   --  Operations
   --

   overriding
   procedure verify (Self : access Item);



private

   type Item is new ada_Type.elementary.scalar.discrete.item with
      record
         Literals                   : enum_literal_vectors.Vector;
         transformed_literals_Names : unbounded_string_vectors.Vector;
      end record;

end ada_Type.elementary.scalar.discrete.enumeration;

