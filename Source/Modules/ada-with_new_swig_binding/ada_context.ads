with ada_Package;
with ada_Type;

with ada.Strings.unbounded;       use ada.Strings.unbounded;
--  with ada.containers.hashed_Sets;
with ada.containers.hashed_Maps;
with ada.unchecked_Conversion;


package ada_Context
--
--  Models an Ada library unit context.
--
is

   type Item is tagged private;




   --  Attributes
   --

   function to_Source (Self : in Item;   own_Package      : in ada_Package.view;                      -- the package to which the context applies.
                                         namespace_Prefix : in unbounded_String)  return String;




   --  Operations
   --

   procedure add (Self : in out Item;   required_Type  : in ada_Type.view);
   procedure add (Self : in out Item;   required_Types : in ada_Type.views);

   procedure add (Self : in out Item;   required_Type  : in ada_Type.view;
                                        is_access      : in Boolean);



private

   type type_Info is
      record
         my_Type    : ada_Type.view;
         is_accessed : Boolean;
      end record;


   function to_Hash is new ada.unchecked_Conversion (ada_Type.view, ada.containers.Hash_type);

   function to_Hash         (Self : in type_Info) return ada.containers.Hash_type;

   package ada_type_Maps is new ada.containers.hashed_Maps (ada_Type.view, type_Info,
                                                             to_Hash, ada_Type."=");

   subtype ada_type_Set        is ada_type_Maps.Map;
   subtype ada_type_set_Cursor is ada_type_Maps.Cursor;



   type Item is tagged
      record
         a_required_Types : ada_Type_Set;
      end record;


end ada_Context;
